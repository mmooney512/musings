DECLARE @startDAte AS DateTime		= '2022-01-01'
DECLARE @enddate AS DateTime		= '2023-12-31 23:59:59'


SELECT			sq.[Name]
				, MIN(sq.TimeStart)		min_TimeStart
				, MAX(sq.TimeStart)		max_TimeStart
				, COUNT(*)				count_row
FROM			(

				SELECT c.Name,
					   e.Timestart,
					   e.TimeEnd,
					   e.UserName,
					   e.Status,
					   c.Description,
					   e.InstanceName,
					   e.ReportID,
					   e.TimeDataRetrieval,
					   e.TimeProcessing,
					   e.TimeRendering,
					   e.Source
				  FROM ssrs.dbo.ExecutionLog e
				INNER JOIN ssrs.dbo.Catalog c
					ON e.ReportID = c.ItemID
				 where timestart >=  @startdate
				   and timestart <=  @enddate
				   --AND c.Name = 'Flight_Manifest_DaysToSail'

				   AND e.UserName <> 'NT AUTHORITY\SYSTEM'
			) sq

GROUP BY		sq.Name
;

