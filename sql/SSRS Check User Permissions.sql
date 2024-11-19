USE SSRS
GO
select u.UserName, r.RoleName, r.Description, c.Path, c.Name 
from dbo.PolicyUserRole pur
   inner join dbo.Users u on pur.UserID = u.UserID
   inner join dbo.Roles r on pur.RoleID = r.RoleID
   inner join dbo.Catalog c on pur.PolicyID = c.PolicyID


WHERE u.UserName = 'RITZ-CARLTONYAC\Jeffrey.Herzfeld'
order by u.UserName  

