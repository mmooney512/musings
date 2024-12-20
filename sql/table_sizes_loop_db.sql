DECLARE		@loop_counter	INT				= 1;
DECLARE		@db_count		INT				= 0;
DECLARE		@db_name		varchar(255)	= '';
DECLARE		@sql_use		varchar(4000)	= '';
DECLARE		@ConvertMB		AS FLOAT		= (8.0 / 1024.0);

IF OBJECT_ID('tempdb..#db_table_size') IS NOT NULL
	BEGIN
		DROP TABLE #db_table_size;
	END

CREATE TABLE	#db_table_size
				( UserDBName		varchar(255)
				, SchemaName		varchar(255)
				, TableName			varchar(255)
				, RowCounts			bigint
				, TotalSpaceMB		float
				, UsedSpaceMB		float
				, UnusedSpaceMB		float
				)

DECLARE		@cte_dbnames 
			TABLE (db_rownum INT, user_db_name VARCHAR(4000))
;


INSERT INTO @cte_dbnames(db_rownum, user_db_name)

SELECT		  ROW_NUMBER() OVER (ORDER BY [name])	db_rownum
			, [name]								user_db_name
FROM		sys.databases
WHERE		[name] NOT IN ('master', 'tempdb', 'model', 'msdb')
			AND [state_desc] = 'ONLINE'
;



SET		@db_count = 
			(
			SELECT		COUNT(*)
			FROM		@cte_dbnames
			)

--select		@db_count;

WHILE		@loop_counter <= @db_count
BEGIN
			SELECT @db_name =
			(
					SELECT		user_db_name
					FROM		@cte_dbnames
					WHERE		db_rownum = @loop_counter
			)
			-- ---------------------------------------------------------------
			SET		@sql_use = 'USE [' + @db_name + '];';
			EXEC	(@sql_use);
			-- ---------------------------------------------------------------

			INSERT INTO #db_table_size
			SELECT		@db_name							AS UserDBName
						,sysschema.name						AS SchemaName
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

			WHERE		systables.is_ms_shipped = 0
						AND sysindex.OBJECT_ID > 255 
						--AND systables.NAME  LIKE 'USM_%'

			
			GROUP BY	systables.name, sysschema.name, syspartitions.rows	

			ORDER BY	SchemaName, TableName
			;

			SET @loop_counter = @loop_counter + 1;

END


SELECT		UserDBName
			, SchemaName			
			, TableName			
			, RowCounts			
			, TotalSpaceMB		
			, UsedSpaceMB		
			, UnusedSpaceMB		
FROM		#db_table_size
ORDER BY	  UserDBName
			, [SchemaName]
			, TableName
;

DROP TABLE	#db_table_size;



select 