DECLARE @sql nvarchar(max);
DECLARE @crsr CURSOR;

SET @crsr = CURSOR STATIC FORWARD_ONLY FOR
SELECT
  CONCAT('
CREATE OR ALTER FUNCTION ',
    QUOTENAME(s.name),
    '.',
    QUOTENAME(t.name + '_AsOf'),
    '
(
',
    c.params,
    ',
@date datetime2
)
RETURNS TABLE
AS RETURN
SELECT *
FROM ',
    QUOTENAME(s.name),
    '.',
    QUOTENAME(t.name),
    ' FOR SYSTEM_TIME AS OF @date
WHERE ',
    c.cols,
    ';'
  )

FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
CROSS APPLY (
    SELECT
      params = STRING_AGG(
        CONCAT(
          v.paramName,
          ' ',
          typ.name,
          CASE
            WHEN typ.name IN ('binary', 'varbinary', 'char', 'varchar', 'nchar', 'nvarchar')
            THEN CONCAT('(', IIF(c.max_length = -1, 'max', CAST(c.max_length AS nvarchar(10))), ')')
            WHEN typ.name IN ('decimal', 'numeric')
            THEN CONCAT('(', c.precision, ',', c.scale, ')')
            WHEN typ.name IN ('datetime2', 'datetimeoffset', 'time')
            THEN CONCAT('(', c.precision, ')')
          END
        ),
        ',
'
      ),
  
      cols = STRING_AGG(
        CONCAT(
          QUOTENAME(c.name),
          ' = ',
          v.paramName
        ),
        '
  AND '
      )
    FROM sys.columns c
    JOIN sys.indexes i ON i.object_id = t.object_id
    JOIN sys.index_columns ic
      ON ic.object_id = i.object_id
     AND ic.index_id = i.index_id
     AND ic.column_id = c.column_id
    JOIN sys.types typ ON typ.user_type_id = c.user_type_id
    CROSS APPLY (
        SELECT
          paramName = '@' + TRANSLATE(c.name, ' -\/''"', '______')
    ) v
    WHERE c.object_id = t.object_id
      AND i.is_primary_key = 1
      AND ic.is_included_column = 0
) c
WHERE t.temporal_type = 2;


OPEN @crsr;
WHILE 1=1
BEGIN
    FETCH NEXT FROM @crsr INTO @sql;
    IF @@FETCH_STATUS <> 0
        BREAK;

    PRINT @sql;

    --EXEC sp_executesql @sql;
END;
