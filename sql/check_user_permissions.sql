-- impersonate a certain user
execute as user = 'NACOKECCE\T41940' 
go

select		*
from		YourView	-- test a view

revert		-- go back to normal permissions
go

-- show owner of all databases
select	name
		, suser_sname(owner_sid) 
from	sys.databases

-- SHOW what is the current username being used
SELECT SUSER_NAME(),USER_NAME()



