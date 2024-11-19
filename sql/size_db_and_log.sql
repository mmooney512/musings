-- ---------------------------------------------------------------------------
-- SIZE OF ONE DATABASE
-- ---------------------------------------------------------------------------

USE			DW_Sales;

SELECT		DB_NAME()				AS [Database_Name]
			,name					AS [FileName]
			,size/128.0				AS UsedSpaceSizeInMB
			,size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS AvailableSpaceInMB

			,size/128.0/1024.0		AS UsedSpaceSizeInGB
			,size/128.0/1024.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0/1024.0 AS AvailableSpaceInGB
			
FROM		sys.database_files	dfiles
;


-- ---------------------------------------------------------------------------
-- SIZE OF ALL DATABASES
-- ---------------------------------------------------------------------------

DROP	TABLE IF EXISTS	#FileSize;

CREATE TABLE #FileSize
(
	dbName					NVarchar(128)
	, DB_FileName			NVarchar(128)
	, DB_Type				NVarchar(128)
	, Used_Space_MB			Decimal(10, 2)
	, Available_Space_MB	Decimal(10, 2)
	, Used_Space_GB			Decimal(10, 2)
	, Available_Space_GB	Decimal(10, 2)
);

INSERT INTO #FileSize
		(dbName, DB_FileName, DB_Type, Used_Space_MB
			, Available_Space_MB,Used_Space_GB, Available_Space_GB
		)
exec sp_msforeachdb 
'use [?]; 
SELECT	DB_NAME()															AS DBName
		, name																AS DB_FileName
		, type_desc															AS DB_Type
		, size / 128.0														AS Used_Space_MB
		, size / 128.0 
		- CAST(FILEPROPERTY(name, ''SpaceUsed'') AS Int) / 128.0				AS Available_Space_MB
		, size / 128.0 / 1024.0												  AS Used_Space_GB
		, size / 128.0 / 1024.0 
		- CAST(FILEPROPERTY(name, ''SpaceUsed'') AS Int) / 128.0 / 1024.0	  AS Available_Space_GB
FROM	sys.database_files
WHERE	type IN (0, 1);
'
    
SELECT * 
FROM #FileSize
WHERE dbName NOT IN ('distribution', 'master', 'model', 'msdb')
ORDER BY dbName, DB_Type DESC
;
    
DROP TABLE #FileSize;