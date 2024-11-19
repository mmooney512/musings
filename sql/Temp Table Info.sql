USE tempdb
GO

 SELECT FileName = df.name,
   current_file_size_MB = df.size*1.0/128,
   max_size = CASE df.max_size
     WHEN 0 THEN 'Autogrowth is off.'
     WHEN -1 THEN 'Autogrowth is on.'
     ELSE 'Log file grows to a maximum size of 2 TB.'
   END,
   growth_value =
     CASE
       WHEN df.growth = 0 THEN df.growth
       WHEN df.growth > 0 AND df.is_percent_growth = 0 THEN df.growth*1.0/128.0
       WHEN df.growth > 0 AND df.is_percent_growth = 1 THEN df.growth
     END,
   growth_increment_unit =
     CASE
       WHEN df.growth = 0 THEN 'Size is fixed.'
       WHEN df.growth > 0 AND df.is_percent_growth = 0  THEN 'Growth value is MB.'
       WHEN df.growth > 0 AND df.is_percent_growth = 1  THEN 'Growth value is a percentage.'
     END
FROM tempdb.sys.database_files AS df;
GO

-- Determining the amount of space used by user objects
SELECT SUM(user_object_reserved_page_count) AS [user object pages used],
  (SUM(user_object_reserved_page_count)*1.0/128) AS [user object space in MB]
FROM tempdb.sys.dm_db_file_space_usage;

 -- Determining the amount of free space in tempdb
SELECT SUM(unallocated_extent_page_count) AS [free pages],
  (SUM(unallocated_extent_page_count)*1.0/128) AS [free space in MB]
FROM tempdb.sys.dm_db_file_space_usage;

-- Determining the amount of space used by the version store
SELECT SUM(version_store_reserved_page_count) AS [version store pages used],
  (SUM(version_store_reserved_page_count)*1.0/128) AS [version store space in MB]
FROM tempdb.sys.dm_db_file_space_usage;

-- Determining the amount of space used by internal objects
SELECT SUM(internal_object_reserved_page_count) AS [internal object pages used],
  (SUM(internal_object_reserved_page_count)*1.0/128) AS [internal object space in MB]
FROM tempdb.sys.dm_db_file_space_usage;



--Check sys.master_files in master
USE master
GO
SELECT DataFileName = mf.name, 
       FileSizeMB  = mf.size*8/1024
FROM sys.master_files AS mf
WHERE mf.database_id = db_id('tempdb')
ORDER BY mf.type, file_id;
GO
--Check sys.database_files in tempdb
USE tempdb
GO
SELECT DataFileName = dbf.name, 
       FileSizeMB  = dbf.size*8/1024
FROM sys.database_files AS dbf
ORDER BY dbf.type, dbf.file_id;


--CHECKPOINT;
--DBCC DROPCLEANBUFFERS;
--GO

--DBCC FREEPROCCACHE;
--GO