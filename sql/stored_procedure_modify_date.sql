USE stg_DW_ODS
;

SELECT		[name]	
			, create_date
			, modify_date
FROM		sys.procedures
ORDER BY	3 DESC
;

USE		stg_DW_Sales
SELECT		[name]	
			, create_date
			, modify_date
FROM		sys.procedures
ORDER BY	3 DESC
;

