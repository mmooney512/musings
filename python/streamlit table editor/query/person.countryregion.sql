SELECT		  CountryRegionCode
			, Name
			, ModifiedDate
FROM		person.CountryRegion
ORDER BY	ID
OFFSET		? ROWS FETCH NEXT ? ROWS ONLY
;