# /query / generated_file.py

class QueryGeneratedFile():
    # version
    FILE_INSERT ="""
        INSERT INTO generated
        (template_id, generated_file_name, generated_file_type, generated_file, deleted)
        VALUES (?, ?, ?, ?, 0)
        ;
        """
    
    FILE_SELECT_BY_ID ="""
        SELECT  generated.generated_id
                , generated.template_id
                , template.template_name
                , generated.generated_file_name
                , generated.generated_file
        FROM    generated 
        
        LEFT JOIN template
        ON template.template_id = generated.template_id
        
        WHERE   generated.generated_id = ?
                AND generated.deleted = 0
        LIMIT   1
        ;
        """
    
    FILE_SELECT_BY_TEMPLATE_ID ="""
        SELECT  generated.generated_id
                , generated.template_id
                , template.template_name
                , generated.generated_file
        FROM    generated 
        
        LEFT JOIN template
        ON template.template_id = generated.template_id
        
        WHERE   generated.template_id = ?
                AND generated.deleted = 0
        LIMIT   1
        ;
        """