EXECUTE master.sys.sp_MSforeachdb 'USE [?]; 
begin try
  drop user [ReportUser]
  print ''did drop at ?''
end try
begin catch
  print ''did not drop at ?''
end catch
'
GO