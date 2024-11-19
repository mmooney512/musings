USE			dgBasis;

SELECT DISTINCT
			xi01_mainkey,
			xi01_subkey,
			SUBSTRING(xi01_datafield, 1, 30)	AS Long_Description, 
			SUBSTRING(xi01_datafield, 31, 10)	AS Short_Description,
			xi01_datafield						AS Raw_DataField

FROM		dbo.xi01

WHERE		xi01_mainkey like '%AM1113%'
ORDER BY	xi01_subkey;
