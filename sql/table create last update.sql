USE		dgSAP;
SELECT	name, create_date, modify_date 
FROM	sys.objects 
WHERE	name = 'mara'
GO

USE		ddSandBox;
SELECT 	OBJECT_NAME(OBJECT_ID) AS DatabaseName
		,last_user_update
		,*

FROM 	sys.dm_db_index_usage_stats

WHERE 	database_id = DB_ID('ddSandBox')
		AND OBJECT_ID=OBJECT_ID('bom_deposit')