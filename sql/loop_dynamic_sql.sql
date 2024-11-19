USE Clarity_Reports_Dev;
GO

SELECT		  DATEPART(dw, '2020-09-13')
			, DATEPART(dw, '2020-09-16')
			, DATEPART(dw, '2020-09-19')



SELECT		TOP (100)
			*
FROM		Qlik.DailyBlast_Metrics
;

DROP TABLE		#db_stats;


CREATE TABLE	#db_stats
(
	  pos				INT
	, fn				NVARCHAR(128)
	, week_segment		NVARCHAR(16)
	, year_value		INT
	, min_value			NUMERIC(18,5)
	, Perc25			NUMERIC(18,5)
	, Perc50			NUMERIC(18,5)
	, mean_value		NUMERIC(18,5)
	, Perc75			NUMERIC(18,5)
	, max_value			NUMERIC(18,5)
)

DECLARE		@ctr	INT = 2;
DECLARE		@fn		NVARCHAR(128) = 'Census_Inpatient'
DECLARE		@sql	NVARCHAR(4000)



WHILE		(@ctr <= 32)
BEGIN

			SELECT			@fn = infocolumns.column_name 

			FROM			INFORMATION_SCHEMA.COLUMNS AS infocolumns
							INNER JOIN INFORMATION_SCHEMA.TABLES AS infoTables
								ON infocolumns.TABLE_NAME = infoTables.TABLE_NAME

			WHERE			infocolumns.TABLE_NAME LIKE '%DailyBlast_Metrics%' 
							AND infocolumns.ORDINAL_POSITION = @ctr
			
			SET @sql =N'	INSERT INTO #db_stats
							SELECT DISTINCT
							  ''' + CAST(@ctr AS NVARCHAR(4)) +'''																	AS pos
							, ''' + @fn +'''																						AS fn
							, ''Full Week''																							AS week_segment
							, db.Year_Date_Value																					AS Year_Value
							, MIN(' + @fn +') OVER (PARTITION BY db.Year_Date_Value)												AS Min_Value
							, PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ' + @fn +') OVER (PARTITION BY db.Year_Date_Value)		AS Perc25
							, PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY ' + @fn +') OVER (PARTITION BY db.Year_Date_Value)		AS Perc50
							, AVG(' + @fn +') OVER (PARTITION BY db.Year_Date_Value)												AS Mean_Value
							, PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ' + @fn +') OVER (PARTITION BY db.Year_Date_Value)		AS Perc75
							, MAX(' + @fn +') OVER (PARTITION BY db.Year_Date_Value)												AS Max_Value
			FROM			(
							SELECT		YEAR(Date_Value)	AS Year_Date_Value
										, *
							FROM		Qlik.DailyBlast_Metrics
							WHERE		Date_Value NOT BETWEEN ''2020-03-01'' AND ''2020-05-31''
							) db
			;'
			EXEC sp_executesql @sql;
			
			SET @sql =N'	INSERT INTO #db_stats
							SELECT DISTINCT
							  ''' + CAST(@ctr AS NVARCHAR(4)) +'''																	AS pos
							, ''' + @fn +'''																						AS fn
							, ''Weekdays''																							AS week_segment
							, db.Year_Date_Value																					AS Year_Value
							, MIN(' + @fn +') OVER (PARTITION BY db.Year_Date_Value)												AS Min_Value
							, PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ' + @fn +') OVER (PARTITION BY db.Year_Date_Value)		AS Perc25
							, PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY ' + @fn +') OVER (PARTITION BY db.Year_Date_Value)		AS Perc50
							, AVG(' + @fn +') OVER (PARTITION BY db.Year_Date_Value)												AS Mean_Value
							, PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ' + @fn +') OVER (PARTITION BY db.Year_Date_Value)		AS Perc75
							, MAX(' + @fn +') OVER (PARTITION BY db.Year_Date_Value)												AS Max_Value
			FROM			(
							SELECT		YEAR(Date_Value)	AS Year_Date_Value
										, *
							FROM		Qlik.DailyBlast_Metrics
							WHERE		Date_Value NOT BETWEEN ''2020-03-01'' AND ''2020-05-31''
										AND DATEPART(dw, Date_Value) BETWEEN 2 AND 6
							) db
			;'
			EXEC sp_executesql @sql;
			
				
			SET @sql =N'	INSERT INTO #db_stats
							SELECT DISTINCT
							  ''' + CAST(@ctr AS NVARCHAR(4)) +'''																	AS pos
							, ''' + @fn +'''																						AS fn
							, ''Weekend''																							AS week_segment
							, db.Year_Date_Value																					AS Year_Value
							, MIN(' + @fn +') OVER (PARTITION BY db.Year_Date_Value)												AS Min_Value
							, PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ' + @fn +') OVER (PARTITION BY db.Year_Date_Value)		AS Perc25
							, PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY ' + @fn +') OVER (PARTITION BY db.Year_Date_Value)		AS Perc50
							, AVG(' + @fn +') OVER (PARTITION BY db.Year_Date_Value)												AS Mean_Value
							, PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ' + @fn +') OVER (PARTITION BY db.Year_Date_Value)		AS Perc75
							, MAX(' + @fn +') OVER (PARTITION BY db.Year_Date_Value)												AS Max_Value
			FROM			(
							SELECT		YEAR(Date_Value)	AS Year_Date_Value
										, *
							FROM		Qlik.DailyBlast_Metrics
							WHERE		Date_Value NOT BETWEEN ''2020-03-01'' AND ''2020-05-31''
										AND DATEPART(dw, Date_Value) NOT BETWEEN 2 AND 6
							) db
			;'
			EXEC sp_executesql @sql;
			SET @ctr = @ctr + 1
END


SELECT		*
FROM		#db_stats
ORDER BY	pos, year_value, week_segment

