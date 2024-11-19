-- ---------------------------------------------------------------------------
-- option one
-- ---------------------------------------------------------------------------
IF	EXISTS
	(SELECT			sys_tables.object_id
	FROM			sys.tables		sys_tables
	WHERE			[type]		= N'U'
					AND [name] = 'DatabaseLog'
					AND SCHEMA_NAME(schema_id) = 'log'
	)
	BEGIN
		SELECT 1 AS one
	END
;


-- ---------------------------------------------------------------------------
-- option two
-- ---------------------------------------------------------------------------
IF	EXISTS
	(SELECT			*
	FROM			INFORMATION_SCHEMA.TABLES
	WHERE			TABLE_TYPE		= 'BASE TABLE'
					AND [TABLE_NAME] = 'DatabaseLog'
					AND [TABLE_SCHEMA] = 'log'
	)
	BEGIN
		SELECT 1 AS one
	END
;



BEGIN TRY
		IF EXISTS
		(SELECT * FROM sys.objects 
		WHERE object_id = OBJECT_ID(N'[CUIC].[Media_Routing_Domain]') AND type IN (N'U')
		)
		BEGIN

			DROP TABLE dbo.temp;

		END

END TRY
BEGIN CATCH
    -- Execute the error retrieval routine.
        SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() as ErrorState,
        ERROR_PROCEDURE() as ErrorProcedure,
        ERROR_LINE() as ErrorLine,
        ERROR_MESSAGE() as ErrorMessage;
END CATCH;



