# /query / document_template.py

class QueryDocumentTemplate():
    # version
    DOCUMENT_INSERT ="""
        INSERT INTO template
        (template_name, template_file, deleted)
        VALUES (?, ?, 0)
        ;
        """
    DOCUMENT_SELECT ="""
        SELECT template_id, template_name, template_file
        FROM template
        WHERE template_name = ?
        AND deleted = 0
        ;
        """
    
    DOCUMENT_SELECT_BY_ID ="""
        SELECT template_id, template_name, template_file
        FROM template
        WHERE template_id = ?
        AND deleted = 0
        ;
        """
    
    DOCUMENT_SELECT_ALL ="""
        SELECT template_id, template_name
        FROM template
        WHERE deleted = 0
        ;
        """
        
    DOCUMENT_UPDATE ="""
        UPDATE template
        SET template_file = ?
        WHERE template_name = ?
        AND deleted = 0
    """
