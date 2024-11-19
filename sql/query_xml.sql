USE BI_ETL;


SELECT	Sample_Id
		, date_loaded
		, 'Variant_Key'
		, tbl_values =	(SELECT  Sample_Id
								, Amplicon_Concentration_dsDNA
								, Assembled
								, Biobank_Id
								, Cid
								, source_row_number
			FROM (values(null)) Variant_Key(interim) for xml AUTO, ELEMENTS)
							
FROM	Covid19_Variant.Staging_Variant_Key_Interim
;


SELECT		UUID
			, date_loaded
			, r.Raw_Contents
			, r.Raw_Contents.value('(/Variant_Key/Sample_Id)[1]' ,'NVARCHAR(255)') AS si
FROM		Covid19_Variant.Staging_Raw AS r
