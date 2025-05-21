# /config / document_style.py

# system library --------------------------------------------------------------
from enum import Enum

class DocumentStyle(Enum):
    # DOCUMENT
    TEMPLATE_NAME           = 'word_documents/cl_template.docx'
    OUTPUT_DIRECTORY_WORD   = 'download'
    OUTPUT_DIRECTORY_PDF    = 'download'
    OUTPUT_FILE_NAME        = '_FileName_'
    OUTPUT_FILE_PREFIX      = 'output_prefix'
    OUTPUT_FILE_USE_PLACEHOLDER_VALUE   = True
    OUTPUT_FILE_PLACEHOLDER_TO_USE      = 'Company Name'

    # DATE FORMAT
    DATE_FORMAT             = '%d %B %Y'
    FILENAME_DATE_FORMAT    = '%Y-%m-%d'

    # PAGE LAYOUT
    PAGE_MARGIN_TOP         = 0.75
    PAGE_MARGIN_BOTTOM      = 0.50
    PAGE_MARGIN_LEFT        = 0.75
    PAGE_MARGIN_RIGHT       = 0.75

    # PARAGRAPH LAYOUT
    PARAGRAPH_FONT_NAME     = 'Times New Roman'
    PARAGRAPH_FONT_POINT    = 12

    # PARAGRAPH BULLET
    BULLET_FONT_NAME        = 'Times New Roman'
    BULLET_FONT_POINT       = 12
    BULLET_STYLE            = 'List Bullet 2'
    BULLET_CHARACTER        = '-'

    # PARAGRAPH
    CL_P_BREAK              = "\n"