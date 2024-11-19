USE BI_Analytics;

SELECT			  SCHEMA_NAME(sys_objects.[schema_id])			AS schema_nm
				, sys_objects.[name]							AS table_name
				, sys_partitions.[rows]							AS row_count

FROM			sys.objects		sys_objects
				INNER JOIN sys.indexes sys_indexes
					ON sys_objects.object_id = sys_indexes.object_id
				INNER JOIN sys.partitions	sys_partitions
					ON sys_objects.object_id = sys_partitions.object_id
					AND	sys_indexes.index_id = sys_partitions.index_id
WHERE			sys_objects.[type] = 'U'
				AND sys_objects.is_ms_shipped = 0x0
				AND sys_indexes.object_id > 255
				AND sys_indexes.index_id <= 1
				AND SCHEMA_NAME(sys_objects.[schema_id]) LIKE '%Taleo%'
				
ORDER BY		schema_nm
				, table_name

USE BI_ETL;

SELECT			  SCHEMA_NAME(sys_objects.[schema_id])			AS schema_nm
				, sys_objects.[name]							AS table_name
				, sys_partitions.[rows]							AS row_count

FROM			sys.objects		sys_objects
				INNER JOIN sys.indexes sys_indexes
					ON sys_objects.object_id = sys_indexes.object_id
				INNER JOIN sys.partitions	sys_partitions
					ON sys_objects.object_id = sys_partitions.object_id
					AND	sys_indexes.index_id = sys_partitions.index_id
WHERE			sys_objects.[type] = 'U'
				AND sys_objects.is_ms_shipped = 0x0
				AND sys_indexes.object_id > 255
				AND sys_indexes.index_id <= 1
				AND SCHEMA_NAME(sys_objects.[schema_id]) LIKE '%Taleo%'
				
ORDER BY		schema_nm
				, table_name



USE BI_Analytics;

SELECT			  SCHEMA_NAME(sys_objects.[schema_id])			AS schema_nm
				, sys_objects.[name]							AS table_name
				, sys_partitions.[rows]							AS row_count

FROM			sys.objects		sys_objects
				INNER JOIN sys.indexes sys_indexes
					ON sys_objects.object_id = sys_indexes.object_id
				INNER JOIN sys.partitions	sys_partitions
					ON sys_objects.object_id = sys_partitions.object_id
					AND	sys_indexes.index_id = sys_partitions.index_id
WHERE			sys_objects.[type] = 'U'
				AND sys_objects.is_ms_shipped = 0x0
				AND sys_indexes.object_id > 255
				AND sys_indexes.index_id <= 1
				AND SCHEMA_NAME(sys_objects.[schema_id]) LIKE '%Taleo%'
				
ORDER BY		schema_nm
				, table_name
;

USE BI_ETL;

SELECT			  SCHEMA_NAME(sys_objects.[schema_id])			AS schema_nm
				, sys_objects.[name]							AS table_name
				, sys_partitions.[rows]							AS row_count

FROM			sys.objects		sys_objects
				INNER JOIN sys.indexes sys_indexes
					ON sys_objects.object_id = sys_indexes.object_id
				INNER JOIN sys.partitions	sys_partitions
					ON sys_objects.object_id = sys_partitions.object_id
					AND	sys_indexes.index_id = sys_partitions.index_id
WHERE			sys_objects.[type] = 'U'
				AND sys_objects.is_ms_shipped = 0x0
				AND sys_indexes.object_id > 255
				AND sys_indexes.index_id <= 1
				AND SCHEMA_NAME(sys_objects.[schema_id]) LIKE '%Taleo%'
				
ORDER BY		schema_nm
				, table_name
;
