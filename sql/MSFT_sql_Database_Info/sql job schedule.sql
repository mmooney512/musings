-- RCYCG-DW01
--USE tst_DW_ODS;
--GO


-- RCYAZ2-DW01
USE prd_DW_ODS;
GO


ALTER VIEW dbo.vw_Sql_Job_Schedule
AS
/* 
===============================================================================
OBJECT NAME	prd_DW_ODS.dbo.vw_Sql_Job_Schedule
PURPOSE 	Show the size of tables in database in MB
ACCEPTS    	NONE
RETURNS		table
CALLED BY	Tableau Report
AUTHOR		Michael Mooney
CREATED		2021-11-23
===============================================================================
EXAMPLE CALLS:
-------------------------------------------------------------------------------
SELECT *	FROM	dbo.vw_Sql_Job_Schedule;
===============================================================================
CHANGE LOG:
-------------------------------------------------------------------------------
Developer				Date		Ref#	Purpose		
--------------------	----------	-----	-----------------------------------
Michael Mooney			2021-11-23	0		Initial Commit

===============================================================================
*/


WITH			cte_WeeklySchedule(schedule_id, days_of_week)
AS
(		SELECT	sq.schedule_id
				, CONCAT(sq.D1,SQ.D2,SQ.D3,SQ.D4,SQ.D5,SQ.D6,SQ.D7)		days_of_week
		FROM	(
				select	  sysschedules.schedule_id
						, CASE WHEN (freq_interval & 1  <> 0) then 'Sun '  ELSE '' END	[D1]
						, CASE WHEN (freq_interval & 2  <> 0) then 'Mon '  ELSE '' END	[D2]
						, CASE WHEN (freq_interval & 4  <> 0) then 'Tue '  ELSE '' END	[D3]
						, CASE WHEN (freq_interval & 8  <> 0) then 'Wed '  ELSE '' END	[D4]
						, CASE WHEN (freq_interval & 16 <> 0) then 'Thu '  ELSE '' END	[D5]
						, CASE WHEN (freq_interval & 32 <> 0) then 'Fri '  ELSE '' END	[D6]
						, CASE WHEN (freq_interval & 64 <> 0) then 'Sat '  ELSE '' END	[D7]
				FROM	msdb.dbo.sysschedules sysschedules
				WHERE	sysschedules.freq_type = 8
				) sq
)

,				cte_PeriodSchedule
AS
(		SELECT	sysschedules.schedule_id
				, CASE (sysschedules.freq_relative_interval)
					WHEN 1	THEN 'First'
					WHEN 2	THEN 'Second'
					WHEN 4	THEN 'Third'
					WHEN 8	THEN 'Fourth'
					WHEN 16 THEN 'Last'
					ELSE		 'N/A'
					END								relative_frequency
				, CASE (sysschedules.freq_interval)
                    WHEN 1	THEN ' Sun'
                    WHEN 2	THEN ' Mon'
                    WHEN 3	THEN ' Tue'
                    WHEN 4	THEN ' Wed'
                    WHEN 5	THEN ' Thu'
                    WHEN 6	THEN ' Fri'
                    WHEN 7	THEN ' Sat'
                    WHEN 8	THEN ' Day'
                    WHEN 9	THEN ' Weekday'
                    WHEN 10	THEN ' Weekend'
                    ELSE		 ' N/A'
                    END								week_day
		FROM	msdb.dbo.sysschedules sysschedules
		WHERE	sysschedules.freq_type = 32

)
,					cte_LastRunDate
AS
(		SELECT		sysjobhistory.job_id							AS Job_Id
					, sysjobhistory.run_duration					AS Run_Duration
					, CASE	(sysjobhistory.run_status)
							WHEN 1 THEN 'The job succeeded'
							WHEN 0 THEN 'The job failed'
					  ELSE	'n/a'
					  END											AS Run_Status
					, sq.max_Last_Run_Date_Time						AS Last_Run_Date_Time


		FROM		msdb.dbo.sysjobhistory	sysjobhistory
					INNER JOIN
					(
					SELECT		  sysjobhistory.job_id				AS Job_Id
								, MAX(sysjobhistory.instance_id) 	AS max_Instance_Id
								, MAX(TRY_CAST(CONCAT(CONVERT(date, CONVERT(VARCHAR(8), sysjobhistory.run_date))
													,' '
													,FORMAT(sysjobhistory.run_time, '00:00:00')
									) AS datetime))					AS max_Last_Run_Date_Time
								, sum(sysjobhistory.run_duration)	AS sum_rd
								, max(sysjobhistory.instance_id)	AS max_id
					FROM		msdb.dbo.sysjobhistory	sysjobhistory

					GROUP BY	sysjobhistory.job_id
					) sq
						ON sysjobhistory.instance_id = sq.max_Instance_Id
)

SELECT			-- sysjobs ---------------------------------------------------
				  sysjobs.job_id					[Job_Id]
				, sysjobs.[name]					[Job Name]
				, sysjobs.[description]				[Job Description]
				, sysjobs.[enabled]					[Job Enabled]
				, sysjobs.date_modified				[Job Last Modified Date]
				, CASE	WHEN  sysjobs.[description] LIKE 'This job is owned by a report server process%'
						THEN 'Yes'
						ELSE 'No'
					END								[Is Report Server Job]

				-- sysjobschedules -------------------------------------------
				, CASE	WHEN ISNULL(freq_subday_type, -1) >= 0
						THEN CONCAT(FORMAT(sysjobschedules.next_run_date,'0000-00-00')
							,' '
							,FORMAT(sysjobschedules.next_run_time , '00:00:00'))	
						ELSE 'N/A'
						END							[Next Run Time]
				-- sysschedules ----------------------------------------------
				, CASE(sysschedules.freq_type)
						WHEN 1	THEN 'ONCE'
						WHEN 4	THEN 'DAILY'
						WHEN 8	THEN 
								CASE WHEN	sysschedules.freq_recurrence_factor > 1 
									 THEN	'Every ' + convert(varchar(3),sysschedules.freq_recurrence_factor) + ' Weeks'  
									 ELSE	'Weekly'  
								END
						WHEN 16	THEN 
								CASE WHEN	sysschedules.freq_recurrence_factor > 1 
									 THEN	'Every ' + convert(varchar(3),sysschedules.freq_recurrence_factor) + ' Months'  
									 ELSE	'Monthly'  
								END
						WHEN 32 THEN 'Every ' + convert(varchar(3),sysschedules.freq_recurrence_factor) + ' Months' -- RELATIVE
						WHEN 64 THEN 'SQL Startup'
						WHEN 128 THEN 'SQL Idle'
						ELSE 'N/A'
				  END								[Frequency]
				, CASE(sysschedules.freq_type)
						WHEN 1	THEN 'One Time Only'
						WHEN 4	THEN
								CASE(sysschedules.freq_interval)
									WHEN 1	THEN 'Every Day'
									ELSE 'Every ' + CONVERT(VARCHAR(10), sysschedules.freq_interval) + ' Days'
								END
						WHEN 8	THEN ISNULL(cte_WeeklySchedule.days_of_week, 'n/a')
						WHEN 16	THEN 'Day ' + CONVERT(VARCHAR(2),sysschedules.freq_interval) 
						WHEN 32 THEN CONCAT(cte_PeriodSchedule.relative_frequency, cte_PeriodSchedule.week_day)
						ELSE 'N/A'
				END									[Interval]
				, CASE(sysschedules.freq_subday_type)
						WHEN 1 THEN FORMAT(sysschedules.active_start_time, '00:00:00')
						WHEN 2 THEN 'Every ' + convert(varchar(10),sysschedules.freq_subday_interval) + ' seconds'
						WHEN 4 THEN 'Every ' + convert(varchar(10),sysschedules.freq_subday_interval) + ' minutes'
						WHEN 8 THEN 'Every ' + convert(varchar(10),sysschedules.freq_subday_interval) + ' hours'
						ELSE 'N/A'
				  END								[Run Time]
				-- cte_LastRunDate -------------------------------------------
				, cte_LastRunDate.last_run_date_time	[Last Run Date Time]
				, cte_LastRunDate.Run_Duration			[Run Duration]
				, cte_LastRunDate.Run_Status			[Run Status]


FROM			msdb.dbo.sysjobs	sysjobs
				LEFT OUTER JOIN msdb.dbo.sysjobschedules sysjobschedules
					ON sysjobs.job_id = sysjobschedules.job_id
				LEFT OUTER JOIN msdb.dbo.sysschedules	sysschedules
					ON sysjobschedules.schedule_id = sysschedules.schedule_id
				LEFT OUTER JOIN cte_WeeklySchedule
					ON sysschedules.schedule_id = cte_WeeklySchedule.schedule_id
				LEFT OUTER JOIN cte_PeriodSchedule
					ON sysschedules.schedule_id = cte_PeriodSchedule.schedule_id
				LEFT OUTER JOIN cte_LastRunDate
					ON sysjobschedules.job_id = cte_LastRunDate.job_id


;


