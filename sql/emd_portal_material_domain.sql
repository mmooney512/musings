-- ---------------------------------------------------------------------------
-- query to extract the portal elements from the material domain
-- selecting only	Country: US
--					active materials
--					records from BASIS and SAP
--	DATABASE:		ETCBDCMD302.ddReports
--	TABLES/VIEWS:	dbo.tblEMDPortal_MaterialDomain
--	CREATED:		15-Nov-12
-- ---------------------------------------------------------------------------

USE			ddReports;

SELECT		pmd.[Data Element Name (LinkTitleNoMenu)]	AS 'Data Element Name'
			,pmd.[Countries]
			,pmd.[Book of Record]
			,pmd.[Table]
			,pmd.[Technical Field Name]
			,pmd.[Data Element Name (LinkTitle)]
			,pmd.[Field Purpose and Business Use]
			,pmd.[Business Rule]
			,pmd.[Last Review Date]
			,pmd.[Active Status]
			,pmd.[Reviewed By]
			,pmd.[Cross-Domain]
			,pmd.[Data Quality Query List]
			,pmd.[BASIS CI Pointer]
			,pmd.[Material Creation Process Flow]
			,pmd.[Decimals]
			,pmd.[Data Standard Level of Applicability]
			,pmd.[Codes and Values Table Name]
			,pmd.[Org Usage]
			,pmd.[Modified]
			,pmd.[Modified By]

FROM		dbo.tblEMDPortal_MaterialDomain as pmd

WHERE		pmd.[Active Status] = N'ACTIVE'
			AND pmd.[book of record] in ('SAP','BASIS')
			AND CAST(pmd.Countries AS nvarchar(max)) like '%US%'
			AND CAST(pmd.[Org Usage] AS nvarchar(max)) like '%L-CCE%'

ORDER BY	pmd.[book of record]
			,pmd.[table]
			,pmd.[Data Element Name (LinkTitleNoMenu)];