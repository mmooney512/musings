# /query / placeholder.py

class QueryPlaceholders():
    # version
    PLACEHOLDER_INSERT ="""
        INSERT INTO placeholder
        (template_id, placeholder_name, placeholder_order, deleted)

        SELECT	?, ?, ?, 0

        EXCEPT

        SELECT template_id, placeholder_name, placeholder_order, deleted
        FROM placeholder
        WHERE template_id = ?
        AND placeholder_name = ?
        AND deleted = 0
        ;
        """
    
    PLACEHOLDER_SELECT ="""
        SELECT placeholder_id,
                template_id,
                placeholder_type,
                placeholder_name
        FROM placeholder
        WHERE template_id = ?
        AND deleted = 0
        ORDER BY placeholder_order
        ;
        """
    
    PLACEHOLDER_SELECT_ID ="""
        SELECT placeholder_id
        FROM placeholder
        WHERE template_id = ?
        AND placeholder_name = ?
        AND deleted = 0
        ORDER BY placeholder_order
        LIMIT 1
        ;
        """
    
    PLACEHOLDER_UPDATE_TYPE ="""
        UPDATE placeholder
        SET placeholder_type = ?
        WHERE placeholder_id = ?
        AND deleted = 0
        ;
        """
    