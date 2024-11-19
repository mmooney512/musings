USE [ddSandbox]
GO
/****** Object:  UserDefinedFunction [dbo].[UPCE]    Script Date: 06/26/2013 13:55:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION  [dbo].[UPCE] (@upca_value VARCHAR(32))  RETURNS VARCHAR(32)
AS 

BEGIN
	DECLARE		@upca		AS	VARCHAR(32)			
	DECLARE		@upce_value	AS	VARCHAR(32)
	DECLARE		@ck			AS	INT
	SET @upca = RTRIM(LTRIM(COALESCE(@upca_value,'0')))
	SET @upce_value = '-1' 
	SET @upca_value = RIGHT('000000000000' + @upca ,12)
	--	POS 1
	IF	(CAST(LEFT(@upca_value,1) AS INT)>1 OR CAST(LEFT(@upca_value,1) AS INT)<0)
		BEGIN
			SET @upce_value = 'INVALID UPC-A'			----- Flag as error
			RETURN(@upce_value)
		END			
	----- POS 3
	IF	(@upce_value = '-1'	
		AND 
		(SUBSTRING(@upca_value,4,3) = '000'	
		OR
		SUBSTRING(@upca_value,4,3) = '100'
		OR
		SUBSTRING(@upca_value,4,3) = '200'
		))
		SET @upce_value = (SUBSTRING(@upca_value, 2, 2) 
						  +SUBSTRING(@upca_value, 9, 3)
						  +SUBSTRING(@upca_value, 4, 1))
	----- POS 5
	IF	(@upce_value = '-1'	AND SUBSTRING(@upca_value, 5, 2) = '00')
		SET	@upce_value = (SUBSTRING(@upca_value, 2, 3)
						  +SUBSTRING(@upca_value, 10, 2)
						  +'3')
	----- POS 6
	IF	(@upce_value = '-1'	AND SUBSTRING(@upca_value, 6, 1) = '0')
		SET	@upce_value = (SUBSTRING(@upca_value, 2, 5)
						  +SUBSTRING(@upca_value, 11, 1)
						  +'4')
	----- POS 11
	IF	(@upce_value = '-1'	AND CAST(SUBSTRING(@upca_value, 11, 1) AS INT) >= 5)
		SET @upce_value = (SUBSTRING(@upca_value, 2, 5)
						  +SUBSTRING(@upca_value, 11, 1)
						  )
	----- Add check digit
	IF	(@upce_value = '-1')
		SET @upce_value = 'INVALID UPC-A'			----- Flag as error
	ELSE
		BEGIN
			SET @upca =	'0' + @upca
			SET @ck =	  (((CAST(SUBSTRING(@upca, 1, 1) AS INT)
							+CAST(SUBSTRING(@upca, 3, 1) AS INT)
							+CAST(SUBSTRING(@upca, 5, 1) AS INT)
							+CAST(SUBSTRING(@upca, 7, 1) AS INT)
							+CAST(SUBSTRING(@upca, 9, 1) AS INT)
							+CAST(SUBSTRING(@upca, 11, 1) AS INT))*3)
							+
							(CAST(SUBSTRING(@upca, 2, 1) AS INT)
							+CAST(SUBSTRING(@upca, 4, 1) AS INT)
							+CAST(SUBSTRING(@upca, 6, 1) AS INT)
							+CAST(SUBSTRING(@upca, 8, 1) AS INT)
							+CAST(SUBSTRING(@upca, 10, 1) AS INT)
							)) % 10
			IF @ck <> 0
				SET @ck = (10 - @ck)
				
			SET	@upce_value = @upce_value + CAST(@ck AS varchar(1))
		END	
	RETURN(@upce_value)
END