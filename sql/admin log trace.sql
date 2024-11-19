USE prd_DW_Sales
SELECT * from fn_trace_getinfo(NULL)
where property=2
and traceid = 1

select * from fn_trace_gettable('C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\log_569.trc', -1)
where EventClass = 47
AND ObjectName LIKE '%booking%'
and ObjectType=8727

select * from fn_trace_gettable('C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\log_569.trc', -1)
where ObjectName LIKE '%booking%'