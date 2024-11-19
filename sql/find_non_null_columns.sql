USE		AllUserDataReplica;


BEGIN TRY
	-- truncate table if it exists
	IF OBJECT_ID('tempdb..#column_list') IS NOT NULL
		BEGIN
			TRUNCATE TABLE #column_list;
		END
	ELSE
		-- if table doesn't exist create it
		BEGIN
			CREATE TABLE #column_list
			(	table_schema			NVARCHAR(512)	NOT NULL
				, table_name			NVARCHAR(512)	NOT NULL
				, ordinal_position		INT				NOT NULL
				, column_name			NVARCHAR(512)	NOT NULL
				, data_type				NVARCHAR(512)	NOT NULL
				, max_length			INT					NULL
				, column_default		NVARCHAR(512)		NULL
				, is_nullable			NVARCHAR(8)			NULL
				, values_found			INT					NULL
			)
		END

		-- find the columns that will be searched
		INSERT INTO		#column_list
						(table_schema,	table_name	,ordinal_position ,column_name 
						,data_type	,max_length	,column_default ,is_nullable)

		SELECT			TOP 250
						infocolumns.table_schema
						, infocolumns.table_name
						, infocolumns.ordinal_position
						, infocolumns.column_name
						, infocolumns.data_type
						, infocolumns.character_maximum_length
						, infocolumns.column_default
						, infocolumns.is_nullable
						
		FROM			INFORMATION_SCHEMA.COLUMNS AS infocolumns
						-- exclude viewa
						LEFT OUTER JOIN INFORMATION_SCHEMA.VIEWS AS infoviews
							ON	infocolumns.TABLE_SCHEMA = infoviews.TABLE_SCHEMA
							AND infocolumns.TABLE_NAME = infoviews.TABLE_NAME

		WHERE			infoviews.TABLE_NAME IS NULL -- exclude views
						AND infocolumns.TABLE_NAME IN
							('OperationsAllUserData'
							)
		;

		-- -------------------------------------------------------------------
		-- set the cursor
		-- -------------------------------------------------------------------
		DECLARE		@main_cursor		AS CURSOR;
		DECLARE		@schema_name		AS NVARCHAR(512);
		DECLARE		@table_name			AS NVARCHAR(512);
		DECLARE		@column_name		AS NVARCHAR(512);
		DECLARE		@sql_command		AS NVARCHAR(4000);
		DECLARE		@result_rows		AS INT;

		SET			@main_cursor = CURSOR FOR 
		SELECT		DISTINCT 
					c_li.table_schema
					, c_li.table_name
					, c_li.column_name
		FROM		#column_list AS c_li
		ORDER BY	1,2
		;

		-- -------------------------------------------------------------------
		-- Loop through the table and columns names and store results in the temp table
		-- -------------------------------------------------------------------
		OPEN		@main_cursor;

		FETCH		NEXT FROM @main_cursor INTO
					@schema_name
					, @table_name
					, @column_name
					;

		WHILE		@@FETCH_STATUS = 0
					BEGIN	-- begin while loop
					PRINT 'SEARCHING: ' + @table_name + '.' + @column_name

					-- update the query
					SET		@sql_command = N' SELECT	@result_rows = COUNT(*) ' +
											' FROM		' + @schema_name + '.' + @table_name +
											' WHERE		' + @column_name + ' IS NOT NULL ' +
											' AND tp_ListId = ' + char(39) + '374f49fb-dfa3-4a15-b7ba-378f805e40f8' + char(39) +
											';'
					-- exec the query
					PRINT @sql_command
					EXECUTE sp_executesql @sql_command, N'@result_rows INT OUTPUT' ,@result_rows OUTPUT

					-- UPDATE Temp Table
					UPDATE	#column_list
							SET values_found = @result_rows
					WHERE	table_name		= @table_name
							AND column_name = @column_name
					;

					
					-- get the next row
					FETCH		NEXT FROM @main_cursor INTO
								@schema_name
								, @table_name
								, @column_name
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


-- -----------------------------------------------------------------------
-- SHOW THE RESULTS
-- -----------------------------------------------------------------------
SELECT		*
FROM		#column_list
ORDER BY	1,2
;


 