USE SSISDB;
GO

-- ---------------------------------------------------------------------------
-- Step 0: Get Source Environment Variables for Step 2
-- ---------------------------------------------------------------------------



--DECLARE @FOLDER_NAME NVARCHAR(128) = N'DW_refresh';
--DECLARE @SOURCE_ENVIRONMENT NVARCHAR(128) = N'PROD';

--SELECT		',(' + '''' + v.[name] + '''' + ',' + ''''
--			+ CONVERT(NVarchar(1024), ISNULL(v.[value], N'<VALUE GOES HERE>'))
--			+ '''' + ',' + '''' + v.[description] + '''' + ')' ENVIRONMENT_VARIABLES
--FROM		[SSISDB].[catalog].[environments]		   e
--			JOIN	[SSISDB].[catalog].[folders]			   f
--			ON e.[folder_id] = f.[folder_id]

--			JOIN	[SSISDB].[catalog].[environment_variables] v
--			ON e.[environment_id] = v.[environment_id]

--WHERE		e.[name] = @SOURCE_ENVIRONMENT
--			AND f.[name] = @FOLDER_NAME

--ORDER BY	v.[name]
--;


--GO
-- ---------------------------------------------------------------------------
-- Step 1: Set Script Variable Values
-- ---------------------------------------------------------------------------

USE SSISDB;
GO

DECLARE	 @FOLDER_NAME             NVARCHAR(128) = N'DW_refresh'
		,@FOLDER_ID               BIGINT
		,@TARGET_ENVIRONMENT_NAME NVARCHAR(128) = N'STAGING'
		,@ENVIRONMENT_ID          INT
		,@VARIABLE_NAME           NVARCHAR(128)
		,@VARIABLE_VALUE          NVARCHAR(1024)
		,@VARIABLE_DESCRIPTION    NVARCHAR(1024)

DECLARE @ENVIRONMENT_VARIABLES TABLE (
  [name]        NVARCHAR(128)
, [value]       NVARCHAR(1024)
, [description] NVARCHAR(1024)
);	


-- ---------------------------------------------------------------------------
-- Step 2: Load Environment Variables and Values into a Table Variable
-- ---------------------------------------------------------------------------
INSERT @ENVIRONMENT_VARIABLES
SELECT [name], [value], [description]
FROM (
  VALUES
	--
	-- PASTE the variable name / value from Step 0 HERE
	--
	('var_name' ,'var_value', 'var_description')
	,('var_name' ,'var_value', 'var_description')

) AS v([name], [value], [description]);
 
SELECT * FROM @ENVIRONMENT_VARIABLES;  -- debug output		



-- ---------------------------------------------------------------------------
-- Step 3: Create Folder (if necessary)
-- ---------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [SSISDB].[catalog].[folders] WHERE name = @FOLDER_NAME)
    EXEC [SSISDB].[catalog].[create_folder] @folder_name=@FOLDER_NAME, @folder_id=@FOLDER_ID OUTPUT
ELSE
    SET @FOLDER_ID = (SELECT folder_id FROM [SSISDB].[catalog].[folders] WHERE name = @FOLDER_NAME)	



-- ---------------------------------------------------------------------------
-- Step 4: Create Environment (if necessary)
-- ---------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [SSISDB].[catalog].[environments] WHERE folder_id = @FOLDER_ID AND
               name = @TARGET_ENVIRONMENT_NAME)
    EXEC [SSISDB].[catalog].[create_environment]
     @environment_name=@TARGET_ENVIRONMENT_NAME,
     @folder_name=@FOLDER_NAME

-- get the environment id
SET @ENVIRONMENT_ID = (SELECT environment_id FROM [SSISDB].[catalog].[environments] 
WHERE folder_id = @FOLDER_ID and name = @TARGET_ENVIRONMENT_NAME)	



-- ---------------------------------------------------------------------------
-- Step 5: Create or Update Environment Variables and Values
-- ---------------------------------------------------------------------------
SELECT TOP 1
 @VARIABLE_NAME = [name]
,@VARIABLE_VALUE = [value]
,@VARIABLE_DESCRIPTION = [description]
FROM @ENVIRONMENT_VARIABLES
WHILE @VARIABLE_NAME IS NOT NULL
BEGIN
   PRINT @VARIABLE_NAME
    -- create environment variable if it doesn't exist
   IF NOT EXISTS (
      SELECT 1 FROM [SSISDB].[catalog].[environment_variables] 
      WHERE environment_id = @ENVIRONMENT_ID AND name = @VARIABLE_NAME
   )
      EXEC [SSISDB].[catalog].[create_environment_variable]
        @variable_name=@VARIABLE_NAME
      , @sensitive=0
      , @description=@VARIABLE_DESCRIPTION
      , @environment_name=@TARGET_ENVIRONMENT_NAME
      , @folder_name=@FOLDER_NAME
      , @value=@VARIABLE_VALUE
      , @data_type=N'String'
   ELSE
    -- update environment variable value if it exists
      EXEC [SSISDB].[catalog].[set_environment_variable_value]
        @folder_name = @FOLDER_NAME
      , @environment_name = @TARGET_ENVIRONMENT_NAME
      , @variable_name = @VARIABLE_NAME
      , @value = @VARIABLE_VALUE
   DELETE TOP (1) FROM @ENVIRONMENT_VARIABLES
   SET @VARIABLE_NAME = null
   SELECT TOP 1
     @VARIABLE_NAME = [name]
    ,@VARIABLE_VALUE = [value]
    ,@VARIABLE_DESCRIPTION = [description]
    FROM @ENVIRONMENT_VARIABLES
END	