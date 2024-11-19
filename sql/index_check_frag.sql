use ddReports;
-- Check the index fragmentation again
SELECT
    [avg_fragmentation_in_percent]
FROM sys.dm_db_index_physical_stats 
	(DB_ID (N'ddReports')
    , OBJECT_ID (N'tblEMDLog_ChangeRequest'), 1, NULL, 'LIMITED');
GO