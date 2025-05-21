# / routes / merge_file.py

# system library -------------------------------------------------------------

# packages -------------------------------------------------------------------
from datetime       import datetime
from flask          import Flask, send_from_directory, render_template, request
from flask          import send_file, redirect, url_for, Blueprint
from flask          import session, jsonify, flash
#from flask_session  import Session
from werkzeug.utils import secure_filename
import sqlite3


# local library --------------------------------------------------------------
from config.document_style      import DocumentStyle
from src.document_handler       import DocumentHandler
from src.web_form_handler       import WebFormHandler
from src.replacement_handler    import ReplacementHandler

# route variables ------------------------------------------------------------
merge_blueprint = Blueprint(name='merge_file', import_name=__name__)

def template_selected() -> int:
    """Set the replacement for the placeholder"""
    template_id = session.get('template_id')

    # Ensure a template is selected
    if not template_id:
        return redirect(url_for('merge_file.select_template'))
    else:
        return template_id

def is_last_placeholder(template_id: int) -> bool:
    """
    check if all the placeholders have been updated
    will redirect to create document if so
    """
    wf = WebFormHandler(template_id=template_id)
    placeholders = wf.fetch_all_placeholders(template_id)

    if not session['current_placeholder_index']:
        session['current_placeholder_index'] = 0

    if session['current_placeholder_index'] >= len(placeholders):
        session['placeholder_names'] = [row['placeholder_name'] for row in placeholders]
        return redirect(url_for('merge_file.summary'))

    return False


@merge_blueprint.route('/select_template', methods=['GET', 'POST'])
def select_template():
    """Allows user to select a template before proceeding to replacement"""
    wf = WebFormHandler(template_id=0)
    templates = wf.fetch_all_templates()
    
    if request.method == 'POST':
        # set the template_id and template_name into the session var
        template_id = request.form.get(key='template_id',default='na')
        
        # check if a valid template_id was returned
        if template_id.isnumeric():
            template_data = wf.fetch_template(template_id=int(template_id))
            for data in template_data:
                session['template_id'] = data['template_id']
                session['template_name'] = data['template_name']
            
            # if template_is is numeric move to next step,
            # else will re-show the default page
            return redirect(url_for('merge_file.replace_placeholders'))

    return render_template('select_template.html', 
                           templates=templates,
                           template_id=session.get('template_id', 0)                           
                           )


@merge_blueprint.route('/replace_placeholders', methods=['GET','POST'])
def replace_placeholders():
    """Cycles through placeholders one by one for user input"""
   
    # Ensure a template is selected
    template_id = template_selected()
    
    # if we have gone through all the placeholders then move to the final document generation
    is_last_placeholder(template_id=template_id)

    wf = WebFormHandler(template_id=template_id)
    placeholders = wf.fetch_all_placeholders(template_id)

    # if the template doesn't have any placeholders then return an error page
    if not placeholders:
        return render_template('error.html', error_number=-20, error_message="No placeholders found in template")  

    placeholder_names = [row['placeholder_name'] for row in placeholders]

    # what step are we on?
    current_index = session.get("current_placeholder_index", 0)

    # if we have gone through all the placeholders then move to the final document generation
    if current_index >= len(placeholders):
        return redirect(url_for('merge_file.summary'))

    # get the current placeholder
    placeholder = placeholders[current_index]

    rh = ReplacementHandler(template_id=template_id)
    query_data = rh.placeholder_replacements(placeholder=placeholder)

    # create the dictionary of items from the query data
    if isinstance(query_data, dict) == False:
        query_data = [{'replacement_id': row[0], 'replacement_group': row[1], 'replacement_value': row[2]} for row in query_data]

    # depending on type of placeholder return the appropriate template
    match placeholders[current_index]['placeholder_type']:
        case "static":
            html_template = 'replace_static.html'
        case "inline":
            html_template = 'replace_inline.html'
        case "list":
            html_template = 'replace_list.html'
        case "bullet":
            html_template = 'replace_list.html'
        case _:
            html_template = 'replace_static.html'

    return render_template(html_template,
                            placeholder=placeholder,
                            placeholder_names=placeholder_names,
                            items=query_data,
                            index=current_index,
                            total_placeholders=len(placeholders),  
                        )


@merge_blueprint.route('/set_replacement', methods=['POST'])
def set_replacement():
    """Set the replacement for the placeholder"""
    # Ensure a template is selected
    template_id = template_selected()

    # will redirect to generate_file.generate_document
    is_last_placeholder(template_id=template_id)

    # Get the new value from the input box and the select box separately
    new_value = request.form.get('replacement_value_input')
    select_value = request.form.get('replacement_value_select')

    # Use the new value if provided, otherwise use the select box value
    replacement_value = new_value if new_value.strip() != "" else select_value

    if new_value.strip() != "":
        rh = ReplacementHandler(template_id=template_id)
        rh.insert_replacement(placeholder_name=request.form.get('placeholder_name','DEFAULT'),
                              replacement_group=request.form.get('replacement_group','DEFAULT'),
                              replacement=replacement_value,
                              )

    # store responses in the session variables
    session[request.form.get('placeholder_name')] =[{'input_type':'single', 'item_text': replacement_value}] 
    session['current_placeholder_index'] = session['current_placeholder_index'] + 1

    # move to the next placeholder
    return redirect(url_for('merge_file.replace_placeholders'))


@merge_blueprint.route('/merge_items', methods=['POST'])
def merge_items():
    """Merge items into the placeholders"""
    # Ensure a template is selected
    template_id = template_selected()

    if request.method == 'POST':
        item_type = request.form.get('item_type')
        selected_item_ids = request.form.get('reorderedItems', '[]')
        selected_item_ids = eval(selected_item_ids)

        if len(selected_item_ids) == 0:
            # allow for blank responses
            session[item_type] = ""
        else:
            # store responses in the session variables
            rh = ReplacementHandler(template_id=template_id)
            session[item_type] = rh.selected_replacements(selected_item_ids=selected_item_ids)
        
        session['current_placeholder_index'] = session['current_placeholder_index'] + 1
        # move to the next placeholder
        return redirect(url_for('merge_file.replace_placeholders'))
    
    # Error
    return render_template('error.html', error_number=-40, error_message=f"No placeholders: {item_type} found in template") 


@merge_blueprint.route('/table_add_item', methods=['POST'])
def table_add_item():
    """Add an item to the table"""
    
    # Ensure a template is selected
    template_id = template_selected()
    
    # Get the new values from the input form
    item_type = request.form.get('item_type')
    group_name = request.form.get('group_name')
    item_text = request.form.get('item_text')
    placeholder_name = request.form.get('placeholder_name','DEFAULT')
    
    if group_name.strip() != "" and item_text.strip() != "":
        rh = ReplacementHandler(template_id=template_id)
        rh.insert_replacement(placeholder_name=placeholder_name,
                              replacement_group=group_name,
                              replacement=item_text,
                              )
    
    return jsonify({'id' : rh.query_handler.GetLastId(),
                    'group_name': group_name,
                    'item_text': item_text,
                    'status': 'success'
                })

@merge_blueprint.route('/table_delete_item', methods=['POST'])
def table_delete_item():
    """Delete an item from the table"""
    
    # Ensure a template is selected
    template_id = template_selected()    
    item_type = request.form.get('item_type')
    item_id = request.form['item_id'] 

    rh = ReplacementHandler(template_id=template_id)
    rh.delete_replacement(item_id = item_id)
    
    # if successful return success
    return jsonify({'status': 'success'})


@merge_blueprint.route('/table_update_item', methods=['POST'])
def table_update_item():
    """Update an item in the table"""
    # Ensure a template is selected
    template_id = template_selected()
    item_type = request.form.get('item_type','DEFAULT')
    item_id = request.form['item_id']
    item_text = request.form.get('item_text') 
    group_name = request.form.get('group_name')

    if group_name.strip() != "" and item_text.strip() != "":
        rh = ReplacementHandler(template_id=template_id)
        rh.update_replacement(replacement_id=int(item_id),replacement_group=group_name,replacement_value=item_text)

    return jsonify({'status': 'success'})


@merge_blueprint.route('/previous_step', methods=['POST'])
def previous_step():
    session['current_placeholder_index'] = session['current_placeholder_index'] - 1
    if session['current_placeholder_index'] < 0:
        session['current_placeholder_index'] = 0
    
    current_placeholder = request.form.get('placeholder_name')
    session[current_placeholder] = ""

    # move to the prior placeholder
    return redirect(url_for('merge_file.replace_placeholders'))


@merge_blueprint.route('/summary', methods=['GET'])
def summary():
    output_filename = session.get('template_name','None.docx')

    if DocumentStyle.OUTPUT_FILE_USE_PLACEHOLDER_VALUE.value == True:
        ph_field = DocumentStyle.OUTPUT_FILE_PLACEHOLDER_TO_USE.value
        ph_value = session.get(ph_field.upper(), 'None.docx')
        output_filename = ph_value[0]['item_text']
    
    # clip the file name
    output_filename = output_filename[:100]

    if not output_filename.lower().endswith('docx'):
        output_filename = ''.join([output_filename, '.docx'])

    file_output_string = ' '.join([datetime.today().strftime(DocumentStyle.FILENAME_DATE_FORMAT.value), output_filename])
    
    return render_template('summary.html',
                           placeholder_names=session.get('placeholder_names',[]),
                           file_output_string=file_output_string,
                           )
