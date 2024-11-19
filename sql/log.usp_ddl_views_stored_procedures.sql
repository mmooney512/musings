USE prd_staging;
go

CREATE PROC [log].[usp_ddl_views_stored_procedures]

AS

/* 
===============================================================================
OBJECT NAME	log.usp_ddl_views_stored_procedures
PURPOSE 	backup DDL for views and stored procedures
ACCEPTS    	
RETURNS		NONE
USES		        
CALLED BY	sql server agent job - DAILY
AUTHOR		
CREATED		2022-06-13
===============================================================================
EXAMPLE CALLS:
-------------------------------------------------------------------------------
EXEC log.usp_ddl_views_stored_procedures;
===============================================================================
CHANGE LOG:
-------------------------------------------------------------------------------
Developer				Date		Ref#	Purpose		
--------------------	----------	-----	-----------------------------------
Michael Mooney			2022-06-13			Initial Commit

===============================================================================
*/


BEGIN
	SET ANSI_NULLS ON  
	SET NOCOUNT ON;  
	SET XACT_ABORT ON;  
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	BEGIN TRY
		
				INSERT INTO log.DatabaseLog
				(
					  PostTime
					, DatabaseUser
					, [Event]
					, [Schema]
					, [Object]
					, [TSQL]
					, XmlEvent
				)
				SELECT		GETDATE()							[PostTime]
							, SYSTEM_USER						[DatabaseUser]
							, 'BACKUP'							[Event]
							, sys_schemas.name					[Schema]
							, sys_procedures.[name]				[Object]
							, sys_sql_modules.definition		[TSQL]
							, CAST(CONCAT('<dates>'
										,'<create_date>'
										,CONVERT(NVarchar(32), sys_procedures.create_date, 20) 
										,'</create_date>'
										,'<modify_date>', 
										CONVERT(NVarchar(32), sys_procedures.create_date, 20) 
										,'</modify_date>'
										,'</dates>'
										)AS Xml)				[XML]

				FROM		sys.procedures						AS sys_procedures
							INNER JOIN	sys.sql_modules			AS sys_sql_modules
							ON sys_procedures.object_id			= sys_sql_modules.object_id
							INNER JOIN	sys.objects				AS sys_objects
							ON sys_procedures.object_id			= sys_objects.object_id
							INNER JOIN	sys.schemas				AS sys_schemas
							ON sys_objects.schema_id			= sys_schemas.schema_id
			
				WHERE		sys_sql_modules.execute_as_principal_id IS NULL
				;


				INSERT INTO log.DatabaseLog
				(
					  PostTime
					, DatabaseUser
					, [Event]
					, [Schema]
					, [Object]
					, [TSQL]
					, XmlEvent
				)
				SELECT		GETDATE()							[PostTime]
							, SYSTEM_USER						[DatabaseUser]
							, 'BACKUP'							[Event]
							, sys_schemas.name					[Schema]
							, sys_views.[name]					[Object]
							, sys_sql_modules.definition		[TSQL]
							, CAST(CONCAT('<dates>'
										,'<create_date>'
										,CONVERT(NVarchar(32), sys_views.create_date, 20) 
										,'</create_date>'
										,'<modify_date>', 
										CONVERT(NVarchar(32), sys_views.create_date, 20) 
										,'</modify_date>'
										,'</dates>'
										)AS Xml)				[XML]

				FROM		sys.views							AS sys_views
							INNER JOIN	sys.sql_modules			AS sys_sql_modules
							ON sys_views.object_id				= sys_sql_modules.object_id
							INNER JOIN	sys.objects				AS sys_objects
							ON sys_views.object_id				= sys_objects.object_id
							INNER JOIN	sys.schemas				AS sys_schemas
							ON sys_objects.schema_id			= sys_schemas.schema_id
				WHERE		sys_sql_modules.execute_as_principal_id IS NULL
				;


	END TRY
	BEGIN CATCH

		IF (XACT_STATE()) = -1
		BEGIN
			PRINT 'The transaction is in an uncommittable state. Rolling back transaction.';
			ROLLBACK TRANSACTION;
		END;

		-- Test whether the transaction is active and valid.  
		IF (XACT_STATE()) = 1
		BEGIN
			COMMIT TRANSACTION;
		END;
		THROW;
	END CATCH;
END;
GO


