# / routes / generate_file.py

# system library -------------------------------------------------------------
from datetime import datetime

# packages -------------------------------------------------------------------
from flask          import Flask, send_from_directory, render_template, request
from flask          import send_file, redirect, url_for, Blueprint
from flask          import session, jsonify, flash
#from flask_session  import Session
from werkzeug.utils import secure_filename
import sqlite3


# local library --------------------------------------------------------------
from src.replacement_handler    import ReplacementHandler
from src.web_form_handler       import WebFormHandler
from src.word_document_handler  import WordDocumentHandler
from src.document_handler       import DocumentHandler

# route variables ------------------------------------------------------------
generate_blueprint = Blueprint(name='generate_file', import_name=__name__)

def clear_flash_messages():
    """
    Manually Clear any previously flashed messages
    """
    session.pop('_flashes', None)

@generate_blueprint.route('/download_word_document', methods=['GET'])
def download_word_document():
    """
    Fetch document from database and return as attachment
    """
    current_time = datetime.now().strftime('%H:%M:%S')
    file_id = session['generated_file_id_word']
    if file_id:
        dh = DocumentHandler()
        output_file_name, output_file = dh.retrieve_word_document(generated_file_id=session['generated_file_id_word'])
        flash(f"{current_time} - Downloaded file {output_file_name}")
        return send_file(output_file, as_attachment=True, download_name=output_file_name, mimetype="application/vnd.openxmlformats-officedocument.wordprocessingml.document")
       
    else:
        flash(f"{current_time} - requested file not in database")
        render_template("generate_document.html",
                        word_file_generated='False',
                        )

@generate_blueprint.route('/flash_download_message', methods=['POST'])
def flash_download_message():
    clear_flash_messages()
    current_time = datetime.now().strftime('%H:%M:%S')
    flash(f"{current_time} - Your Word document has been downloaded.")
    return ('', 204)  # Return empty response for fetch()


@generate_blueprint.route('/generate_document', methods=['POST'])
def generate_document():
    """Generates the final Word document with user-selected replacements"""
    template_id = session.get('template_id')
    
    if not template_id:
        return redirect(url_for('merge_blueprint.select_template'))

    rh = ReplacementHandler(template_id=template_id)
    template_data = rh.fetch_template_data()

    for data in template_data:
        template_file = data['template_file']

    if not template_data:
        return "Template not found.", 400
    
    wf = WebFormHandler(template_id=template_id)
    placeholder_data = wf.fetch_all_placeholders(template_id=template_id)

    # generate and store the word document
    wdh = WordDocumentHandler(template_id=session['template_id'],
                              generated_file_name=request.form.get(key='output_file_name',default='2000-01-01 template.docx')
                              )
    
    wdh.generate_word_document(template_file=template_file,
                               placeholder_data=placeholder_data,
                               replacement_data=dict(session)
                               )

    current_time = datetime.now().strftime('%H:%M:%S')
    flash(f"{current_time} - Word file created successfully. You can download the word file.")
    
    session['generated_file_id_word'] = wdh.generated_file_id

    return render_template("generate_document.html",
                           word_file_generated='True',
                           )

    # save generated_file
    #doc = docx.Document(io.BytesIO(template_data['template_file']))
    

    # # Replace placeholders in the document
    # for para in doc.paragraphs:
    #     for replacement in replacements:
    #         placeholder_text = f"{{{{{replacement['placeholder_name']}}}}}"
    #         if replacement['placeholder_type'] == "inline":
    #             para.text = para.text.replace(placeholder_text, replacement['replacement_value'])
    #         elif replacement['placeholder_type'] in ("list", "bullet"):
    #             para.text = para.text.replace(placeholder_text, "")
    #             if replacement['placeholder_type'] == "bullet":
    #                 para.add_run("\n• " + replacement['replacement_value'])
    #             else:
    #                 para.add_run(", " + replacement['replacement_value'])

    # # Save and send the file
    # output_stream = io.BytesIO()
    # doc.save(output_stream)
    # output_stream.seek(0)

    # return send_file(output_stream, as_attachment=True, download_name="merged_document.docx", mimetype="application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    # return render_template('error.html', error_number=-999, error_message="implementing generate_document") 
    

