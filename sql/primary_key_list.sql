USE BI_Analytics;
SELECT		SCHEMA_NAME(tab.schema_id)	AS [schema_name]
			, pk.[name]					AS pk_name
			, ic.index_column_id		AS column_id
			, col.[name]				AS column_name
			, tab.[name]				AS table_name
from		sys.tables tab
			INNER join sys.indexes pk
				ON tab.object_id = pk.object_id 
				AND pk.is_primary_key = 1
			INNER join sys.index_columns ic
				ON ic.object_id = pk.object_id
				AND ic.index_id = pk.index_id
			INNER join sys.columns col
				ON pk.object_id = col.object_id
				AND col.column_id = ic.column_id
order by	schema_name(tab.schema_id)
			, pk.[name]
			, ic.index_column_id