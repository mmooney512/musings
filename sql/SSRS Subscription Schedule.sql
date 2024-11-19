USE SSRS;
GO

DROP TABLE IF EXISTS #t;
--these CTEs are used to match the bitmask fields in the schedule to determine which days & months the schedule is triggered on
WITH wkdays
AS (
   SELECT	'Sunday' AS label
			, 1		 AS daybit
   UNION ALL
   SELECT	'Monday'
			, 2
   UNION ALL
   SELECT	'Tuesday'
			, 4
   UNION ALL
   SELECT	'Wednesday'
			, 8
   UNION ALL
   SELECT	'Thursday'
			, 16
   UNION ALL
   SELECT	'Friday'
			, 32
   UNION ALL
   SELECT	'Saturday'
			, 64
   )
	 , monthdays
	AS (
	   SELECT	CAST(number AS Varchar(2))			   AS label
				, POWER(CAST(2 AS BigInt), number - 1) AS daybit
	   FROM		master.dbo.spt_values
	   WHERE	type = 'P'
				AND number BETWEEN 1 AND 31
	   )
	 , months
	AS (
	   SELECT	DATENAME(MM, DATEADD(MM, number - 1, 0)) AS label
				, POWER(CAST(2 AS BigInt), number - 1)	 AS mnthbit
	   FROM		master.dbo.spt_values
	   WHERE	type = 'P'
				AND number BETWEEN 1 AND 12
	   )


SELECT	cat.path
		, cat.name
		, cat.creationdate
		, cat.modifieddate
		,

		subs.Description
		, subs.LastStatus
		, subs.LastRunTime
		, subs.InactiveFlags
		, CASE RecurrenceType
			   WHEN 1
			   THEN 'Once'
			   WHEN 2
			   THEN 'Hourly'
			   WHEN 3
			   THEN 'Daily'	  --by interval
			   WHEN 4
			   THEN CASE WHEN WeeksInterval > 1
						 THEN 'Weekly'
						 ELSE 'Daily' --by day of week
					END
			   WHEN 5
			   THEN 'Monthly' --by calendar day
			   WHEN 6
			   THEN 'Monthly' --by day of week
		  END			   AS sched_type
		, sched.StartDate
		, sched.MinutesInterval
		, sched.RecurrenceType
		, sched.DaysInterval
		, sched.WeeksInterval
		, sched.MonthlyWeek
		, wkdays.label	   AS wkday
		, wkdays.daybit	   AS wkdaybit
		, monthdays.label  AS mnthday
		, monthdays.daybit AS mnthdaybit
		, months.label	   AS mnth
		, months.mnthbit
INTO	#t
FROM	dbo.Catalog					 AS cat
		LEFT JOIN dbo.ReportSchedule AS repsched
		ON	repsched.ReportID					 = cat.ItemID

		LEFT JOIN dbo.Subscriptions	 AS subs
		ON	subs.SubscriptionID					 = repsched.SubscriptionID

		LEFT JOIN dbo.Schedule		 AS sched
		ON	sched.ScheduleID					 = repsched.ScheduleID

		LEFT JOIN wkdays
		ON	wkdays.daybit & sched.DaysOfWeek	 > 0

		LEFT JOIN monthdays
		ON	monthdays.daybit & sched.DaysOfMonth > 0

		LEFT JOIN months
		ON	months.mnthbit & sched.[Month]		 > 0
WHERE	cat.ParentID IS NOT NULL;	--all reports have a ParentID


/* THE PREVIOUS QUERY LEAVES MULTIPLE ROWS FOR SUBSCRIPTIONS THAT HAVE MULTIPLE BITMASK MATCHES      *
 * THIS QUERY WILL CONCAT ALL OF THOSE FIELDS TOGETHER AND ACCUMULATE THEM IN A TABLE FOR USE LATER. */
DROP TABLE IF EXISTS #c;
CREATE TABLE #c
(
	type		Varchar(16)	  COLLATE Latin1_General_100_CI_AS_KS_WS
	, name		Varchar(255)  COLLATE Latin1_General_100_CI_AS_KS_WS
	, path		Varchar(255)  COLLATE Latin1_General_100_CI_AS_KS_WS
	, concatStr Varchar(2000) COLLATE Latin1_General_100_CI_AS_KS_WS
);


WITH d
AS (
   SELECT	DISTINCT
			path
			, name
			, mnthday	 AS lbl
			, mnthdaybit AS bm
   FROM		#t
   )
INSERT INTO #c
(
	type
	, path
	, name
	, concatStr
)
SELECT		'monthday' AS type
			, t1.path
			, t1.name
			, STUFF((
					SELECT		', ' + CAST(lbl AS Varchar(MAX))
					FROM		d AS t2
					WHERE		t2.path		= t1.path
								AND t2.name = t1.name
					ORDER BY	bm
					FOR XML PATH(''), TYPE
					).value('.', 'VARCHAR(MAX)')
					, 1
					, 2
					, ''
				   )   AS concatStr
FROM		d AS t1
GROUP BY	t1.path
			, t1.name;

WITH d
AS (
   SELECT	DISTINCT
			path
			, name
			, wkday	   AS lbl
			, wkdaybit AS bm
   FROM		#t
   )
INSERT INTO #c
(
	type
	, path
	, name
	, concatStr
)
SELECT		'weekday' AS type
			, t1.path
			, t1.name
			, STUFF((
					SELECT		', ' + CAST(lbl AS Varchar(MAX))
					FROM		d AS t2
					WHERE		t2.path		= t1.path
								AND t2.name = t1.name
					ORDER BY	bm
					FOR XML PATH(''), TYPE
					).value('.', 'VARCHAR(MAX)')
					, 1
					, 2
					, ''
				   )  AS concatStr
FROM		d AS t1
GROUP BY	t1.path
			, t1.name;

WITH d
AS (
   SELECT	DISTINCT
			path
			, name
			, mnth	  AS lbl
			, mnthbit AS bm
   FROM		#t
   )


INSERT INTO #c
(
	type
	, path
	, name
	, concatStr
)
SELECT		'month'	 AS type
			, t1.path
			, t1.name
			, STUFF((
					SELECT		', ' + CAST(lbl AS Varchar(MAX))
					FROM		d AS t2
					WHERE		t2.path		= t1.path
								AND t2.name = t1.name
					ORDER BY	bm
					FOR XML PATH(''), TYPE
					).value('.', 'VARCHAR(MAX)')
					, 1
					, 2
					, ''
				   ) AS concatStr
FROM		d AS t1
GROUP BY	t1.path
			, t1.name;


/* PUT EVERYTHING TOGETHER FOR THE REPORT */

SELECT	a.path
		, a.name
		, a.sched_type
		, a.creationdate
		, a.modifieddate
		, a.description															AS sched_desc
		, a.laststatus															AS sched_laststatus
		, a.lastruntime															AS sched_lastrun
		, a.inactiveflags														AS sched_inactive
		, CASE RecurrenceType WHEN 1 THEN 'Run once on ' 
		ELSE 'Starting on ' 
		END + CAST(StartDate AS Varchar(32)) + ' ' + CASE RecurrenceType
	WHEN 1
	THEN ''
	WHEN 2
	THEN 'repeat every ' + CAST(MinutesInterval AS Varchar(255)) + ' minutes.'
	WHEN 3
	THEN 'repeat every ' + CAST(DaysInterval AS Varchar(255)) + ' days.'
	WHEN 4
	THEN CASE WHEN WeeksInterval > 1
			 THEN 'repeat every ' + CAST(WeeksInterval AS Varchar(255)) + ' on ' + COALESCE(wkdays.concatStr, '')
			 ELSE 'repeat every ' + COALESCE(wkdays.concatStr, '')
		END
	WHEN 5
	THEN 'repeat every ' + COALESCE(mnths.concatStr, '') + ' on calendar day(s) ' + COALESCE(mnthdays.concatStr, '')
	WHEN 6
	THEN 'run on the ' + CASE MonthlyWeek
		 WHEN 1
		 THEN '1st'
		 WHEN 2
		 THEN '2nd'
		 WHEN 3
		 THEN '3rd'
		 WHEN 4
		 THEN '4th'
		 WHEN 5
		 THEN 'Last'
	END + ' week of ' + COALESCE(mnths.concatStr, '') + ' on ' + COALESCE(wkdays.concatStr, '')
 END AS sched_pattern
FROM	(
		SELECT	DISTINCT
				path
				, name
				, creationdate
				, modifieddate
				, description
				, laststatus
				, lastruntime
				, inactiveflags
				, sched_type
				, recurrencetype
				, startdate
				, minutesinterval
				, daysinterval
				, weeksinterval
				, monthlyweek
		FROM	#t
		)			 AS a
		LEFT JOIN #c AS mnthdays
		ON	mnthdays.path	  = a.path
			AND mnthdays.name = a.name
			AND mnthdays.type = 'monthday'

		LEFT JOIN #c AS wkdays
		ON	wkdays.path		  = a.path
			AND wkdays.name	  = a.name
			AND wkdays.type	  = 'weekday'

		LEFT JOIN #c AS mnths
		ON	mnths.path		  = a.path
			AND mnths.name	  = a.name
			AND mnths.type	  = 'month'


DROP TABLE #t
		   , #c;


