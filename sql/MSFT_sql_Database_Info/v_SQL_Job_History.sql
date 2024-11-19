-- RCYCG-DW01 - DEV
--USE tst_DW_ODS;
--GO

-- RCYAZ2-DW01 - PROD
USE prd_DW_ODS;
GO

ALTER VIEW dbo.vw_Sql_Job_History
AS
/* 
===============================================================================
OBJECT NAME	tst_DW_ODS.dbo.vw_Sql_Job_History
PURPOSE 	Show the history of SSIS jobs
ACCEPTS    	NONE
RETURNS		table
CALLED BY	Tableau Report
AUTHOR		Michael Mooney
CREATED		2021-11-23
===============================================================================
EXAMPLE CALLS:
-------------------------------------------------------------------------------
SELECT *	FROM	dbo.vw_Sql_Job_History;
===============================================================================
CHANGE LOG:
-------------------------------------------------------------------------------
Developer				Date		Ref#	Purpose		
--------------------	----------	-----	-----------------------------------
Michael Mooney			2021-11-23	0		Initial Commit

===============================================================================
*/


SELECT		  sysjobs.job_id
			, sysjobs.[name]										[Job Name]
			, sysjobs.[description]									[Job Description]
			, CASE	WHEN  sysjobs.[description] LIKE 'This job is owned by a report server process%'
						THEN 'Yes'
						ELSE 'No'
					END												[Is Report Server Job]
			, sysjobhistory.step_id
			, sysjobhistory.step_name
			, sysjobhistory.sql_severity
			, sysjobhistory.[message]
			, CASE	(sysjobhistory.run_status)
							WHEN 1 THEN 'The job succeeded'
							WHEN 0 THEN 'The job failed'
					  ELSE	'n/a'
					  END											AS Run_Status
			, sysjobhistory.run_date
			, sysjobhistory.run_time
			, msdb.dbo.agent_datetime(sysjobhistory.run_date
									,sysjobhistory.run_time)		AS Run_Date_Time
			, sysjobhistory.run_duration
			, sysjobhistory.[server]
FROM		msdb.dbo.sysjobs	sysjobs
			INNER JOIN msdb.dbo.sysjobhistory	sysjobhistory
				ON sysjobs.job_id = sysjobhistory.job_id
ORDER BY	sysjobhistory.job_id
			, sysjobhistory.instance_id

