SELECT	  SysJobs.NAME AS JobName
		, ReportSchedule.SubscriptionID
		, SSRS_Catalog.NAME
		, SSRS_Catalog.Path
		, Subscriptions.Description
		, Subscriptions.LastStatus
		, Subscriptions.EventType
		, Subscriptions.LastRunTime
		, SysJobs.date_created
		, SysJobs.date_modified

FROM	ssrs.dbo.ReportSchedule					AS ReportSchedule
		INNER JOIN msdb.dbo.sysjobs				AS SysJobs
		ON	CAST(ReportSchedule.ScheduleID AS SYSNAME) = SysJobs.NAME

		INNER JOIN ssrs.dbo.ReportSchedule		AS ReportSchedule_Name
		ON	SysJobs.NAME						= CAST(ReportSchedule_Name.ScheduleID AS SYSNAME)

		INNER JOIN ssrs.dbo.Subscriptions		AS Subscriptions
		ON	ReportSchedule_Name.SubscriptionID	= Subscriptions.SubscriptionID

		INNER JOIN SSRS.dbo.CATALOG				AS SSRS_Catalog
		ON	Subscriptions.Report_OID			= SSRS_Catalog.ItemID


WHERE	SSRS_Catalog.NAME LIKE '%QA Staging SSIS Job Monitor%'
;

USE SSRS
EXEC ssrs.dbo.AddEvent @EventType = N'TimedSubscription'		
					   , @EventData = N'C75635B5-49C6-416B-8335-CA9736F6BADD'
;
