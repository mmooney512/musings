USE DW_Sales
GO

--SELECT			TOP (100)
--				*
--FROM			log.Database_Log
--WHERE			[Object] = 'usp_Voyage_Status'
--				AND [Event] IN ('CREATE_PROCEDURE'
--				, 'ALTER_PROCEDURE')
--ORDER BY		Database_Log_Id
;

SELECT			all_proc.SPECIFIC_SCHEMA
				,all_proc.SPECIFIC_NAME
				, c_log.[Event]
				, c_log.last_Post_Time		create_time

				, a_log.[Event]
				, a_log.last_Post_Time		alter_time

				, CASE	WHEN COALESCE(a_log.last_Post_Time, c_log.last_Post_Time)	<= '2024-01-10'
						THEN 'OK'
						WHEN COALESCE(a_log.last_Post_Time, c_log.last_Post_Time)	>  '2024-01-17 10:30:00'
						THEN 'UPDATED'
						ELSE 'CHECK'
						END					Update_Proc
FROM			INFORMATION_SCHEMA.ROUTINES		all_proc
				LEFT JOIN

				(
				SELECT			create_log.[Event]
								, create_log.[Schema]
								, create_log.[Object]
								, MAX(create_log.Post_Time)			last_Post_Time
				FROM			log.Database_Log					create_log
				WHERE			create_log.[Schema] IN ('dbo', 'etl', 'incontact', 'resco')
								AND [Event] = 'CREATE_PROCEDURE'
								
				GROUP BY		create_log.[Event]
								, create_log.[Schema]
								, create_log.[Object]
				) c_log
				ON all_proc.SPECIFIC_SCHEMA = c_log.[Schema]
				AND all_proc.SPECIFIC_NAME	= c_log.[Object]

				LEFT OUTER JOIN
				(
				SELECT			alter_log.[Event]
								, alter_log.[Schema]
								, alter_log.[Object]
								, MAX(alter_log.Post_Time)			last_Post_Time
				FROM			log.Database_Log					alter_log
				WHERE			alter_log.[Schema] IN ('dbo', 'etl', 'incontact', 'resco')
								AND [Event] = 'ALTER_PROCEDURE'
								--AND alter_log.Post_Time <= '2024-01-17 13:00:00'
				GROUP BY		alter_log.[Event]
								, alter_log.[Schema]
								, alter_log.[Object]
				) a_log
				ON all_proc.SPECIFIC_SCHEMA	= a_log.[Schema]
				AND all_proc.SPECIFIC_NAME	= a_log.[Object]

WHERE			all_proc.SPECIFIC_SCHEMA IN ('dbo', 'etl', 'incontact', 'resco')

ORDER BY		all_proc.SPECIFIC_SCHEMA
				, all_proc.SPECIFIC_NAME
;

