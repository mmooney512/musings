USE			dgBasis;

SELECT		sq1.mainkey, count(company) as cntCompany
FROM		(
			SELECT		DISTINCT
						xi01_mainkey	as mainkey, 
						company
			FROM		dbo.xi01
			) as sq1
GROUP BY	mainkey
ORDER BY	mainkey