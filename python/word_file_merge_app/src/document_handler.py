# /src/document_handler.py

# system library -------------------------------------------------------------
import io, re

# packages -------------------------------------------------------------------
import docx
import docx.document

# local library --------------------------------------------------------------
from src.sql_handler            import SqlHandler
from query.document_template    import QueryDocumentTemplate
from query.placeholder          import QueryPlaceholders
from query.generated_file       import QueryGeneratedFile

class DocumentHandler:
    def __init__(self, filename:str=None):
        self.filename:str                       = filename
        self.file_data:bytes                    = None
        self.placeholders:list                  = None
        self.query_handler:SqlHandler           = SqlHandler()
        self.template_id:int                    = None
        self.template_exists:bool               = False
        self.valid_placeholders:bool            = False
 
    def __insert_file_into_database(self) -> None:
        """
        Inserts a file into the database
        """
        qry = QueryDocumentTemplate.DOCUMENT_INSERT

        # insert the file into the database
        self.query_handler.insert_query(qry, self.filename, self.file_data)
        self.template_id = self.query_handler.GetLastId()
        qry = None

    def __update_file_into_database(self) -> None:
        qry = QueryDocumentTemplate.DOCUMENT_UPDATE

        # update the file data in the database
        self.query_handler.update_query(qry, self.file_data, self.filename)
        qry = None

    def __extract_placeholders_from_docx(self) -> None:
        """
        Extracts placeholders from a docx file
        """
        doc = docx.Document(io.BytesIO(self.file_data))
        placeholders = []
        position = 0
        placeholder_pattern = re.compile(r"\{\{(.*?)\}\}")

        for para in doc.paragraphs:
            matches = placeholder_pattern.findall(para.text)
            for match in matches:
                match_strip = match.strip()
                # check if the placeholder already exists in the list
                if not any(match_strip == item[0] for item in placeholders):
                        placeholders.append((match_strip, position))
                        position += 1
        
        if len(placeholders) > 0:
            self.placeholders = placeholders
            self.valid_placeholders = True
    
    def __store_placeholders_in_database(self) -> None:
        """
        Store the placeholders in the database
        """
        qry = QueryPlaceholders.PLACEHOLDER_INSERT

        # insert the file into the database
        for placeholder, position in self.placeholders:
            self.query_handler.insert_query(qry, self.template_id, placeholder, position,
                                            self.template_id, placeholder,
                                            )
        qry = None
    
    def __template_exists(self) -> bool:
        """
        Check if the template already exists
        """
        # insert the file into the database
        rows = self.query_handler.select_query(user_query=QueryDocumentTemplate.DOCUMENT_SELECT,
                                               params=[self.filename])
        
        if len(rows) > 0:
            self.template_id = rows[0][0]
            self.template_exists = True

    def process_docx(self, file_data:bytes) -> None:
        """
        Process a docx file
        
        Parameters
        ----------
        file_data: bytes
            Contents of the word document user has sent 
            via a POST request
        """
        self.file_data = file_data
        # check if the template exists
        self.__template_exists()
        
        # even if the template exists, the names of the placeholders 
        # may have changed
        self.__extract_placeholders_from_docx()

        # check if the template has valid placeholders and if the template exists
        # if the template does not exist, insert it into the database
        if self.valid_placeholders and self.template_exists == False:
            self.__insert_file_into_database()
        else:
            self.__update_file_into_database()

        # if the template has valid placeholders, insert them into the database
        if self.valid_placeholders:
            self.__store_placeholders_in_database()


    def retrieve_word_document(self, generated_file_id:int):
        """
        return the requested generated word file from the database

        ------
        Returns file_name:str, docx.Document:bytes
        """
        # output_stream = io.BytesIO()
        # doc.save(output_stream)
        # output_stream.seek(0)

        qry = QueryGeneratedFile.FILE_SELECT_BY_ID
        generated_document_data = self.query_handler.select_query(qry, params=[generated_file_id])
        qry = None
        
        if generated_document_data:
            for row in generated_document_data:
                db_file = row['generated_file']
                byte_io = io.BytesIO(db_file)
                return(row['generated_file_name'], byte_io)
        