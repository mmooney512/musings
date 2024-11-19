

END TRY

	BEGIN CATCH

		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK;
			END;
		-- to get database and schema of error_procedure()

		DECLARE	@DbName		VARCHAR(100)
			,	@ProcSchema	VARCHAR(25);

		SELECT
			@DbName = DB_NAME(DB_ID())
		,	@ProcSchema = OBJECT_SCHEMA_NAME(@@PROCID);

		--to log the error
		EXEC [Report].[usp_ProcErrorLog]
			@ErrorLogID		= 0
		,	@DatabaseName	= @DbName
		,	@Schema			= @ProcSchema;

		--to show the error to the end user
		THROW;
	END CATCH;

	SET NOCOUNT OFF;
GO