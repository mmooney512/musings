-- ---------------------------------------------------------------------------
-- Store the names of the branches 
DECLARE		@table_name		AS VARCHAR(255);
DECLARE		@schema_name	AS VARCHAR(32);
DECLARE		@row_count		AS INT;
-- ---------------------------------------------------------------------------
-- ---------------------------------------------------------------------------
-- cursor
DECLARE		@main_cursor AS CURSOR;
-- ---------------------------------------------------------------------------

SET		@main_cursor = CURSOR FOR

		SELECT		systables.name						AS TableName
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
		WHERE		systables.NAME LIKE 'U_2015_08_28_S%' 	
		;

OPEN	@main_cursor;

FETCH	NEXT FROM	@main_cursor INTO 
		@table_name
		,@schema_name
		,@row_count
		;

WHILE	@@FETCH_STATUS = 0
		BEGIN
			SET @table_name = @schema_name + '.' + @table_name;
			PRINT 'DROP TABLE  ' + @table_name + ' ;'
			SET @table_name = '';

			FETCH	NEXT FROM	@main_cursor INTO 
			@table_name
			,@schema_name
			,@row_count
			;
		END


CLOSE	@main_cursor;