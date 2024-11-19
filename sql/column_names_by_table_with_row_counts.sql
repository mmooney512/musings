-- ---------------------------------------------------------------------------
-- find column names and row counts
-- ---------------------------------------------------------------------------
SELECT			  infocolumns.table_schema
				, infocolumns.table_name
				, infocolumns.ordinal_position 
				, infocolumns.column_name 
				, infocolumns.data_type
				, infocolumns.character_maximum_length
				, infocolumns.column_default 
				, infocolumns.is_nullable
				, table_counts.row_count

FROM			INFORMATION_SCHEMA.COLUMNS AS infocolumns
				INNER JOIN
				(
					SELECT		sysschemas.name			AS table_schema								
								,sysobj.name			AS table_name
								,sysstats.row_count		AS row_count

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
				) AS table_counts
				ON	infocolumns.table_schema	= table_counts.table_schema
				AND infocolumns.table_name		= table_counts.table_name

--WHERE			infocolumns.column_name LIKE '%ref_num%'
--				AND table_counts.row_count > 0

ORDER BY		infocolumns.table_name,
				infocolumns.ordinal_position