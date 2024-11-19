CREATE VIEW dbo.v_Reports_Without_Executions
AS

/* 
===============================================================================
OBJECT NAME	SSRS.dbo.v_Reports_Without_Executions
PURPOSE 	Show the reports, and execution details of the report
ACCEPTS    	NONE
RETURNS		table
CALLED BY	Tableau Report
AUTHOR		Michael Mooney
CREATED		2021-12-01
===============================================================================
EXAMPLE CALLS:
-------------------------------------------------------------------------------
SELECT		* FROM SSRS.dbo.v_Reports_Without_Executions;
===============================================================================
CHANGE LOG:
-------------------------------------------------------------------------------
Developer				Date		Ref#	Purpose		
--------------------	----------	-----	-----------------------------------
Michael Mooney			2021-12-01	0		Initial Commit

===============================================================================
*/



SELECT		-- ssrs_Catalog --------------------------------------------------
			  ssrs_catalog.ItemID											[Report_ID]
			, ssrs_catalog.[Name]											[Report_Name]
			, CAST(ssrs_catalog.CreationDate AS DATE)						[Report_Creation_Date]
			, ssrs_catalog.[Description]									[Report_Description]
			, CAST(ssrs_catalog.ModifiedDate AS DATE)						[Report_Modified_Date]
FROM		dbo.Catalog		ssrs_catalog WITH (NOLOCK) 
			LEFT OUTER JOIN dbo.ExecutionLog4 ssrs_ExecutionLog WITH (NOLOCK)
				ON ssrs_catalog.ItemID = ssrs_ExecutionLog.ReportID
WHERE		ssrs_catalog.[Type] = 2
			AND ssrs_ExecutionLog.ReportID IS NULL
;