USE		ccr_galt;

EXEC sp_estimate_data_compression_savings 
	'sto'			--schema name
	, 'D_05_23_2014_CDE_May_Close_03_SourceFormat_Equip_Full_Mapped_Final'		--table name
	, NULL
	, NULL
	, 'PAGE' ;		--ROW or --PAGE



-- compress the table
ALTER TABLE sto.D_05_23_2014_CDE_May_Close_03_SourceFormat_Equip_Full_Mapped_Final REBUILD WITH (DATA_COMPRESSION = PAGE); 