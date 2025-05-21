# /query / replacement.py

class QueryReplacement():
    # version
    REPLACEMENT_INSERT ="""
        INSERT INTO replacement
        (template_id, placeholder_id, replacement_group, replacement_value)

        SELECT    :template_id, :placeholder_id, :replacement_group, :replacement_value

        EXCEPT

        SELECT template_id, placeholder_id, replacement_group, replacement_value
        FROM replacement
        WHERE template_id       = :template_id
        AND placeholder_id      = :placeholder_id
        AND replacement_group   = :replacement_group
        AND replacement_value   = :replacement_value
        and deleted = 0
        ;
        """

    REPLACEMENT_SELECT ="""
        SELECT    placeholder.placeholder_id
                , placeholder.placeholder_type 
                , placeholder.placeholder_name
                , replacement.replacement_id
                , replacement.replacement_group
                , replacement.replacement_value
        FROM placeholder  
        INNER JOIN replacement
        ON replacement.placeholder_id = placeholder.placeholder_id
        WHERE template_id = ?
        ;
        """

    REPLACEMENT_SELECT_BY_PH ="""
        SELECT replacement.replacement_id
                , replacement.replacement_group
                , replacement.replacement_value
        FROM replacement
        WHERE placeholder_id = ?
              AND deleted = 0
        ORDER BY replacement.replacement_group
                , replacement.replacement_value
        ;
        """

    REPLACEMENT_SELECTED_BY_ID ="""
        SELECT replacement.replacement_id
                , replacement.replacement_group
                , replacement.replacement_value
        FROM replacement
        WHERE replacement_id in ({})
        """
    
    REPLACEMENT_DELETE_BY_ID ="""
        UPDATE replacement
        SET    deleted = 1
        WHERE template_id = :template_id
            AND replacement_id = :replacement_id
        ;
        """


    REPLACEMENT_UPDATE_BY_ID ="""
        UPDATE replacement
        SET replacement_group = :replacement_group
            , replacement_value = :replacement_value
        WHERE template_id = :template_id
            AND replacement_id  = :replacement_id
        ;
        """
