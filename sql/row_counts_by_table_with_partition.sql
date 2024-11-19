
SELECT		sysobjects.object_id, sysObjects.Name, sum(dbStats.row_count) as countRows
FROM		sys.objects	AS sysObjects
			INNER JOIN sys.dm_db_partition_stats AS dbStats 
				on sysObjects.object_id = dbStats.object_id
WHERE		sysObjects.type = 'U'
GROUP BY	sysobjects.object_id, sysObjects.Name
ORDER BY	sysObjects.Name;