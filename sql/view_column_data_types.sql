USE prd_DW_ODS
GO


SELECT	c.name
		, t.name
		, c.max_length
		, c.precision
		, c.scale
		, c.column_id

FROM	sys.columns	   c
		JOIN sys.types t
		ON	t.user_type_id		 = c.user_type_id
			AND t.system_type_id = c.system_type_id
WHERE	object_id = OBJECT_ID('vw_SFMC_Itinerary_NVAR');
