# / routes / maintain_file.py

# system library -------------------------------------------------------------

# packages -------------------------------------------------------------------
from flask          import Flask, send_from_directory, render_template, request
from flask          import send_file, redirect, url_for, Blueprint
from flask          import session, jsonify, flash
#from flask_session  import Session
from werkzeug.utils import secure_filename
import sqlite3


# local library --------------------------------------------------------------
from config.app_config          import AppConfig
from src.document_handler       import DocumentHandler
from src.web_form_handler       import WebFormHandler

# route variables ------------------------------------------------------------
maintain_blueprint = Blueprint(name='maintain_file', import_name=__name__)


@maintain_blueprint.route('/upload_template', methods=['GET', 'POST'])
def upload_template():
    """Upload a new word template file"""

    if request.method == 'POST':
        # check if the post request has the file part
        if 'file' not in request.files:
            flash("No file selected", "danger")
            return redirect(request.url)
        # grab the file
        file = request.files['file']

        # if filename is empty re-direct
        if file.filename == '': 
            flash("No file selected", "danger")
            return redirect(request.url)
        
        # if file is valid, read the file contents
        if file:
            dh = DocumentHandler(filename=secure_filename(file.filename))
            # process the word file
            dh.process_docx(file.read())

        if dh.valid_placeholders:
            session['template_id'] = dh.template_id
            return redirect(url_for("maintain_file.set_placeholder_type",
                            template_id=dh.template_id
                            ))


    return render_template("template.html",
                            version=AppConfig.VERSION.value,
                            )


@maintain_blueprint.route('/set_placeholder_type', methods=['GET', 'POST'])
def set_placeholder_type():
    wf = WebFormHandler(template_id=0)
    templates = wf.fetch_all_templates()

    template_id = request.args.get('template_id') or session.get('template_id')
    
    if not template_id:
        template_id = 0

    session['template_id'] = template_id
    return render_template("placeholder_type.html",
                        version=AppConfig.VERSION.value,
                        placeholders=wf.fetch_all_placeholders(template_id=template_id),
                        template_id=template_id,
                        templates=templates
                        )


@maintain_blueprint.route('/set_template_session', methods=['POST'])
def set_template_session():
    """
    Updates the session variable for the selected template_id.
    """
    data = request.get_json()
    template_id = data.get("template_id")

    if template_id:
        session["template_id"] = template_id
        session["current_placeholder_index"] = 0
        return jsonify({"success": True})
    return jsonify({"success": False}), 400


@maintain_blueprint.route('/update_placeholder_type', methods=['POST'])
def update_placeholder_type():
    """
    Updates placeholder types in the database.
    """
    template_id = request.args.get('template_id') or session.get('template_id')
    
    if not template_id:
        flash("Please select a template first.", "error")
        return redirect(url_for('maintain_file.set_placeholder_type'))
    
    wf = WebFormHandler(template_id=template_id)
    wf.process_placeholders(template_id=template_id,
                            form_data=request.form
                            )
    flash("Placeholder Types are updated")
    return redirect(url_for('maintain_file.set_placeholder_type'))
    
