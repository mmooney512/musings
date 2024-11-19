-- ----------------------------------------------------------------------------
-- find duplicates in 1 column
-- ----------------------------------------------------------------------------
USE			ddReports;

SELECT		matid, count(matid) as count_matid
FROM		dbo.SAPAPO_MATLOC 
GROUP BY	matid
HAVING		COUNT(*) > 1