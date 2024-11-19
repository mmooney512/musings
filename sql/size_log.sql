-- SIZE LOG
SELECT	(size * 8.0)/1024.0				AS size_in_mb
		(size * 8.0)/1024.0 / 1024.0	AS size_in_gb
		,CASE	WHEN	max_size	= -1 
				THEN	9999999                  -- Unlimited growth, so handle this how you want
				ELSE	(max_size * 8.0)/1024.0            
		END										AS max_size_in_mb
		,CASE	WHEN	max_size	= -1 
				THEN	9999999                  -- Unlimited growth, so handle this how you want
				ELSE	(max_size * 8.0)/1024.0  / 1024               
		END										AS max_size_in_gb
FROM	CCR_Galt.sys.database_files
WHERE	data_space_id = 0           