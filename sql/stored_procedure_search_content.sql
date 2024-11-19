USE		AllUserDataReplica;


SELECT		DISTINCT
			sys_objects.name			AS		sp_Object_Name
			,sys_objects.type_desc		AS		type_desc
			,

FROM		sys.sql_modules				AS sys_sql_modules 
			INNER JOIN	sys.objects		AS sys_objects
				ON sys_sql_modules.object_id = sys_objects.object_id
 
 WHERE		sys_objects.[definition] Like '%%';