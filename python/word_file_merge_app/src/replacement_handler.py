# /src/replacement_handler.py

# system library -------------------------------------------------------------
import io
from datetime import datetime

# packages -------------------------------------------------------------------
import docx

# local library --------------------------------------------------------------
from config.document_style      import DocumentStyle
from src.sql_handler            import SqlHandler
from query.document_template    import QueryDocumentTemplate
from query.placeholder          import QueryPlaceholders
from query.replacement          import QueryReplacement

class ReplacementHandler():
    def __init__(self, template_id):
        self.query_handler          = SqlHandler()
        self.template_id:int        = template_id
        self.replacements           = None
        self._current_placeholder   = None

        self.__set_template_id(template_id=template_id)

    def __set_template_id(self, template_id:str) -> None:
        """
        Sets the template_id
        """
        if template_id is not None:
            if isinstance(template_id, (str)):
                if template_id.isnumeric():
                    template_id = int(template_id)
                else:
                    template_id = 0
            self.template_id = template_id
        else:
            self.template_id = 0
        
    def __fetch_replacements(self, template_id:int) -> list:
        """
        Fetches all replacements for a given template
        """
        # self.__set_template_id(template_id=template_id)

        qry = QueryReplacement.REPLACEMENT_SELECT
        self.replacements = self.query_handler.select_query(qry, params=[self.template_id])
        qry = None
    
    def __fetch_replacements_by_ph(self) -> list:
        """
        Fetches all replacements for a given template
        """
        qry = QueryReplacement.REPLACEMENT_SELECT_BY_PH
        self.replacements = self.query_handler.select_query(qry, params=[self._current_placeholder['placeholder_id']])
        qry = None
    
    def __special_placeholder(self) -> None:
        """
        Checks if the placeholder is a special placeholder
        """
        match self._current_placeholder['placeholder_name'].lower():
            case "current date":
                current_date = [f"{datetime.now().strftime(DocumentStyle.DATE_FORMAT.value)}"]
                self.replacements = {'replacement_id': 0, 'replacement_group': "current date", 'replacement_value': current_date[0]}
            case _ :
                self.replacements = []
    

    def fetch_template_data(self) -> list:
        """
        Fetches all placeholders for a given template
        """
        qry = QueryDocumentTemplate.DOCUMENT_SELECT_BY_ID
        document_template = self.query_handler.select_query(qry, params=[self.template_id])
        qry = None
        return document_template


    def insert_replacement(self, placeholder_name:int, replacement_group:str, replacement:str) -> None:
        """
        Inserts a replacement into the database
        """
        qry = QueryPlaceholders.PLACEHOLDER_SELECT_ID

        placeholder_id = self.query_handler.select_query(qry, params=[self.template_id, placeholder_name])
        placeholder_id = placeholder_id[0]['placeholder_id']

        qry = QueryReplacement.REPLACEMENT_INSERT

        self.query_handler.insert_query(qry,
                                        template_id=self.template_id, 
                                        placeholder_id=int(placeholder_id),
                                        replacement_group=replacement_group, 
                                        replacement_value=replacement)
        qry = None

    def delete_replacement(self, item_id:str):
        """
        Inserts a replacement into the database
        """
        qry = QueryReplacement.REPLACEMENT_DELETE_BY_ID

        self.query_handler.delete_query(qry,
                                        template_id=self.template_id,
                                        replacement_id=int(item_id)
                                        )
        qry = None

    def update_replacement(self,
                           replacement_id:str, 
                           replacement_group:str, 
                           replacement_value:str):
        """
        updates a replacement in the database
        """
        qry = QueryReplacement.REPLACEMENT_UPDATE_BY_ID

        self.query_handler.update_query(qry,
                                        template_id=self.template_id,
                                        replacement_id=int(replacement_id),
                                        replacement_group=replacement_group,
                                        replacement_value=replacement_value
                                        )

        qry = None

    def placeholder_replacements(self, placeholder:str) -> list:
        """
        Returns the placeholder replacements
        """
        # check if special placeholder
        self._current_placeholder = placeholder
        self.__special_placeholder()
        
        if not self.replacements:
            self.__fetch_replacements_by_ph()

        return self.replacements

    def selected_replacements(self, selected_item_ids:list) -> list:
        """
        Returns the selected replacements
        """
        # fetch the selected items
        query_data = self.query_handler.select_query(QueryReplacement.REPLACEMENT_SELECTED_BY_ID, params=selected_item_ids)
        
        # sort the query data in same order user selected
        replacement_data = [{'input_type':'multi','id': row[0], 'group_name': row[1], 'item_text': row[2]} for row in query_data]
        ordered_items = sorted(replacement_data,
                               key=lambda x: selected_item_ids.index(x['id'])
                               )
        return(ordered_items)
