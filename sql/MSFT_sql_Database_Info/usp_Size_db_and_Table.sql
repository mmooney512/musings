
CREATE		PROCEDURE 	dbo.usp_Size_Db_And_Table
AS
/* 
===============================================================================
OBJECT NAME	prd_DW_ODS.dbo.usp_Size_Db_And_Table
PURPOSE 	Show the size of tables in database in MB
ACCEPTS    	NONE
RETURNS		table
CALLED BY	Tableau Report
AUTHOR		Michael Mooney
CREATED		2021-11-23
===============================================================================
EXAMPLE CALLS:
-------------------------------------------------------------------------------
EXEC		dbo.usp_Size_Db_And_Table;
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

IF OBJECT_ID('tempdb..#db_table_size') IS NOT NULL
	BEGIN
		DROP TABLE #db_table_size;
	END

CREATE TABLE	#db_table_size
				( ServerName		varchar(255)
				, UserDBName		varchar(255)
				, SchemaName		varchar(255)
				, TableName			varchar(255)
				, RowCounts			bigint
				, TotalSpaceMB		float
				, UsedSpaceMB		float
				, UnusedSpaceMB		float
				)

			set @sql_command = 'USE ?
			INSERT INTO #db_table_size
			SELECT		@@SERVERNAME						AS ServerName
						,db_name()							AS UserDBName
						,sysschema.name						AS SchemaName
						,systables.name						AS TableName
						,syspartitions.rows					AS RowCounts

						,ROUND(CAST(SUM(sysalloc.total_pages) * ((8.0 / 1024.0)) AS FLOAT),2)	AS TotalSpaceMB
						,ROUND(CAST(SUM(sysalloc.used_pages)  * (8.0 / 1024.0) AS FLOAT),2)		AS UsedSpaceMB
						,ROUND(CAST((SUM(sysalloc.total_pages) - SUM(sysalloc.used_pages)) 
						* (8.0 / 1024.0) AS FLOAT),2)				AS UnusedSpaceMB
		
			FROM		sys.tables AS  systables
						INNER JOIN	sys.indexes AS sysindex 
							ON systables.OBJECT_ID = sysindex.object_id
						INNER JOIN sys.partitions AS syspartitions 
							ON sysindex.object_id = syspartitions.OBJECT_ID 
							AND sysindex.index_id = syspartitions.index_id
						INNER JOIN sys.allocation_units AS sysalloc 
							ON syspartitions.partition_id = sysalloc.container_id
						LEFT OUTER JOIN sys.schemas AS sysschema 
							ON systables.schema_id = sysschema.schema_id

			WHERE		systables.is_ms_shipped = 0
						AND sysindex.OBJECT_ID > 255 
						--AND systables.NAME  LIKE ''USM_%''

			
			GROUP BY	systables.name, sysschema.name, syspartitions.rows	

			ORDER BY	SchemaName, TableName
			;'

			exec sp_MSforeachdb @sql_command


SELECT		ServerName
			, UserDBName
			, SchemaName			
			, TableName			
			, RowCounts			
			, TotalSpaceMB		
			, UsedSpaceMB		
			, UnusedSpaceMB		
FROM		#db_table_size
ORDER BY	  UserDBName
			, [SchemaName]
			, TableName
;

DROP TABLE	#db_table_size;
SET NOCOUNT OFF;


