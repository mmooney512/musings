-- ---------------------------------------------------------------------------


--	SELECT dbo.SpaceBeforeCap('ThisIsASampleDBString', 1) -- perserve adjacent caps
--	SELECT dbo.SpaceBeforeCap('ThisIsASampleDBString', 0) -- spaces between adjacent caps

-- ---------------------------------------------------------------------------


CREATE FUNCTION		reporting.SpaceBeforeCapital 
					(
					  @InputString NVARCHAR(MAX)
					, @PreserveAdjacentCaps BIT
					)
RETURNS NVARCHAR(MAX)

AS
	BEGIN

		DECLARE		@i				INT
					, @j			INT
					, @previous		NCHAR
					, @current		NCHAR
					, @next			NCHAR
					, @result		NVARCHAR(MAX)

		SELECT
					@i = 1
					, @j = LEN(@InputString)
					, @result = ''


		WHILE @i <= @j
			BEGIN
					SELECT
							@previous = SUBSTRING(@InputString,@i-1,1)
							, @current = SUBSTRING(@InputString,@i+0,1)
							, @next = SUBSTRING(@InputString,@i+1,1)


					IF @current = UPPER(@current) COLLATE Latin1_General_CS_AS
						BEGIN
						-- Add space if Current is UPPER 
						-- and either Previous or Next is lower or user chose not to preserve adjacent caps
						-- and Previous or Current is not already a space
							IF @current = UPPER(@current) COLLATE Latin1_General_CS_AS
								AND (
										@previous <> UPPER(@previous) COLLATE Latin1_General_CS_AS
										OR  @next <> UPPER(@next) collate Latin1_General_CS_AS
										OR  @PreserveAdjacentCaps = 0
								)
								AND @previous <> ' '
								AND @current <> ' '
						
							SET @result = @result + ' '
						END 

						SET @result = @result + @current
						SET @i = @i + 1
					END 

		RETURN @result
	END

