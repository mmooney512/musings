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




SELECT		TOP 100
			*
FROM		[dbo].[EquipmentInfo_May_2014]
WHERE		Bottler = 'UNITED'
			AND [Branch Name] = 'MONTGOMERY'


SELECT		TOP 100
			*
FROM		[dbo].[EquipmentInfo_June_2014]
WHERE		Bottler = 'CCBCC'
			AND [Branch Name] = 'COOKVILLE'
