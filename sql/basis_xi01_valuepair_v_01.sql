SELECT		XI01_SUBKEY							AS Brand_Type, 
			SUBSTRING(XI01_DATAFIELD, 1, 30)	AS LONG_DESC, 
			SUBSTRING(XI01_DATAFIELD, 31, 10)	AS MED_DESC, 
			RTRIM(LTRIM(XI01_MAINKEY))			AS MainKey, 
			ASCII(LTRIM(XI01_SUBKEY))			AS Ascii_BrandType
FROM		dbo.XI01
GROUP BY	RTRIM(LTRIM(XI01_MAINKEY)), 
			SUBSTRING(XI01_DATAFIELD, 1, 30), 
			SUBSTRING(XI01_DATAFIELD, 31, 10), 
			XI01_SUBKEY, XI01_MAINKEY,
			ASCII(LTRIM(XI01_SUBKEY))

HAVING		(RTRIM(LTRIM(XI01_MAINKEY)) = 'AM1113')

ORDER BY	Brand_Type