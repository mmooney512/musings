-- ---------------------------------------------------------------------------
-- Find the count of distinct values for each column in a table
-- ---------------------------------------------------------------------------
USE			ddReports;						--ENTER Database name

DECLARE		@sql_function		VARCHAR(MAX)
DECLARE		@tablename			VARCHAR(255)
SET			@tablename	=		'tblEMDPortal_VendorDomain'		-- ENTER Table name

-- Get the column names
SELECT		@sql_function = 'SELECT ' + CHAR(10)
SELECT		@sql_function = @sql_function 
							+ ' COUNT(DISTINCT ['+ isc.column_name + ']) AS ' 
							+ QUOTENAME(CAST(isc.ordinal_position AS VARCHAR(4)) + '_count_'
							+ REPLACE(isc.column_name,'/','_')) + ', '+ CHAR(10)
FROM		INFORMATION_SCHEMA.COLUMNS AS isc
WHERE		isc.table_name = @tablename
			AND isc.ordinal_position BETWEEN 1 AND 30		--GET the first 30 columns
			AND isc.data_type NOT IN ('text' , 'ntext')

-- Remove the trailing comma
SET			@sql_function = SUBSTRING(@sql_function, 1, LEN(@sql_function) - 3) + CHAR(10)
SELECT		@sql_function = @sql_function + ' FROM ' + @tablename

-- echo the sql statement
PRINT		@sql_function
EXEC		(@sql_function);