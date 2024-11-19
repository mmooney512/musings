USE				DW_Staging;

SELECT			 infocolumns.table_schema
				,infocolumns.table_name
				--,infoTables.table_type
				,infocolumns.ordinal_position 
				,infocolumns.column_name 
				,infocolumns.data_type
				,infocolumns.character_maximum_length
				,infocolumns.column_default 
				,infocolumns.is_nullable

FROM			INFORMATION_SCHEMA.COLUMNS AS infocolumns
				INNER JOIN INFORMATION_SCHEMA.TABLES AS infoTables
					ON infocolumns.TABLE_NAME = infoTables.TABLE_NAME
					AND infocolumns.TABLE_SCHEMA = infoTables.TABLE_SCHEMA

WHERE			-- infoTables.TABLE_TYPE = '%%'
				-- infocolumns.column_name LIKE '%D%'
				infocolumns.TABLE_NAME LIKE '%%'
				-- infocolumns.DATA_TYPE LIKE '%%'
				AND infocolumns.TABLE_SCHEMA = 'dbo'
				
ORDER BY		infocolumns.table_name,
				infocolumns.ordinal_position
;
