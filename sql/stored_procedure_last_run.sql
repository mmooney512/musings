DECLARE		@database_name			Varchar(64) = 'DW_Sales'
DECLARE		@stored_procedure_name	Varchar(64) = 'x'

SELECT		  proc_stats.object_id
			, DB_NAME(proc_stats.database_id)			'Database_Name'
			, OBJECT_NAME(object_id, database_id)	   'proc name'
			, proc_stats.cached_time
			, proc_stats.last_execution_time
			, proc_stats.total_elapsed_time
			--, proc_stats.total_elapsed_time / proc_stats.execution_count AS [avg_elapsed_time]
			, CAST(((proc_stats.total_elapsed_time / proc_stats.execution_count) / 1000000.0) AS Decimal(7,3)) AS [avg_elapsed_time]
			, proc_stats.last_elapsed_time
			, CAST((last_elapsed_time / 1000000.0) AS Decimal(7,3))  AS last_elapsed_time_Seconds
			, proc_stats.execution_count
FROM		sys.dm_exec_procedure_stats AS proc_stats 
WHERE		DB_NAME(database_id) LIKE '%' + @database_name + '%'
			--AND OBJECT_NAME(object_id, database_id) LIKE '%' + @stored_procedure_name + '%'
ORDER BY	Database_Name, [total_worker_time] DESC
;