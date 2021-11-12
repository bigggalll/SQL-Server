CREATE FUNCTION [dbo].[DecimalToBinary]
(
	@Input bigint
)
RETURNS varchar(255)
AS
BEGIN

	DECLARE @Output varchar(255) = ''

	WHILE @Input > 0 BEGIN

		SET @Output = @Output + CAST((@Input % 2) AS varchar)
		SET @Input = @Input / 2

	END

	RETURN REVERSE(@Output)

END
GO


/****** Object:  UserDefinedFunction [dbo].[DecimalToBinary_V2]    Script Date: 2017-03-02 09:25:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[DecimalToBinary_V2]
(
	@Input bigint
)
RETURNS varchar(255)
AS
BEGIN

	DECLARE @OutputTxt varchar(255) = ''
	DECLARE @Coeur int = 1

	WHILE @Input > 0 BEGIN

		--SET @Output = @Output + CAST((@Input % 2) AS varchar)
		If @Input % 2 = 1
		Begin
			If  @OutputTxt = ''
			Begin
				Set @OutputTxt = 'Coeurs utilisés: ' + cast(@Coeur as nvarchar)
			End
			Else
			Begin
				Set	@OutputTxt = @OutputTxt + ', '
				Set	@OutputTxt = @OutputTxt + cast(@Coeur as nvarchar)
			End
		End
			
		SET @Input = @Input / 2
		Set @Coeur = @Coeur + 1

	END

	RETURN @OutputTxt

END

GO

