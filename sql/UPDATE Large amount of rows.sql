

SET			ROWCOUNT 10000

UPDATE		sdo
SET			sdo.flo	= 1
FROM		sto.SourceData_Outlet AS sdo
			INNER JOIN [tmp].[flo_dlvr_pnt_no] AS fdp
				ON sdo.dlvr_pnt_no = fdp.dlvr_pnt_no
WHERE		sdo.flo IS NULL

WHILE		@@rowcount > 0
	BEGIN
			UPDATE		sdo
			SET			sdo.flo	= 1
			FROM		sto.SourceData_Outlet AS sdo
						INNER JOIN [tmp].[flo_dlvr_pnt_no] AS fdp
							ON sdo.dlvr_pnt_no = fdp.dlvr_pnt_no
			WHERE		sdo.flo IS NULL
	END


SET			ROWCOUNT 0


