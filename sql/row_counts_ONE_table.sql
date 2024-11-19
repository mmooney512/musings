USE stg_staging

GO
-- ---------------------------------------------------------------------------
-- Get the row counts from the each of the tables
-- ---------------------------------------------------------------------------
SELECT		sysobj.name
			,sysstats.row_count

FROM		sys.indexes AS sysindex
			INNER JOIN sys.objects AS sysobj
				ON sysindex.object_id = sysobj.object_ID
			INNER JOIN sys.dm_db_partition_stats AS sysstats
				ON sysindex.object_id = sysstats.object_id
				AND sysindex.index_id = sysstats.index_id
WHERE		sysindex.index_id < 2
			AND sysobj.is_ms_shipped = 0
			--Specify table names
			--AND sysobj.name IN ('')
			
ORDER BY	sysobj.name
