USE DW_Staging_MXP -- Your database here
GO
--	---------------------------------------------------------------------------
--	User-defined variables
--	---------------------------------------------------------------------------

DECLARE @TABLE_SCHEMA NVARCHAR(128)		= 'mxp'					-- Your schema here
DECLARE @TABLE_NAME NVARCHAR(128)		= 'IM_Specs'			-- Your table here
DECLARE @ColumnListIN NVarchar(4000)	= ''					-- Enter a comma-separated list of specific columns
																-- to profile, or leave blank for all
DECLARE @TextCol Bit					= 1						-- Analyse all text (char/varchar/nvarchar) data type columns
DECLARE @NumCol Bit						= 1						-- Analyse all numeric data type columns
DECLARE @DateCol Bit					= 1						-- Analyse all date data type data type columns
DECLARE @LobCol Bit						= 1						-- Analyse all VAR(char/nchar/binary) MAX data type columns (potentially time-consuming)
DECLARE @AdvancedAnalysis Bit			= 0						-- Perform advanced analysis (threshold counts/domain analysis) 
																--(potentially time-consuming)
DECLARE @DistinctValuesMinimum Int		= 200					-- Minimum number of distinct values to suggest a reference 
																-- table and/or perform domain analysis
DECLARE @BoundaryPercent Numeric(3,2)	= 0.57					-- Percent of records at upper/lower threshold to suggest
																-- a possible anomaly
DECLARE @NullBoundaryPercent Numeric(5,2) = 90.00				-- Percent of NULLs to suggest a possible anomaly
DECLARE @DataTypePercentage Int = 2								-- Percentage variance allowed when suggesting another data type 
																-- for a column

-----------------------------------------------------------------------
-- Process variables
-----------------------------------------------------------------------
DECLARE @DATA_TYPE Varchar(128) = ''
DECLARE @FULLSQL Varchar(MAX) = ''
DECLARE @SQLMETADATA Varchar(MAX) = ''
DECLARE @NUMSQL Varchar(MAX) = ''
DECLARE @DATESQL Varchar(MAX) = ''
DECLARE @LOBSQL Varchar(MAX) = ''
DECLARE @COLUMN_NAME Varchar(128)
DECLARE @CHARACTER_MAXIMUM_LENGTH Int
DECLARE @ROWCOUNT BigInt = 0
DECLARE @ColumnList Varchar(4000) = ' '
DECLARE @TableCheck TinyInt
DECLARE @ColumnCheck SmallInt
DECLARE @DataTypeVariance Int
-----------------------------------------------------------------------
-- Start the process:
BEGIN
TRY
-- Test that the schema and table exist
SELECT
 @TableCheck = COUNT (*) 
   FROM INFORMATION_SCHEMA.TABLES 
   WHERE TABLE_SCHEMA = @TABLE_SCHEMA 
   AND TABLE_NAME = @TABLE_NAME
IF @TableCheck <> 1
 BEGIN
  RAISERROR ('The table does not exist',16,1)
  RETURN
 END
-----------------------------------------------------------------------
-- Parse list of columns to process / get list of columns according to types required
-----------------------------------------------------------------------
IF OBJECT_ID('tempdb..#ColumnList') IS NOT NULL
	DROP TABLE tempdb..#ColumnList;
CREATE TABLE #ColumnList
(
	COLUMN_NAME				   Varchar(128)
	, DATA_TYPE				   Varchar(128)
	, CHARACTER_MAXIMUM_LENGTH Int
); -- Used to hold list of columns to process
IF @ColumnListIN <> '' -- See if there is a list of columns to process
BEGIN
	-- Process list
	SET @ColumnList = @ColumnListIN + ',';
	DECLARE @CharPosition Int;
	WHILE CHARINDEX(',', @ColumnList) > 0
	BEGIN
		SET @CharPosition = CHARINDEX(',', @ColumnList);
		INSERT INTO #ColumnList
		(
			COLUMN_NAME
		)
		VALUES
			 (LTRIM(RTRIM(LEFT(@ColumnList, @CharPosition - 1))));
		SET @ColumnList = STUFF(@ColumnList, 1, @CharPosition, '');
	END; -- While loop
		 -- update with datatype and length
	UPDATE	CL
	SET		CL.CHARACTER_MAXIMUM_LENGTH = ISNULL(ISC.CHARACTER_MAXIMUM_LENGTH, 0)
			, CL.DATA_TYPE = ISC.DATA_TYPE
	FROM	#ColumnList							  CL
			INNER JOIN INFORMATION_SCHEMA.COLUMNS ISC
			ON	CL.COLUMN_NAME = ISC.COLUMN_NAME
	WHERE	ISC.TABLE_NAME		 = @TABLE_NAME
			AND ISC.TABLE_SCHEMA = @TABLE_SCHEMA;
END;
-- If test for list of column names
ELSE
BEGIN
	-- Use all column names, to avoid filtering
	IF @TextCol = 1
	BEGIN
		INSERT INTO #ColumnList
		(
			COLUMN_NAME
			, DATA_TYPE
			, CHARACTER_MAXIMUM_LENGTH
		)
		SELECT	COLUMN_NAME
				, DATA_TYPE
				, CHARACTER_MAXIMUM_LENGTH
		FROM	INFORMATION_SCHEMA.COLUMNS
		WHERE	DATA_TYPE IN (	 'varchar'
								 , 'nvarchar'
								 , 'char'
								 , 'nchar'
								 , 'binary'
							 )
				AND TABLE_NAME				 = @TABLE_NAME
				AND TABLE_SCHEMA			 = @TABLE_SCHEMA
				AND CHARACTER_MAXIMUM_LENGTH > 0;
	END;
	IF @NumCol = 1
	BEGIN
		INSERT INTO #ColumnList
		(
			COLUMN_NAME
			, DATA_TYPE
			, CHARACTER_MAXIMUM_LENGTH
		)
		SELECT	COLUMN_NAME
				, DATA_TYPE
				, ISNULL(CHARACTER_MAXIMUM_LENGTH, 0)
		FROM	INFORMATION_SCHEMA.COLUMNS
		WHERE	DATA_TYPE IN (	 'numeric'
								 , 'int'
								 , 'bigint'
								 , 'tinyint'
								 , 'smallint'
								 , 'decimal'
								 , 'money'
								 , 'smallmoney'
								 , 'float'
								 , 'real'
							 )
				AND TABLE_NAME	 = @TABLE_NAME
				AND TABLE_SCHEMA = @TABLE_SCHEMA;
	END;
	IF @DateCol = 1
	BEGIN
		INSERT INTO #ColumnList
		(
			COLUMN_NAME
			, DATA_TYPE
			, CHARACTER_MAXIMUM_LENGTH
		)
		SELECT	COLUMN_NAME
				, DATA_TYPE
				, ISNULL(CHARACTER_MAXIMUM_LENGTH, 0)
		FROM	INFORMATION_SCHEMA.COLUMNS
		WHERE	DATA_TYPE IN (	 'Date'
								 , 'DateTime'
								 , 'SmallDateTime'
								 , 'DateTime2'
								 , 'time'
							 )
				AND TABLE_NAME	 = @TABLE_NAME
				AND TABLE_SCHEMA = @TABLE_SCHEMA;
	END;
	IF @LOBCol = 1
	BEGIN
		INSERT INTO #ColumnList
		(
			COLUMN_NAME
			, DATA_TYPE
			, CHARACTER_MAXIMUM_LENGTH
		)
		SELECT	COLUMN_NAME
				, DATA_TYPE
				, CHARACTER_MAXIMUM_LENGTH
		FROM	INFORMATION_SCHEMA.COLUMNS
		WHERE	DATA_TYPE IN (	 'varchar'
								 , 'nvarchar'
								 , 'varbinary'
								 , 'xml'
							 )
				AND TABLE_NAME				 = @TABLE_NAME
				AND TABLE_SCHEMA			 = @TABLE_SCHEMA
				AND CHARACTER_MAXIMUM_LENGTH = -1;
	END;
END;
-- Else test to get all column names
-----------------------------------------------------------------------
-- Test that there are columns to analyse
SELECT	@ColumnCheck = COUNT(*)
FROM	#ColumnList
WHERE	DATA_TYPE IS NOT NULL;
IF @ColumnCheck = 0
BEGIN
	RAISERROR('The columns do not exist in the selected database or no columns are selected', 16, 1);
	RETURN;
END;
-----------------------------------------------------------------------
-- Create Temp table used to hold profiling data
-----------------------------------------------------------------------
IF OBJECT_ID('tempdb..#ProfileData') IS NOT NULL
	DROP TABLE tempdb..#ProfileData;
CREATE TABLE #ProfileData
(
	TABLE_SCHEMA				 NVarchar(128)
	, TABLE_NAME				 NVarchar(128)
	, COLUMN_NAME				 NVarchar(128)
	, ColumnDataLength			 Int
	, DataType					 Varchar(128)
	, MinDataLength				 BigInt
	, MaxDataLength				 BigInt
	, AvgDataLength				 BigInt
	, MinDate					 Sql_Variant
	, MaxDate					 Sql_Variant
	, NoDistinct				 BigInt
	, NoNulls					 Numeric(32, 4)
	, NoZeroLength				 Numeric(32, 4)
	, PercentageNulls			 Numeric(9, 4)
	, PercentageZeroLength		 Numeric(9, 4)
	, NoDateWithHourminuteSecond BigInt		   NULL
	, NoDateWithSecond			 BigInt		   NULL
	, NoIsNumeric				 BigInt		   NULL
	, NoIsDate					 BigInt		   NULL
	, NoAtLimit					 BigInt		   NULL
	, IsFK						 Bit		   NULL
		  DEFAULT 0
	, DataTypeComments			 NVarchar(1500)
);
-- Get row count
DECLARE @ROWCOUNTTEXT NVARCHAR(1000) = ''
DECLARE @ROWCOUNTPARAM NVARCHAR(50) = ''
SET @ROWCOUNTTEXT = 'SELECT @ROWCOUNTOUT = COUNT (*) FROM ' + QUOTENAME(@TABLE_SCHEMA) + '.' + QUOTENAME(@TABLE_NAME) + ' WITH (NOLOCK)'
SET @ROWCOUNTPARAM = '@ROWCOUNTOUT INT OUTPUT'
EXECUTE sp_executesql @ROWCOUNTTEXT, @ROWCOUNTPARAM, @ROWCOUNTOUT = @ROWCOUNT OUTPUT
-----------------------------------------------------------------------
-- Test that there are records to analyse
IF @ROWCOUNT = 0
 BEGIN
  RAISERROR('There is no data in the table to analyse',16,1)
  RETURN
 END


-----------------------------------------------------------------------
-- Define the dynamic SQL used for each column to analyse
-----------------------------------------------------------------------
SET @SQLMETADATA = 'INSERT INTO #ProfileData (ColumnDataLength,COLUMN_NAME,TABLE_SCHEMA,TABLE_NAME,DataType,MaxDataLength,MinDataLength,AvgDataLength,MaxDate,MinDate,NoDateWithHourminuteSecond,NoDateWithSecond,NoIsNumeric,NoIsDate,NoNulls,NoZeroLength,NoDistinct)'
DECLARE SQLMETADATA_CUR CURSOR LOCAL FAST_FORWARD FOR 
 SELECT COLUMN_NAME, CHARACTER_MAXIMUM_LENGTH, DATA_TYPE FROM #ColumnList
OPEN SQLMETADATA_CUR 
FETCH NEXT FROM SQLMETADATA_CUR INTO @COLUMN_NAME, @CHARACTER_MAXIMUM_LENGTH, @DATA_TYPE 
WHILE @@FETCH_STATUS = 0 
 BEGIN 
  SET @SQLMETADATA = @SQLMETADATA +'
  SELECT TOP 100 PERCENT ' + CAST(@CHARACTER_MAXIMUM_LENGTH AS VARCHAR(20)) + ' ,''' + QUOTENAME(@COLUMN_NAME) + '''
  ,''' + QUOTENAME(@TABLE_SCHEMA) + '''
  ,''' + QUOTENAME(@TABLE_NAME) + '''
  ,''' + @DATA_TYPE + ''''
   + CASE
      WHEN @DATA_TYPE IN ('varchar', 'nvarchar', 'char', 'nchar') 
   AND @CHARACTER_MAXIMUM_LENGTH >= 0 
     THEN + '
  , MAX(LEN(' + QUOTENAME(@COLUMN_NAME) + ')) 
  , MIN(LEN(' + QUOTENAME(@COLUMN_NAME) + ')) 
  , AVG(LEN(' + QUOTENAME(@COLUMN_NAME) + '))
  ,NULL
  ,NULL 
  ,NULL 
  ,NULL 
  ,(SELECT COUNT (*) from '
   + QUOTENAME(@TABLE_SCHEMA) + '.' + QUOTENAME(@TABLE_NAME) + ' WHERE ISNUMERIC(' + QUOTENAME(@COLUMN_NAME) + ') = 1) 
  ,(SELECT COUNT (*) from ' + QUOTENAME(@TABLE_SCHEMA) + '.' + QUOTENAME(@TABLE_NAME) + ' WHERE ISDATE(' + QUOTENAME(@COLUMN_NAME) + ') = 1) '
  WHEN @DATA_TYPE IN ('numeric', 'int', 'bigint', 'tinyint', 'smallint', 'decimal', 'money', 'smallmoney', 'float','real') THEN + '
  ,MAX(' + QUOTENAME(@COLUMN_NAME) + ') 
  ,MIN(' + QUOTENAME(@COLUMN_NAME) + ') 
  ,AVG(CAST(' + QUOTENAME(@COLUMN_NAME) + ' AS NUMERIC(36,2)))
  ,NULL
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL '
   WHEN @DATA_TYPE IN ('DateTime', 'SmallDateTime') THEN + '
  ,NULL 
  ,NULL 
  ,NULL 
  ,MAX(' + QUOTENAME(@COLUMN_NAME) + ') 
  ,MIN(' + QUOTENAME(@COLUMN_NAME) + ')
  ,(SELECT COUNT (*) from ' 
   + QUOTENAME(@TABLE_SCHEMA) + '.' + QUOTENAME(@TABLE_NAME) + ' WHERE (CONVERT(NUMERIC(20,12), ' + QUOTENAME(@COLUMN_NAME) + ' ) - FLOOR(CONVERT(NUMERIC(20,12), ' + QUOTENAME(@COLUMN_NAME) + ')) <> 0))
  ,(SELECT COUNT (*) from '
   + QUOTENAME(@TABLE_SCHEMA) + '.' + QUOTENAME(@TABLE_NAME) + ' WHERE DATEPART(ss,' + QUOTENAME(@COLUMN_NAME) + ') <> 0 OR DATEPART(mcs,' + QUOTENAME(@COLUMN_NAME) + ') <> 0) 
  ,NULL 
  ,NULL '
    WHEN @DATA_TYPE IN ('DateTime2') THEN + '
  ,NULL 
  ,NULL 
  ,NULL 
  ,MAX(' + QUOTENAME(@COLUMN_NAME) + ') 
  ,MIN(' + QUOTENAME(@COLUMN_NAME) + ')
  ,NULL
  ,NULL
  ,NULL 
  ,NULL '
   WHEN @DATA_TYPE IN ('Date') THEN + '
  ,NULL 
  ,NULL 
  ,NULL 
  ,MAX('
   + QUOTENAME(@COLUMN_NAME) + ') 
  ,MIN('
  + QUOTENAME(@COLUMN_NAME) + ')
  ,NULL 
  ,NLL 
  ,NULL 
  ,NULL '
   WHEN @DATA_TYPE IN ('xml') THEN + '
  ,MAX(LEN(CAST(' + QUOTENAME(@COLUMN_NAME) + ' AS NVARCHAR(MAX)))) 
  ,MIN(LEN(CAST(' + QUOTENAME(@COLUMN_NAME) + ' AS NVARCHAR(MAX)))) 
  ,AVG(LEN(CAST(' + QUOTENAME(@COLUMN_NAME) + ' AS NVARCHAR(MAX)))) 
  ,NULL
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL '
  WHEN @DATA_TYPE IN ('varbinary','varchar','nvarchar') AND  @CHARACTER_MAXIMUM_LENGTH = -1 THEN + '
  ,MAX(LEN(' + QUOTENAME(@COLUMN_NAME) + ')) 
  ,MIN(LEN(' + QUOTENAME(@COLUMN_NAME) + ')) 
  ,AVG(LEN(' + QUOTENAME(@COLUMN_NAME) + '))
  ,NULL
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL '
   WHEN @DATA_TYPE IN ('binary') THEN + '
  ,MAX(LEN(' + QUOTENAME(@COLUMN_NAME) + ')) 
  ,MIN(LEN(' + QUOTENAME(@COLUMN_NAME) + ')) 
  ,AVG(LEN(' + QUOTENAME(@COLUMN_NAME) + '))
  ,NULL
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL '
   WHEN @DATA_TYPE IN ('time') THEN + '
  ,NULL 
  ,NULL 
  ,NULL 
  ,MAX(' + QUOTENAME(@COLUMN_NAME) + ') 
  ,MIN(' + QUOTENAME(@COLUMN_NAME) + ')
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL '
   ELSE + '
  ,NULL 
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL '
  END + '
  ,(SELECT COUNT(*) FROM ' + QUOTENAME(@TABLE_SCHEMA) + '.' + QUOTENAME(@TABLE_NAME) + ' WHERE ' + QUOTENAME(@COLUMN_NAME) + ' IS NULL)'
   + CASE
   WHEN @DATA_TYPE IN ('varchar', 'nvarchar', 'char', 'nchar') THEN + '
  ,(SELECT COUNT(*) FROM ' + QUOTENAME(@TABLE_SCHEMA) + '.' + QUOTENAME(@TABLE_NAME) +  ' WHERE LEN(LTRIM(RTRIM(' + QUOTENAME(@COLUMN_NAME) + '))) = '''')'
   ELSE + '
  ,NULL'
   END + '
  ,(SELECT COUNT(DISTINCT ' + QUOTENAME(@COLUMN_NAME) + ') FROM ' + QUOTENAME(@TABLE_SCHEMA) + '.' + QUOTENAME(@TABLE_NAME) + ' WHERE ' + QUOTENAME(@COLUMN_NAME) + ' IS NOT NULL )
  FROM ' + QUOTENAME(@TABLE_SCHEMA) + '.' + QUOTENAME(@TABLE_NAME) + ' WITH (NOLOCK)
  UNION'
 FETCH NEXT FROM SQLMETADATA_CUR INTO @COLUMN_NAME, @CHARACTER_MAXIMUM_LENGTH, @DATA_TYPE 
END 
CLOSE SQLMETADATA_CUR 
DEALLOCATE SQLMETADATA_CUR 
SET @SQLMETADATA = LEFT(@SQLMETADATA, LEN(@SQLMETADATA) -5)
EXEC (@SQLMETADATA)
-----------------------------------------------------------------------
-- Final Calculations
-----------------------------------------------------------------------
-- Indicate Foreign Keys
;WITH FK_CTE (FKColumnName)
AS (
   SELECT	DISTINCT
			CU.COLUMN_NAME
   FROM		INFORMATION_SCHEMA.TABLE_CONSTRAINTS				  TC
			INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE CU
			ON	TC.CONSTRAINT_NAME	= CU.CONSTRAINT_NAME
				AND TC.TABLE_SCHEMA = CU.TABLE_SCHEMA
				AND TC.TABLE_NAME	= CU.TABLE_NAME
				AND TC.TABLE_SCHEMA = @TABLE_SCHEMA
				AND TC.TABLE_NAME	= @TABLE_NAME
				AND CONSTRAINT_TYPE = 'FOREIGN KEY'
   )
UPDATE	P
SET		P.IsFK = 1
FROM	#ProfileData	  P
		INNER JOIN FK_CTE CTE
		ON	P.COLUMN_NAME = CTE.FKColumnName;
-- Calculate percentages
UPDATE	#ProfileData
SET		PercentageNulls = (NoNulls / @ROWCOUNT) * 100
		, PercentageZeroLength = (NoZeroLength / @ROWCOUNT) * 100;
-- Add any comments
-- Datatype suggestions
-- First get number of records where a variation could be an anomaly
SET @DataTypeVariance = ROUND((@ROWCOUNT * @DataTypePercentage) / 100, 0);
UPDATE	#ProfileData
SET		DataTypeComments = 'Possibly could be one of the DATE types. '
WHERE	NoIsDate BETWEEN (@ROWCOUNT - @DataTypeVariance) AND (@ROWCOUNT + @DataTypeVariance)
		AND DataType IN (	'varchar'
							, 'nvarchar'
							, 'char'
							, 'nchar'
						);
UPDATE	#ProfileData
SET		DataTypeComments = 'Possibly could be one of the NUMERIC types. '
WHERE	NoIsNumeric BETWEEN (@ROWCOUNT - @DataTypeVariance) AND (@ROWCOUNT + @DataTypeVariance)
		AND DataType IN (	'varchar'
							, 'nvarchar'
							, 'char'
							, 'nchar'
						);
UPDATE	#ProfileData
SET		DataTypeComments = 'Possibly could be INT type. '
WHERE	MinDataLength	  >= -2147483648
		AND MaxDataLength <= 2147483648
		AND DataType IN ('bigint');

UPDATE	#ProfileData
SET		DataTypeComments = 'Possibly could be SMALLINT type. '
WHERE	MinDataLength	  >= -32768
		AND MaxDataLength <= 32767
		AND DataType IN (	'bigint'
							, 'int'
						);
UPDATE	#ProfileData
SET		DataTypeComments = 'Possibly could be TINYINT type. '
WHERE	MinDataLength	  >= 0
		AND MaxDataLength <= 255
		AND DataType IN (	'bigint'
							, 'int'
							, 'smallint'
						);
UPDATE	#ProfileData
SET		DataTypeComments = 'Possibly could be SMALLDATE type. '
WHERE	NoDateWithSecond = 0
		AND MinDate		 >= '19000101'
		AND MaxDate		 <= '20790606'
		AND DataType IN (	'datetime'
							, 'datetime2'
						);
UPDATE	#ProfileData
SET		DataTypeComments = 'Possibly could be DATE type (SQL Server 2008 only). '
WHERE	NoDateWithHourminuteSecond = 0
		AND DataType IN (	'datetime'
							, 'datetime2'
						);
UPDATE	#ProfileData
SET		DataTypeComments = 'Possibly could be DATETIME type. '
WHERE	MinDate		>= '17530101'
		AND MaxDate <= '99991231'
		AND DataType IN ('datetime2');
-- Empty column suggestions
UPDATE	#ProfileData
SET		DataTypeComments = ISNULL(DataTypeComments, '') + 'Seems empty - is it required? '
WHERE	(
		PercentageNulls			 = 100
		OR	PercentageZeroLength = 100
		)
		AND IsFK				 = 0;
-- Null column suggestions
UPDATE	#ProfileData
SET		DataTypeComments = ISNULL(DataTypeComments, '') + 'There is a large percentage of NULLs - attention may be required. '
WHERE	PercentageNulls >= @NullBoundaryPercent;
-- Distinct value suggestions
UPDATE	#ProfileData
SET		DataTypeComments = ISNULL(DataTypeComments, '') + 'Few distinct elements - potential for reference/lookup table (contains NULLs).'
WHERE	NoDistinct			< @DistinctValuesMinimum
		AND @ROWCOUNT		> @DistinctValuesMinimum
		AND IsFK			= 0
		AND PercentageNulls <> 100
		AND NoNulls			<> 0;
-- FK suggestions
UPDATE	#ProfileData
SET		DataTypeComments = ISNULL(DataTypeComments, '') + 'Few distinct elements - potential for Foreign Key.'
WHERE	NoDistinct	  < @DistinctValuesMinimum
		AND @ROWCOUNT > @DistinctValuesMinimum
		AND IsFK	  = 0
		AND NoNulls	  = 0
		AND DataType NOT LIKE '%Date%'
		AND DataType  <> 'Time';
-- Filestream suggestions
UPDATE	#ProfileData
SET		DataTypeComments = 'Possibly a good candidate for FILESTREAM (SQL Server 2008 only).'
WHERE	AvgDataLength		 >= 1000000
		AND DataType IN ('varbinary')
		AND ColumnDataLength = -1;
UPDATE	#ProfileData
SET		DataTypeComments = 'Possibly not a good candidate for FILESTREAM (SQL Server 2008 only).'
WHERE	AvgDataLength		 < 1000000
		AND DataType IN ('varbinary')
		AND ColumnDataLength = -1;
-- Sparse Column Suggestions
IF OBJECT_ID('tempdb..#SparseThresholds') IS NOT NULL
  DROP TABLE tempdb..#SparseThresholds;
  CREATE TABLE #SparseThresholds (DataType VARCHAR(128), Threshold NUMERIC(9,4))
  INSERT INTO #SparseThresholds (DataType, Threshold)
   VALUES 
    ('tinyint',86),
    ('smallint',76),    
    ('int',64),    
    ('bigint',52),    
    ('real',64),    
    ('float',52),    
    ('money',64),    
    ('smallmoney',64),    
    ('smalldatetime',52),    
    ('datetime',52),    
    ('uniqueidentifier',43),    
    ('date',69),    
    ('datetime2',52),    
    ('decimal',42),    
    ('nuumeric',42),    
    ('char',60),    
    ('varchar',60),    
    ('nchar',60),    
    ('nvarchar',60),    
    ('binary',60),    
    ('varbinary',60),    
    ('xml',60)    
; WITH Sparse_CTE (COLUMN_NAME, SparseComment)
AS
(
SELECT
  P.COLUMN_NAME
 ,CASE
  WHEN P.PercentageNulls >= T.Threshold THEN 'Could benefit from sparse columns. '
  ELSE ''
  END AS SparseComment
FROM #ProfileData P
 INNER JOIN #SparseThresholds T
  ON P.DataType = T.DataType
)
UPDATE PT
  SET PT.DataTypeComments = 
      CASE WHEN PT.DataTypeComments IS NULL THEN CTE.SparseComment
           ELSE ISNULL(PT.DataTypeComments,'') + CTE.SparseComment + '. '
      END
 FROM #ProfileData PT
  INNER JOIN Sparse_CTE CTE
   ON PT.COLUMN_NAME = CTE.COLUMN_NAME
-----------------------------------------------------------------------
-- Optional advanced analysis
-----------------------------------------------------------------------
IF @AdvancedAnalysis = 1
 BEGIN
-----------------------------------------------------------------------
-- Data at data boundaries
-----------------------------------------------------------------------
  IF OBJECT_ID('tempdb..#LimitTest') IS NOT NULL
    DROP TABLE tempdb..#LimitTest;
    CREATE TABLE #LimitTest (COLUMN_NAME VARCHAR(128), NoAtLimit BIGINT);
    DECLARE @advancedtestSQL VARCHAR(MAX) = 'INSERT INTO #LimitTest (COLUMN_NAME, NoAtLimit)' + CHAR(13)
    SELECT @advancedtestSQL = @advancedtestSQL + 'SELECT '''+ COLUMN_NAME + ''', COUNT('+ COLUMN_NAME + ') FROM ' + @TABLE_SCHEMA + '.' + @TABLE_NAME + 
     CASE
       WHEN DataType IN ('numeric', 'int', 'bigint', 'tinyint', 'smallint', 'decimal', 'money', 'smallmoney', 'float','real') THEN ' WHERE '+ COLUMN_NAME + ' = ' + CAST(ISNULL(MaxDataLength,0) AS VARCHAR(40)) + ' OR '+ COLUMN_NAME + ' = ' + CAST(ISNULL(MinDataLength,0) AS VARCHAR(40)) + CHAR(13) + ' UNION' + CHAR(13)
       ELSE ' WHERE LEN('+ COLUMN_NAME + ') = ' + CAST(ISNULL(MaxDataLength,0) AS VARCHAR(40)) + ' OR LEN('+ COLUMN_NAME + ') = ' + CAST(ISNULL(MinDataLength,0) AS VARCHAR(40)) + CHAR(13) + ' UNION' + CHAR(13)
     END
    FROM #ProfileData 
    WHERE DataType IN ('numeric', 'int', 'bigint', 'tinyint', 'smallint', 'decimal', 'money', 'smallmoney', 'float','real','varchar', 'nvarchar', 'char', 'nchar', 'binary')
    SET @advancedtestSQL = LEFT(@advancedtestSQL,LEN(@advancedtestSQL) -6) 
    EXEC (@advancedtestSQL)
    UPDATE M
      SET M.NoAtLimit = T.NoAtLimit
         ,M.DataTypeComments = 
           CASE
             WHEN CAST(T.NoAtLimit AS NUMERIC(36,2)) / CAST(@ROWCOUNT AS NUMERIC(36,2)) >= @BoundaryPercent THEN ISNULL(M.DataTypeComments,'') + 'Large numbers of data elements at the max/minvalues. '
             ELSE M.DataTypeComments
           END
    FROM #ProfileData M
     INNER JOIN #LimitTest T
      ON M.COLUMN_NAME = T.COLUMN_NAME
   -----------------------------------------------------------------------
   -- Domain analysis
   -----------------------------------------------------------------------
   IF OBJECT_ID('tempdb..#DomainAnalysis') IS NOT NULL
     DROP TABLE tempdb..#DomainAnalysis;
   CREATE TABLE #DomainAnalysis
   (
    DomainName NVARCHAR(128)
   ,DomainElement NVARCHAR(4000)
   ,DomainCounter BIGINT
   ,DomainPercent NUMERIC(7,4)
   );
   DECLARE @DOMAINSQL VARCHAR(MAX) = 'INSERT INTO #DomainAnalysis (DomainName, DomainElement, DomainCounter) '
   DECLARE SQLDOMAIN_CUR CURSOR LOCAL FAST_FORWARD FOR 
     SELECT COLUMN_NAME, DataType 
  FROM #ProfileData 
   WHERE NoDistinct < @DistinctValuesMinimum
   OPEN SQLDOMAIN_CUR 
   FETCH NEXT FROM SQLDOMAIN_CUR INTO @COLUMN_NAME, @DATA_TYPE 
   WHILE @@FETCH_STATUS = 0 
    BEGIN 
     SET @DOMAINSQL = @DOMAINSQL + 'SELECT ''' + @COLUMN_NAME + ''' AS DomainName, CAST( '+ @COLUMN_NAME + ' AS VARCHAR(4000)) AS DomainElement, COUNT(ISNULL(CAST(' + @COLUMN_NAME + ' AS NVARCHAR(MAX)),'''')) AS DomainCounter FROM ' + @TABLE_SCHEMA + '.' + @TABLE_NAME + ' GROUP BY ' + @COLUMN_NAME + ''
     + ' UNION '
     FETCH NEXT FROM SQLDOMAIN_CUR INTO @COLUMN_NAME, @DATA_TYPE 
   END 
  CLOSE SQLDOMAIN_CUR 
  DEALLOCATE SQLDOMAIN_CUR 
  SET @DOMAINSQL = LEFT(@DOMAINSQL, LEN(@DOMAINSQL) -5) + ' ORDER BY DomainName ASC, DomainCounter DESC '
   EXEC (@DOMAINSQL)
   -- Now calculate percentages (this appraoch is faster than doing it when performing the domain analysis)
   ; WITH DomainCounter_CTE (DomainName, DomainCounterTotal)
   AS
  (
   SELECT DomainName, SUM(ISNULL(DomainCounter,0)) AS DomainCounterTotal
    FROM #DomainAnalysis 
    GROUP BY DomainName
  )
  UPDATE D
    SET D.DomainPercent = (CAST(D.DomainCounter AS NUMERIC(36,4)) / CAST(CTE.DomainCounterTotal AS NUMERIC(36,4))) * 100
   FROM #DomainAnalysis D
    INNER JOIN DomainCounter_CTE CTE
     ON D.DomainName = CTE.DomainName
   WHERE D.DomainCounter <> 0
 END
-- Advanced analysis


-----------------------------------------------------------------------
-- Output results from the profile and domain data tables
-----------------------------------------------------------------------
UPDATE	#ProfileData
SET		TABLE_SCHEMA = REPLACE(REPLACE(pd.TABLE_SCHEMA,'[', ''),']','')
		,TABLE_NAME	= REPLACE(REPLACE(pd.TABLE_NAME,'[', ''),']','')
		,COLUMN_NAME = REPLACE(REPLACE(pd.COLUMN_NAME,'[', ''),']','')
		
FROM	#ProfileData		pd
;

-- ---------------------------------------------------------------------------
-- SHOW PROFILE
-- ---------------------------------------------------------------------------

SELECT	col.ORDINAL_POSITION
		,pd.*
FROM	#ProfileData		pd
		INNER JOIN INFORMATION_SCHEMA.COLUMNS		col
		ON pd.TABLE_SCHEMA	= col.TABLE_SCHEMA
		AND pd.TABLE_NAME = col.TABLE_NAME
		AND pd.COLUMN_NAME = col.COLUMN_NAME
ORDER BY col.ORDINAL_POSITION
;


-- ---------------------------------------------------------------------------
-- SHOW ADVANCED
-- ---------------------------------------------------------------------------

IF @AdvancedAnalysis = 1
BEGIN
	SELECT	*
	FROM	#DomainAnalysis;
END;


END TRY
BEGIN CATCH
 SELECT
  ERROR_NUMBER() AS ErrorNumber
 ,ERROR_SEVERITY() AS ErrorSeverity
 ,ERROR_STATE() AS ErrorState
 ,ERROR_PROCEDURE() AS ErrorProcedure
 ,ERROR_LINE() AS ErrorLine
 ,ERROR_MESSAGE() AS ErrorMessage;
 
END CATCH