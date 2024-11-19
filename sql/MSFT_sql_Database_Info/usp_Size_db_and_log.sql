ALTER		PROCEDURE 	dbo.usp_Size_Db_And_Log
AS
/* 
===============================================================================
OBJECT NAME	tst_DW_ODS.dbo.usp_Size_Db_And_Log
PURPOSE 	Show the size in MB and GB of the database and log files
ACCEPTS    	NONE
RETURNS		table
CALLED BY	Tableau Report
AUTHOR		Michael Mooney
CREATED		2021-11-23
===============================================================================
EXAMPLE CALLS:
-------------------------------------------------------------------------------
EXEC		dbo.usp_Size_Db_And_Log;
===============================================================================
CHANGE LOG:
-------------------------------------------------------------------------------
Developer				Date		Ref#	Purpose		
--------------------	----------	-----	-----------------------------------
Michael Mooney			2021-11-23	0		Initial Commit

===============================================================================
*/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
SET XACT_ABORT ON;	--Rollback the transaction automatically if a run-time error is encountered

DECLARE		@sql_command	varchar(8000)	= '';

IF OBJECT_ID('tempdb..#db_size') IS NOT NULL
	BEGIN
		DROP TABLE #db_size;
	END

CREATE TABLE	#db_size
				( ServerName			varchar(255)
				, UserDBName			varchar(255)
				, [FileName]			varchar(4000)
				, UsedSpaceSizeInMB		float
				, AvailableSpaceInMB	float
				, UsedSpaceSizeInGB		float
				, AvailableSpaceInGB	float
				)


set @sql_command = 'USE ?
					INSERT INTO #db_size
					SELECT		@@SERVERNAME			AS ServerName
								,DB_NAME()				AS [Database_Name]
								,name					AS [FileName]
								,size/128.0				AS UsedSpaceSizeInMB
								,size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS int)/128.0 AS AvailableSpaceInMB

								,size/128.0/1024.0		AS UsedSpaceSizeInGB
								,size/128.0/1024.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS int)/128.0/1024.0 AS AvailableSpaceInGB
					FROM		sys.database_files;
					'
exec sp_MSforeachdb @sql_command

SELECT		ServerName		
			, UserDBName	
			, [FileName]			
			, UsedSpaceSizeInMB		
			, AvailableSpaceInMB	
			, UsedSpaceSizeInGB		
			, AvailableSpaceInGB	
FROM		#db_size
ORDER BY	 UserDBName
;

DROP TABLE	#db_size;
SET NOCOUNT OFF;



