SELECT		iddomain ,domainname
			,[f1] ,[f2] ,[f3] ,[f4] ,[f5] ,[f6] ,[f7] ,[f8]
FROM		(
				SELECT		TOP 100
							fn.idfieldname
							,fn.fieldname
							,fn.iddomain
							,dn.domainname
				FROM		dbo.port_fieldname AS fn
							INNER JOIN dbo.port_domain AS dn
								ON fn.iddomain = dn.iddomain
				WHERE		fn.iddomain = 1
			) AS sourcetable
			PIVOT
			(
				COUNT(idfieldname)
				FOR fieldname IN ([f1] ,[f2] ,[f3] ,[f4] ,[f5] ,[f6] ,[f7] ,[f8])
			)AS PivotTable