WITH CTE AS
(
   SELECT	[outlet_no]
			,[second_list]
			,RN = ROW_NUMBER() OVER
							(PARTITION BY [outlet_no] 
							ORDER BY [outlet_no]
							)
   FROM tmp.flo_dlvr_pnt_no_2
)
DELETE FROM CTE WHERE RN > 1