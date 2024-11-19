SELECT			obj.NAME	AS FK_NAME
				, sch.NAME	AS [schema_name]
				, tab1.NAME AS [table]
				, col1.NAME AS [column]
				, tab2.NAME AS [referenced_table]
				, col2.NAME AS [referenced_column]

FROM			sys.foreign_key_columns fkc
				INNER JOIN	sys.objects				obj
				ON obj.OBJECT_ID = fkc.constraint_object_id

				INNER JOIN	sys.tables				tab1
				ON tab1.OBJECT_ID = fkc.parent_object_id

				INNER JOIN	sys.schemas				sch
				ON tab1.SCHEMA_ID = sch.SCHEMA_ID

				INNER JOIN	sys.COLUMNS				col1
				ON col1.column_id = parent_column_id
				   AND	col1.OBJECT_ID = tab1.OBJECT_ID

				INNER JOIN	sys.tables				tab2
				ON tab2.OBJECT_ID = fkc.referenced_object_id

				INNER JOIN	sys.COLUMNS				col2
				ON col2.column_id = referenced_column_id
				   AND	col2.object_id = tab2.object_id

WHERE			obj.name LIKE '%FK_booking_payment_payment_method%'
;
