SET NOCOUNT ON;
 
DECLARE @UpperLimit INT = 1000000;
 
WITH n AS
(
    SELECT
        x = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
    FROM       sys.all_objects AS s1
    CROSS JOIN sys.all_objects AS s2
    CROSS JOIN sys.all_objects AS s3
)
SELECT Number = x
  INTO dbo.Numbers
  FROM n
  WHERE x BETWEEN 1 AND @UpperLimit;
 
GO
CREATE UNIQUE CLUSTERED INDEX n ON dbo.Numbers(Number) 
    WITH (DATA_COMPRESSION = PAGE);
GO

CREATE FUNCTION dbo.SplitStrings_Numbers
(
   @List       NVARCHAR(MAX),
   @Delimiter  NVARCHAR(255)
)
RETURNS TABLE
WITH SCHEMABINDING
AS
   RETURN
   (
       SELECT Item = SUBSTRING(@List, Number, 
         CHARINDEX(@Delimiter, @List + @Delimiter, Number) - Number)
       FROM dbo.Numbers
       WHERE Number <= CONVERT(INT, LEN(@List))
         AND SUBSTRING(@Delimiter + @List, Number, LEN(@Delimiter)) = @Delimiter
   );
GO