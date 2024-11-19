
select		isr.SPECIFIC_SCHEMA
			,isr.SPECIFIC_NAME

FROM		 AllUserDataReplica.information_schema.routines  AS isr
where routine_type = 'PROCEDURE'
 ;