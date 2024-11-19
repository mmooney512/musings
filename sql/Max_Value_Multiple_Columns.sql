-- ---------------------------------------------------------------------------
-- Max Column value from multiple columns grouped by one value
-- ---------------------------------------------------------------------------

		SELECT	EMPLID
				,	(SELECT Max(v) 
					FROM (VALUES (cmpny_seniority_dt)
								, (HIRE_DT)
								, (REHIRE_DT)
						) AS value(v)
					) MultiColumnMaxDate
		FROM PeopleSoft.staging_employment_date


-- ---------------------------------------------------------------------------
-- Max Column value from multiple columns
-- ---------------------------------------------------------------------------
SELECT	MAX(sq.MultiColumnMaxDate)		TableMaxDate
FROM	(
		SELECT	EMPLID
				,	(SELECT Max(v) 
					FROM (VALUES (cmpny_seniority_dt)
								, (HIRE_DT)
								, (REHIRE_DT)
						) AS value(v)
					) MultiColumnMaxDate
		FROM PeopleSoft.staging_employment_date
		) sq
;
