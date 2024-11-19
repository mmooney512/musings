DECLARE @phoneIndicator INT 

DECLARE @home bit,  
        @homeFax bit, 
        @mobile bit,  
        @office bit,  
        @officeFax bit, 
        @tollfreeOffice bit,  
        @tollfreeFax bit 

-- turn on indicators 1=on 0=off
SET @home			= 1 
SET @homeFax		= 0   
SET @mobile			= 0    
SET @office			= 0    
SET @officeFax		= 0         
SET @tollfreeOffice	= 0 
SET @tollfreeFax	= 0       

SET @phoneIndicator = POWER(2*@home				,1)  
                    + POWER(2*@homeFax			,2) 
                    + POWER(2*@mobile			,3) 
                    + POWER(2*@office			,4)  
                    + POWER(2*@officeFax		,5)  
                    + POWER(2*@tollfreeOffice	,6)  
                    + POWER(2*@tollfreeFax		,7) 

PRINT @phoneIndicator 

IF ( (2 & @phoneIndicator) = 2 )     PRINT 'Has Home' 
IF ( (4 & @phoneIndicator) = 4 )     PRINT 'Has Home Fax' 
IF ( (8 & @phoneIndicator) = 8 )     PRINT 'Has Mobile' 
IF ( (16 & @phoneIndicator) = 16 )   PRINT 'Has Office' 
IF ( (32 & @phoneIndicator) = 32 )   PRINT 'Has Office Fax' 
IF ( (64 & @phoneIndicator) = 64 )   PRINT 'Has Toll Free Office' 
IF ( (128 & @phoneIndicator) = 128 ) PRINT 'Has Toll Free Fax'

