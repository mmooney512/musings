USE dgSap;
-- Declare variables
SET NOCOUNT ON;
DECLARE @tablename varchar(255);
DECLARE @execstr   varchar(400);
DECLARE @objectid  int;
DECLARE @indexid   int;
DECLARE @frag      decimal;
DECLARE @maxfrag   decimal;

-- Decide on the maximum fragmentation to allow for.
SELECT @maxfrag = 0.01;

-- Declare a cursor.
DECLARE tables CURSOR FOR
   SELECT TABLE_SCHEMA + '.' + TABLE_NAME
   FROM INFORMATION_SCHEMA.TABLES
   WHERE TABLE_TYPE = 'BASE TABLE'
		 AND TABLE_NAME NOT LIKE '%NACOKECCE%'

-- Create the table.
CREATE TABLE #fraglist (
   ObjectName char(255),
   ObjectId int,
   IndexName char(255),
   IndexId int,
   Lvl int,
   CountPages int,
   CountRows int,
   MinRecSize int,
   MaxRecSize int,
   AvgRecSize int,
   ForRecCount int,
   Extents int,
   ExtentSwitches int,
   AvgFreeBytes int,
   AvgPageDensity int,
   ScanDensity decimal,
   BestCount int,
   ActualCount int,
   LogicalFrag decimal,
   ExtentFrag decimal);

-- Open the cursor.
OPEN tables;

-- Loop through all the tables in the database.
FETCH NEXT
   FROM tables
   INTO @tablename;

WHILE @@FETCH_STATUS = 0
BEGIN
-- Do the showcontig of all indexes of the table
	PRINT 'Executing insert INTO fraglist: ' + RTRIM(@tablename)
   INSERT INTO #fraglist 
   EXEC ('DBCC SHOWCONTIG (''' + @tablename + ''') WITH FAST, TABLERESULTS, ALL_INDEXES, NO_INFOMSGS');
   FETCH NEXT
      FROM tables
      INTO @tablename;
END;

-- Close and deallocate the cursor.
CLOSE tables;
DEALLOCATE tables;

-- List the indexes for the tables and frag amount
   SELECT ObjectName, ObjectId, IndexId, LogicalFrag
   FROM #fraglist
   WHERE LogicalFrag >= @maxfrag
      AND INDEXPROPERTY (ObjectId, IndexName, 'IndexDepth') > 0;

-- Delete the temporary table.
DROP TABLE #fraglist;
GO
