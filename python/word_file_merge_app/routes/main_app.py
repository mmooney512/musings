# /routes / main_app.py

# system library -------------------------------------------------------------
import os, io, re
import sqlite3

# packages -------------------------------------------------------------------
from flask          import Flask, send_from_directory, render_template, request
from flask          import send_file, redirect, url_for, Blueprint
from flask          import session, flash
from flask          import g
#from flask_session  import Session
from werkzeug.utils import secure_filename
import docx

# local library --------------------------------------------------------------
from config.app_config import AppConfig
from src.document_handler import DocumentHandler


base_blueprint = Blueprint('base', __name__)

@base_blueprint.route('/favicon.ico', methods=['GET'])
def favicon():
    return send_from_directory(os.path.join(base_blueprint.root_path,'static'),
                               'favicon.ico',
                               mimetype='image/vnd.microsoft.icon')

@base_blueprint.route('/', methods=['GET'])
def index():
    # return standard index page
    return(render_template("index.html",
                            version=AppConfig.VERSION.value,
                            ))


@base_blueprint.route("/reset", methods=['GET'])
def reset():
    # clear all session variables and return to index
    session.clear()
    flash("Session Cleared")
    return redirect(url_for('base.index'))
