USE		ddreports;

SELECT		m.definition    
FROM		sys.views AS v
			INNER JOIN sys.sql_modules AS m 
				ON m.object_id = v.object_id
WHERE		v.name = 'mara'