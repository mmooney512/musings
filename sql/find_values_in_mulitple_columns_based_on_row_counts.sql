USE				DW_Staging_MXP;
--USE			DW_ODS_MXP;
GO

DECLARE		@max_row_count		AS INT
DECLARE		@search_columns		AS NVARCHAR(512);
DECLARE		@search_value		AS NVARCHAR(512);
DECLARE		@search_datatype	AS NVARCHAR(32); 

SET			@max_row_count		= 1000000
SET			@search_columns		= '%'
SET			@search_value		= CHAR(39) + '%G01%' + CHAR(39)
SET			@search_datatype	= 'varchar'
--SET			@search_value		= 10225873
--SET			@search_datatype	= 'int'

BEGIN TRY
	DROP TABLE IF EXISTS #column_list;

	CREATE TABLE #column_list
	(
		table_schema			NVarchar(512)	NOT NULL
		, table_name			NVARCHAR(512)	NOT NULL
		, ordinal_position		INT				NOT NULL
		, column_name			NVARCHAR(512)	NOT NULL
		, data_type				NVARCHAR(512)	NOT NULL
		, max_length			INT					NULL
		, column_default		NVARCHAR(512)		NULL
		, is_nullable			NVARCHAR(8)			NULL
		, values_found			INT					NULL
		, sql_command			NVarchar(4000)		NULL
	);

		-- find the columns that will be searched
		INSERT INTO		#column_list
						(table_schema, table_name	,ordinal_position ,column_name 
						,data_type	,max_length	,column_default ,is_nullable)

		SELECT			infocolumns.TABLE_SCHEMA
						, infocolumns.table_name
						, infocolumns.ordinal_position
						, infocolumns.column_name
						, infocolumns.data_type
						, infocolumns.character_maximum_length
						, infocolumns.column_default
						, infocolumns.is_nullable

		FROM			INFORMATION_SCHEMA.COLUMNS AS infocolumns
						-- exclude views
						LEFT OUTER JOIN INFORMATION_SCHEMA.VIEWS AS infoviews
							ON	infocolumns.TABLE_SCHEMA = infoviews.TABLE_SCHEMA
							AND infocolumns.TABLE_NAME = infoviews.TABLE_NAME
						
						-- join to get the row counts
						INNER JOIN
						(SELECT		systables.name						AS TableName
									,sysschema.name						AS SchemaName
									,syspartitions.rows					AS RowCounts
							
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
										AND syspartitions.rows	BETWEEN 1 AND @max_row_count
							GROUP BY	systables.name, sysschema.name, syspartitions.rows	
						) AS table_sizes
							ON	infocolumns.TABLE_SCHEMA = table_sizes.SchemaName
							AND infocolumns.TABLE_NAME = table_sizes.TableName
							

		WHERE			infoviews.TABLE_NAME IS NULL -- exclude views
						AND infocolumns.column_name LIKE @search_columns
						AND infocolumns.data_type = @search_datatype
						AND infocolumns.TABLE_SCHEMA NOT IN ('log', 'history')
						AND infocolumns.COLUMN_NAME <> 'ROW_COUNTER'
		
		
		;


		-- -------------------------------------------------------------------
		-- set the cursor
		-- -------------------------------------------------------------------

		DECLARE		@main_cursor		AS CURSOR;
		DECLARE		@table_schema		AS NVarchar(512);
		DECLARE		@table_name			AS NVARCHAR(512);
		DECLARE		@column_name		AS NVARCHAR(512);
		DECLARE		@sql_command		AS NVARCHAR(MAX);
		DECLARE		@result_rows		AS INT;

		SET			@main_cursor = CURSOR FOR 
		SELECT		DISTINCT 
					c_li.table_schema
					,c_li.table_name
					,c_li.column_name
		FROM		#column_list AS c_li
		ORDER BY	1,2
		;
		-- -------------------------------------------------------------------
		-- Loop through the table and columns names and store results in the temp table
		-- -------------------------------------------------------------------

		OPEN		@main_cursor;

		FETCH		NEXT FROM @main_cursor INTO
					@table_schema
					,@table_name
					,@column_name
					;

		WHILE		@@FETCH_STATUS = 0
					BEGIN	-- begin while loop
						PRINT 'SEARCHING: ' + @table_schema + '.' + @table_name + '.' + @column_name
					
						SET @sql_command = N' SELECT	@result_rows = COUNT(*)' +
											' FROM  ' + @table_schema +'.'+ @table_name + 
											' WHERE ' + @column_name + ' LIKE ' + @search_value +';'
						
						PRINT @sql_command
						EXECUTE sp_executesql @sql_command, N'@result_rows INT OUTPUT' ,@result_rows OUTPUT
					
						-- UPDATE Temp Table
						UPDATE	#column_list
								SET values_found	= @result_rows
									, sql_command	= REPLACE(@sql_command, '@result_rows = COUNT(*)', '*')
						WHERE	table_schema		= @table_schema
								AND table_name		= @table_name
								AND column_name		= @column_name
						;
						
						-- get the next row
						FETCH		NEXT FROM @main_cursor INTO
									@table_schema
									,@table_name
									,@column_name
									;
					
					END		-- end while loop

END TRY


-- -----------------------------------------------------------------------
-- standard error handler
-- -----------------------------------------------------------------------
BEGIN CATCH
	--ROLLBACK TRANSACTION @current_transaction;
	-- Execute the error retrieval routine.
		SELECT 
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() as ErrorState,
		ERROR_PROCEDURE() as ErrorProcedure,
		ERROR_LINE() as ErrorLine,
		ERROR_MESSAGE() as ErrorMessage;
END CATCH;

SELECT		*
FROM		#column_list
WHERE		values_found > 0
ORDER BY	1,2
;

