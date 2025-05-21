# main.py

# system library --------------------------------------------------------------
import os, sys

# local library --------------------------------------------------------------
from    config.flask_app    import FlaskOptions
import  word_file_app


def main(argv:list) -> None:
    web_port = FlaskOptions.API_PORT_PROD.value
    # create the flask app
    app = word_file_app.create_application(
        app_name=__name__
    )

    app.run(host='127.0.0.1', port=web_port,debug=True)

if __name__ == '__main__':
    main(sys.argv[1:])
