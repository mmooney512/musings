
DECLARE			@Table_or_View_Name Varchar(255) = 'VW_%'
SELECT			sys_all_objects.[Name]
				, sys_all_columns.column_id
				, sys_all_columns.[name]		AS ColumnName
				, sys_types.[name]			AS DataType
				, sys_all_columns.max_length AS Length
				, sys_types.[Precision]
				, sys_types.Scale
			
FROM			sys.all_objects sys_all_objects
				INNER JOIN sys.all_columns sys_all_columns
				ON sys_all_objects.object_id = sys_all_columns.object_id
				INNER JOIN sys.types sys_types
				ON sys_all_columns.user_type_id=sys_types.user_type_id
				
WHERE			sys_all_objects.[Name] LIKE @Table_or_View_Name
				AND sys_all_objects.[type] IN ('U','V')
ORDER BY		sys_all_objects.[Name]
				,sys_all_columns.column_id
;
