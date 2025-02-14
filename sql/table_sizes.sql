-- --------------------------------------------------------------------------------
--USE			Sandbox;
DECLARE		@ConvertMB AS FLOAT
SET			@ConvertMB = (8.0 / 1024.0)
-- --------------------------------------------------------------------------------

SELECT		sysschema.name						AS SchemaName
			,systables.name						AS TableName
			,syspartitions.rows					AS RowCounts

			,ROUND(CAST(SUM(sysalloc.total_pages) * (@ConvertMB) AS FLOAT),2)	AS TotalSpaceMB
			,ROUND(CAST(SUM(sysalloc.used_pages)  * @ConvertMB AS FLOAT),2)		AS UsedSpaceMB
			,ROUND(CAST((SUM(sysalloc.total_pages) - SUM(sysalloc.used_pages)) 
			* @ConvertMB AS FLOAT),2)				AS UnusedSpaceMB
		
FROM		sys.tables AS  systables
			INNER JOIN	sys.indexes AS sysindex 
				ON systables.OBJECT_ID = sysindex.object_id
			INNER JOIN sys.partitions AS syspartitions 
				ON sysindex.object_id = syspartitions.OBJECT_ID 
				AND sysindex.index_id = syspartitions.index_id
			INNER JOIN sys.allocation_units AS sysalloc 
				ON syspartitions.partition_id = sysalloc.container_id
			LEFT OUTER JOIN sys.schemas AS sysschema 
				ON systables.schema_id = sysschema.schema_id

WHERE		systables.NAME  LIKE 'USM_%'
			AND systables.is_ms_shipped = 0
			AND sysindex.OBJECT_ID > 255 

			
GROUP BY	systables.name, sysschema.name, syspartitions.rows	

ORDER BY	SchemaName, TableName
