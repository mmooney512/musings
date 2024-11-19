USE tst_DW_ODS
;
-- extract all the ddl's for the stored procedures
-- print out the ddl, looping through the text in blocks of 4000
-- in case the ddl is longer than 4000 characters.
-- print function has a cap @ 4000 characters
-- output needs to be saved to a file

DROP TABLE	IF EXISTS #sp_list;

CREATE	TABLE	#sp_list
(	ITEM_ID				Int
	, sys_proc_name		Varchar(255)
)

-- store list of stored procedures into a temp table

INSERT	INTO	#sp_list
(
	ITEM_ID
	, sys_proc_name
)
SELECT			ROW_NUMBER() OVER(ORDER BY  sys_proc.[name]) AS row_num
				, sys_proc.[name]
FROM			sys.procedures	sys_proc
ORDER BY		sys_proc.[name]

DECLARE			@sp_name	Varchar(255) = '';
Declare			@sql		Varchar(max) ;
DECLARE			@sp_count	Int		= 0;
DECLARE			@ctr		Int		= 1;
DECLARE			@StartPos	BigInt	= 1;
DECLARE			@LenSql		BigInt  = 0; 

-- how many stored procedures will we be processing
SELECT			@sp_count = COUNT(item_id)
FROM			#sp_list

-- loop through each of the stored procedures
WHILE			(@ctr <= @sp_count)
BEGIN
		-- extract the stored procedure ddl
		SELECT	@sp_name = sys_proc.[name]
				, @sql = Object_definition(object_id)
				
		FROM	sys.procedures	sys_proc
				INNER JOIN #sp_list
				ON sys_proc.[name] = #sp_list.sys_proc_name
				AND #sp_list.ITEM_ID = @ctr
		;

		-- print name of stored procedure
		PRINT	'DDL ' + @sp_name;

		-- print stored procedure ddl
		BEGIN
			SET	@StartPos	= 1;
			SET @LenSql		= LEN(@sql);

			WHILE @StartPos < @LenSql
				BEGIN
					PRINT SUBSTRING(@sql,@StartPos,@StartPos + 4000)
					SET @StartPos = @StartPos + 4000
				END
		END
		
		SET @ctr = @ctr + 1
END

DROP TABLE	IF EXISTS #sp_list;

