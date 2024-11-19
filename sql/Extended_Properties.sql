SELECT	SCHEMA_NAME(tbl.schema_id)	   AS SchemaName
		, tbl.name					   AS TableName
		, clmns.name				   AS ColumnName
		, p.name					   AS ExtendedPropertyName
		, CAST(p.value AS Sql_Variant) AS ExtendedPropertyValue
FROM	[RCYAZ2-STGCL,14725].VRes2.sys.tables						  AS tbl
		INNER JOIN [RCYAZ2-STGCL,14725].VRes2.sys.all_columns		  AS clmns
		ON	clmns.object_id = tbl.object_id

		INNER JOIN [RCYAZ2-STGCL,14725].VRes2.sys.extended_properties AS p
		ON	p.major_id		= tbl.object_id
			AND p.minor_id	= clmns.column_id
			AND p.class		= 1
WHERE	SCHEMA_NAME(tbl.schema_id) = 'dbo'
		AND tbl.name			   = 'evtEvent';
--and clmns.name='sno'		--column name
--and p.name='SNO'			-- extended property name