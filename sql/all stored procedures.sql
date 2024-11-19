SELECT		  sys_objects.[name]				sp_Name
			, sys_sql_modules.definition		sp_Definition

FROM		sys.objects							AS sys_objects
			INNER JOIN	sys.sql_modules			AS sys_sql_modules
            on sys_objects.object_id			= sys_sql_modules.object_id

WHERE		--sys_indexes.index_id				< 2
			sys_objects.is_ms_shipped		= 0
			AND sys_objects.[type]				= 'p'	-- stored procedures
			AND sys_sql_modules.execute_as_principal_id IS NULL
;

