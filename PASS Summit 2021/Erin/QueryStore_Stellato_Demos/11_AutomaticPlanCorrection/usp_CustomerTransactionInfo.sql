SET NOCOUNT ON;
GO

USE [WideWorldImportersB];

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;

EXEC [Sales].[usp_CustomerTransactionInfo] 1088;

DECLARE @CustomerID INT;
DECLARE @RowNum INT = 1;
DECLARE @TotalRows INT;

SELECT @TotalRows = COUNT(*) FROM [WideWorldImportersB].[dbo].[CustomerIDs]

WHILE 1=1
BEGIN

	SELECT @CustomerID = (
		SELECT [CustomerID] 
		FROM [WideWorldImportersB].[dbo].[CustomerIDs]
		WHERE RowNum = @RowNum);

	EXEC [Sales].[usp_CustomerTransactionInfo] @CustomerID;

	IF @RowNum <= @TotalRows
	BEGIN
		SET @RowNum = @RowNum + 1
	END
	ELSE
	BEGIN
		SET @RowNum = 1
	END

END
GO