select
			 name
			,enabled
			,description
from		msdb.dbo.sysjobs

select		 name
			,enabled
			,freq_type
			,freq_interval
			,freq_subday_type
			,freq_subday_interval
			,freq_recurrence_factor  
from		msdb.dbo.sysschedules


select		name
			,enabled
			,description
from		msdb.dbo.sysjobs
			inner join msdb.dbo.sysjobschedules 
				on sysjobs.job_id = sysjobschedules.job_id
order by	enabled desc




-- list jobs and schedule info with daily and weekly schedules

-- jobs with a daily schedule
select			sysjobs.name							[Job Name]
				,sysjobs.description					[Job Description]
				, CASE WHEN  sysjobs.[description] LIKE 'This job is owned by a report server process%'
						THEN 'Yes'
						ELSE 'No'
				 END									[Is Report Server Job]
				,sysjobs.enabled						[Job Enabled]
				,sysschedules.name						[Schedule Name]
				,sysschedules.freq_recurrence_factor	[Recurrence Factor]
				,case	when freq_type = 4 
						then 'Daily'
				end										[Frequency]
				,'every ' + cast (freq_interval as varchar(3)) + ' day(s)'  [Schedule Days]
				, case	when freq_subday_type = 2 
						then	' every ' + cast(freq_subday_interval as varchar(7)) 
								+ ' seconds' + ' starting at '
								+ stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
						when freq_subday_type = 4 
						then	' every ' + cast(freq_subday_interval as varchar(7)) 
								+ ' minutes' + ' starting at '
								+ stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
						when freq_subday_type = 8 
						then	' every ' + cast(freq_subday_interval as varchar(7)) 
								+ ' hours'   + ' starting at '
								+ stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
						else	' starting at ' 
								+ stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
						end [Schedule Time]

from			msdb.dbo.sysjobs
				inner join msdb.dbo.sysjobschedules 
					on sysjobs.job_id = sysjobschedules.job_id
				inner join msdb.dbo.sysschedules 
					on sysjobschedules.schedule_id = sysschedules.schedule_id
where			freq_type = 4

union

-- jobs with a weekly schedule
select			sysjobs.name							[Job Name]
				, sysjobs.description					[Job Description]
				, CASE WHEN  sysjobs.[description] LIKE 'This job is owned by a report server process%'
						THEN 'Yes'
						ELSE 'No'
				 END									[Is Report Server Job]
				, sysjobs.enabled						[Job Enabled]
				, sysschedules.name						[Schedule Name]
				, sysschedules.freq_recurrence_factor	[Recurrence Factor]
				, case	when freq_type = 8 
						then 'Weekly'
				  end									[Frequency]
				, replace
					(
					 CASE WHEN freq_interval&1 = 1 THEN 'Sunday, ' ELSE '' END
					+CASE WHEN freq_interval&2 = 2 THEN 'Monday, ' ELSE '' END
					+CASE WHEN freq_interval&4 = 4 THEN 'Tuesday, ' ELSE '' END
					+CASE WHEN freq_interval&8 = 8 THEN 'Wednesday, ' ELSE '' END
					+CASE WHEN freq_interval&16 = 16 THEN 'Thursday, ' ELSE '' END
					+CASE WHEN freq_interval&32 = 32 THEN 'Friday, ' ELSE '' END
					+CASE WHEN freq_interval&64 = 64 THEN 'Saturday, ' ELSE '' END
					,', '
					,''
					)									[Schedule Days]
					,
					case when freq_subday_type = 2 then ' every ' + cast(freq_subday_interval as varchar(7)) 
							+ ' seconds' + ' starting at '
							+ stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 
						 when freq_subday_type = 4 then ' every ' + cast(freq_subday_interval as varchar(7)) 
							+ ' minutes' + ' starting at '
							+ stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
					when freq_subday_type = 8 then ' every ' + cast(freq_subday_interval as varchar(7)) 
							 + ' hours'   + ' starting at '
							 + stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
					 else ' starting at ' 
							+ stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
					end									[Schedule Time]
from			msdb.dbo.sysjobs
				inner join msdb.dbo.sysjobschedules 
					on sysjobs.job_id = sysjobschedules.job_id
				inner join msdb.dbo.sysschedules 
					on sysjobschedules.schedule_id = sysschedules.schedule_id

where			freq_type = 8

order by		[Job Name] desc

;



WITH			cte_Job
AS
(
		SELECT			  sysjobs.job_id
						, sysjobs.[name]					[Job Name]
						, sysjobs.[description]				[Job Description]
						, sysjobs.[enabled]					[Job Enabled]
						, sysjobs.date_modified				[Job Last Modified Date]
						, CASE	WHEN  sysjobs.[description] LIKE 'This job is owned by a report server process%'
								THEN 'Yes'
								ELSE 'No'
						 END									[Is Report Server Job]
		FROM			msdb.dbo.sysjobs	sysjobs
		
)
,				cte_sysjobschedules
AS
(
SELECT			sysjobschedules.job_id
				, sysjobschedules.schedule_id
				, sysjobschedules.next_run_date
				, sysjobschedules.next_run_time

FROM			msdb.dbo.sysjobschedules			sysjobschedules
)
,				cte_schedule_daily
AS
(				SELECT		*
							, sysschedules.schedule_id
							, CASE	WHEN sysschedules.freq_type = 4 
									THEN 'Daily'
									WHEN sysschedules.freq_type = 8 
									THEN 'Weekly'
									WHEN sysschedules.freq_type = 16 
									THEN 'Monthly'
									WHEN sysschedules.freq_type = 64
									THEN '64'
							  END										[Frequency]
				FROM		msdb.dbo.sysschedules sysschedules
				WHERE		sysschedules.freq_interval = 4
)


SELECT			*
FROM			cte_job
				LEFT OUTER JOIN cte_sysjobschedules
					ON cte_Job.job_id = cte_sysjobschedules.job_id


;

