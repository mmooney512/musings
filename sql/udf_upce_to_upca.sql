CREATE FUNCTION ConvertUPCEtoUPCA(@UPC_E varchar(8))
RETURNS varchar(12)
AS
BEGIN
  DECLARE @validDigitsFarRight varchar(1)
  DECLARE @validDigits varchar(6)
  DECLARE @checkdigit varchar(1) 
  DECLARE @mfgDigits varchar(10)
  DECLARE @prodDigits varchar(10)      
  DECLARE @UPC_A varchar(12)
            
    
	SET @UPC_A = ''
	SET @validDigits = Substring(@UPC_E, 2, 6)
	SET @checkDigit = Substring(@UPC_E, Len(@UPC_E), 1);
	SET @mfgDigits = ''
	SET @prodDigits = ''
	SET @validDigitsFarRight = Substring(@validDigits, Len(@validDigits), 1)
            
    SET @mfgDigits = 
		CASE
                WHEN 
                @validDigitsFarRight = '0' OR
                @validDigitsFarRight = '1' OR
                @validDigitsFarRight = '2'
                 THEN
					Substring(@validDigits, 1, 2) + Substring(@validDigits, Len(@validDigits), 1 ) + '00'
				  WHEN @validDigitsFarRight = '3' THEN
                    Substring(@validDigits, 1, 3) + '00'
                WHEN @validDigitsFarRight = '4' THEN                
                    Substring(@validDigits, 1, 4) + '0'
                ELSE
                    Substring(@validDigits, 1, 5)
            END    

    SET @prodDigits = 
		CASE
                WHEN 
                @validDigitsFarRight = '0' OR
                @validDigitsFarRight = '1' OR
                @validDigitsFarRight = '2'
                 THEN
					'00' + Substring(@validDigits, 3, 3)
				  WHEN @validDigitsFarRight = '3' THEN
                    '000' + Substring(@validDigits, 4, 2)
                WHEN @validDigitsFarRight = '4' THEN                
                    '0000' + Substring(@validDigits, 5, 1)
                ELSE
                    '0000' + Substring(@validDigits, 6, 1)
            END        
     SET @UPC_A = Substring(@UPC_E, 1, 1) + @mfgDigits + @prodDigits + @checkDigit;
     RETURN @UPC_A
END
GO