SELECT		  Catalog.Name
			, Roles.RoleName
			, Users.UserName 

FROM		dbo.Catalog							[Catalog] 
			inner join dbo.PolicyUserRole		[PolicyUserRole]
				on Catalog.PolicyID	= PolicyUserRole.PolicyID
			inner join dbo.Roles				[Roles]
				on PolicyUserRole.RoleID = Roles.RoleID 
			inner join dbo.Users				[Users]
				on Users.UserID = PolicyUserRole.UserID

WHERE		Users.UserName = 'RITZ-CARLTONYAC\noella.cutajar' 
			OR 
			Catalog.Name = 'Payments_Received_by_Posting_Date'
;

