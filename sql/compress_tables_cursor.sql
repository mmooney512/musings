USE		ccr_galt;

BEGIN TRY
		IF OBJECT_ID('tempdb..#TableList') IS NULL
			BEGIN 
				CREATE TABLE #TableList
							([schema_name]		NVARCHAR(512)
							,[table_name]		NVARCHAR(512)
							,[table_rows]			FLOAT
							-- BEFORE
							,[before_total_space]	FLOAT
							,[before_used_space]	FLOAT
							,[before_unused_space]	FLOAT
							-- AFTER
							,[after_total_space]	FLOAT DEFAULT 0
							,[after_used_space]		FLOAT DEFAULT 0
							,[after_unused_space]	FLOAT DEFAULT 0
							-- CHANGE
							,[change_total_space]	FLOAT DEFAULT 0
							,[change_used_space]	FLOAT DEFAULT 0
							,[change_unused_space]	FLOAT DEFAULT 0
							);
			END
			IF OBJECT_ID('tempdb..#TableList') IS NOT NULL
				BEGIN
					TRUNCATE TABLE #TableList;
				END

		-- -------------------------------------------------------------------
		-- get table name and sizes
		-- -------------------------------------------------------------------
		DECLARE		@ConvertMB AS FLOAT
		SET			@ConvertMB = (8.0 / 1024.0)
		-- --------------------------------------------------------------------------------
		INSERT INTO #TableList
					([schema_name]
					,[table_name]
					,[table_rows]
					,[before_total_space]
					,[before_used_space]
					,[before_unused_space]
					)
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

		WHERE		systables.NAME NOT LIKE 'dt%' 
					AND systables.is_ms_shipped = 0
					AND sysindex.OBJECT_ID > 255 
			
					AND systables.name IN 
					('P_2015_05_01_Depr_By_MUN','R_2015_07_03_Depr_By_MUN','W_2015_10_31_Depr_By_MUN'
					,'U_2015_08_28_Depr_By_MUN','Q_2015_05_29_Depr_By_MUN'
					,'V_2015_10_02_Depr_By_MUN','S_2015_07_31_Depr_By_MUN','B_2014_03_28_Depr_By_Outlet'
					,'V_2015_10_02_Depr_By_Outlet_qtrly','O_2015_04_03_Depr_By_Outlet_qtrly'
					,'Y_2015_12_31_Depr_By_MUN','X_2015_11_27_Depr_By_MUN','Q_2015_05_29_SourceData_Volume_GLCC'
					,'R_2015_07_03_Depr_By_Outlet_qtrly','Y_2015_12_31_Depr_By_Outlet_qtrly'
					,'Q_2015_05_29_SourceData_Volume_CCBF','V_2015_10_02_SourceFormat_Replacement_all'
					,'Y_2015_12_31_SourceFormat_Replacement','AA_2016_01_29_SourceFormat_Replacement'
					,'X_2015_11_27_SourceFormat_Replacement'
					,'AB_2016_02_26_SourceFormat_Replacement','E_2014_05_23_SourceData_Service_CurrentMonth'
					,'E_2014_05_23_SourceData_Volume_CurrentMonth','P_2015_05_01_SourceData_MRC'
					)

		GROUP BY	systables.name, sysschema.name, syspartitions.rows	


		DECLARE		@main_cursor	AS CURSOR;
		DECLARE		@schema_name	AS NVARCHAR(512);
		DECLARE		@table_name		AS NVARCHAR(512);
		DECLARE		@sql_command	AS NVARCHAR(MAX);

		DECLARE		@after_total_space		AS FLOAT = 0.0001
		DECLARE		@after_used_space		AS FLOAT = 0.0001
		DECLARE		@after_unused_space		AS FLOAT = 0.0001

		-- set the cursor
		SET			@main_cursor = CURSOR FOR
		SELECT		TOP 1000
					tli.[schema_name]
					,tli.[table_name]
		FROM		#TableList AS tli		
		;
		-- -------------------------------------------------------------------
		-- Loop through the schema and table names and store results in the temp table
		-- -------------------------------------------------------------------
		OPEN	@main_cursor;

		FETCH	NEXT FROM	@main_cursor INTO 
				@schema_name
				,@table_name
				;

		WHILE	@@FETCH_STATUS = 0
				BEGIN
					PRINT 'REBUILDING : ' +  @schema_name + '.' + @table_name
					-- build the query
					SET @sql_command =	N'ALTER TABLE '
										+ @schema_name + '.' + @table_name
										+ ' REBUILD WITH (DATA_COMPRESSION = PAGE) ;'
					-- run the query
					EXECUTE	sp_executesql @sql_command

					SELECT		@after_total_space		= ROUND(CAST(SUM(sysalloc.total_pages) * (@ConvertMB) AS FLOAT),2)
								,@after_used_space		= ROUND(CAST(SUM(sysalloc.used_pages)  * @ConvertMB AS FLOAT),2)
								,@after_unused_space	= ROUND(CAST((SUM(sysalloc.total_pages) - SUM(sysalloc.used_pages)) 
														* @ConvertMB AS FLOAT),2)
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

					WHERE		systables.NAME NOT LIKE 'dt%' 
								AND systables.is_ms_shipped = 0
								AND sysindex.OBJECT_ID > 255 
								AND sysschema.name = @schema_name	
								AND systables.name = @table_name

					-- update change numbers
					UPDATE		tli
					SET			[after_total_space]		= @after_total_space
								,[after_used_space]		= @after_used_space
								,[after_unused_space]	= @after_unused_space

								,[change_total_space]	= [before_total_space]	- @after_total_space
								,[change_used_space]	= [before_used_space]	- @after_used_space	
								,[change_unused_space]	= [before_unused_space]	- @after_unused_space
					FROM		#TableList AS tli
					;

					-- get next table and field name
					FETCH	NEXT FROM	@main_cursor INTO 
							@schema_name
							,@table_name
							;
				END

		-- print out results
		SELECT		TOP 1000
					tli.*
		FROM		#TableList AS tli
		ORDER BY	tli.[schema_name]
					,tli.[table_name]

END TRY
-- ---------------------------------------------------------------------------
-- Print out the error messages
-- ---------------------------------------------------------------------------
BEGIN CATCH
		SELECT		ERROR_NUMBER() AS ErrorNumber
					,ERROR_SEVERITY() AS ErrorSeverity
					,ERROR_STATE() AS ErrorState
					,ERROR_PROCEDURE() AS ErrorProcedure
					,ERROR_LINE() AS ErrorLine
					,ERROR_MESSAGE() AS ErrorMessage;

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;	