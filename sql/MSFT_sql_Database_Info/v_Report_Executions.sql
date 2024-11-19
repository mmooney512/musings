CREATE VIEW dbo.v_Report_Execution
AS

/* 
===============================================================================
OBJECT NAME	SSRS.dbo.v_Report_Execution
PURPOSE 	Show the reports, and execution details of the report
ACCEPTS    	NONE
RETURNS		table
CALLED BY	Tableau Report
AUTHOR		Michael Mooney
CREATED		2021-12-01
===============================================================================
EXAMPLE CALLS:
-------------------------------------------------------------------------------
SELECT		* FROM SSRS.dbo.v_Report_Execution;
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
			
			-- ssrs_ExecutionLog ---------------------------------------------
			, CAST(ssrs_ExecutionLog.ByteCount AS FLOAT) / 1000.0			[Execution_KB_Size]
			, ssrs_ExecutionLog.ReportAction								[Execution_Report_Action]
			, ssrs_ExecutionLog.ReportPath									[Execution_Report_Path]
			, ssrs_ExecutionLog.RequestType									[Execution_Request_Type]
			, ssrs_ExecutionLog.[RowCount]									[Execution_Row_Count]
			, ssrs_ExecutionLog.[Source]									[Execution_Source]
			, ssrs_ExecutionLog.[Status]									[Execution_Status]
			, ssrs_ExecutionLog.TimeEnd										[Execution_Time_End]
			, ssrs_ExecutionLog.TimeStart									[Execution_Time_Start]
			, MAX(ssrs_ExecutionLog.TimeStart) OVER(PARTITION BY ssrs_catalog.ItemID)
																			[Execution_Last_Run_Date]
			, CAST(ssrs_ExecutionLog.TimeDataRetrieval AS FLOAT) / 1000.0	[Execution_Time_Data_Retrieval]
			, CAST(ssrs_ExecutionLog.TimeProcessing AS FLOAT) / 1000.0		[Execution_Time_Processing]
			, CAST(ssrs_ExecutionLog.TimeRendering AS FLOAT) / 1000.0		[Execution_Time_Rendering]
			, ssrs_ExecutionLog.UserName									[Execution_Domain_User_Name]
			,UPPER(SUBSTRING(UserName,PATINDEX('%\%', UserName)+1,512))		[Execution_User_Name]

FROM		dbo.Catalog		ssrs_catalog WITH (NOLOCK) 
			INNER JOIN dbo.ExecutionLog4 ssrs_ExecutionLog WITH (NOLOCK)
				ON ssrs_catalog.ItemID = ssrs_ExecutionLog.ReportID

WHERE		ssrs_catalog.[Type] = 2
;


