USE BI_ETL;  
GO  
SELECT OBJECT_DEFINITION (OBJECT_ID(N'Covid19_Variant.usp_Merge_Analytics_Variant_Patient'));  

ALTER AUTHORIZATION ON SCHEMA::Covid19_Variant TO dbo;


