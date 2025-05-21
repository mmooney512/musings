SELECT		  Name
			, CostRate
			, Availability
			, ModifiedDate
FROM		production.Location
ORDER BY	LocationID
OFFSET		? ROWS FETCH NEXT ? ROWS ONLY
;