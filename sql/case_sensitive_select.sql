-- ----------------------------------------------------------------------------
-- List all available collations
-- ----------------------------------------------------------------------------
SELECT *
FROM fn_helpcollations()

-- ----------------------------------------------------------------------------
-- do a case sensitive select query
-- ----------------------------------------------------------------------------

USE			ddReports;

--	unique ID to find = 'JhaFYsy7293X0800fsaR10'

--	Will find the ID's
SELECT		matid
FROM		dbo.SAPAPO_MATLOC
WHERE		matid = 'JhaFYsy7293X0800fsaR10'
COLLATE		SQL_Latin1_General_Cp1251_CS_AS

--	Will NOT find the ID's
SELECT		matid
FROM		dbo.SAPAPO_MATLOC
WHERE		matid = 'JHaFYsy7293X0800fsaR10'
COLLATE		SQL_Latin1_General_Cp1251_CS_AS
