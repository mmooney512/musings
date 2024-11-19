USE			dgSAP;

DECLARE @temp_za TABLE(
						table_name	nvarchar(60),
						record_key	nvarchar(140),
						change_nr	nvarchar(36),
						field		nvarchar(60),
						change_id	nvarchar(2),
						old_value	nvarchar(510),
						new_value	nvarchar(510),
						change_date	nvarchar(40)
						)
						
BEGIN TRANSACTION
	INSERT INTO @temp_za(table_name,record_key,change_nr,field,change_id,old_value,new_value,change_date)
	SELECT		table_name	,
						record_key	,
						change_nr	,
						field		,
						change_id	,
						old_value	,
						new_value	,
						change_date	
			FROM		dbo.zisscom_audit as za
			WHERE		za.change_date > '20121115'

COMMIT TRANSACTION

SELECT		*
FROM		@temp_za as tza
WHERE		tza.table_name = 'ZVIC_BEV_PROD'

UNION
SELECT		*
FROM		@temp_za as tza
WHERE		tza.table_name = 'ZVIC_BEV_STTE'
go


