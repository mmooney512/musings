
SELECT	
		 PivotHandlingTable.contact_uuid
		,PivotHandlingTable.[Customer Renewal in Progress]
		,PivotHandlingTable.[ELT]
		,PivotHandlingTable.[IT Helper]
		,PivotHandlingTable.[See Service Desk Management]
		,PivotHandlingTable.[See Service Desk Mgmt]
		,PivotHandlingTable.[VIP]
		,PivotHandlingTable.[Vision Impaired]

FROM	(
		SELECT		TOP 1000
					usp_contact_handling.contact				AS contact_uuid
					,usp_contact_handling.special_handling		AS contact_handling_id
					,usp_special_handling.sym					AS special_handling_name

		FROM		dbo.usp_contact_handling
					INNER JOIN dbo.usp_special_handling
						ON usp_contact_handling.special_handling = usp_special_handling.id

		WHERE		usp_special_handling.del = 0
		) AS sourcetable
		PIVOT
		(
			COUNT(sourcetable.contact_handling_id)
			FOR special_handling_name IN([Customer Renewal in Progress] 
										,[ELT] 
										,[IT Helper]
										,[See Service Desk Management] 
										,[See Service Desk Mgmt]
										,[VIP]
										,[Vision Impaired]
										)
		) AS PivotHandlingTable
		
		
;

