
-- ---------------------------------------------------------------------------
-- Get the row counts from the each of the tables
-- ---------------------------------------------------------------------------
DECLARE		@table_name		Varchar(64)	= 'e'
DECLARE		@schema_name	Varchar(64) = 'dbo'

SELECT		sysschemas.name
			,sysobj.name
			,sysstats.row_count

FROM		sys.indexes AS sysindex
			INNER JOIN sys.objects as sysobj
				ON sysindex.object_id = sysobj.object_ID
			INNER JOIN sys.dm_db_partition_stats AS sysstats
				ON sysindex.object_id = sysstats.object_id
				AND sysindex.index_id = sysstats.index_id
			INNER JOIN sys.schemas AS sysschemas
				ON sysobj.schema_id = sysschemas.schema_id
WHERE		sysindex.index_id < 2
			AND sysobj.is_ms_shipped = 0
			--Specify schema names
			AND sysschemas.name LIKE  '%' + @schema_name '%'
			--Specify table names
			AND sysobj.name LIKE '%' + @table_name +'%'

ORDER BY	sysschemas.name
			,sysobj.name
;

