/*

USE [msdb];
GO

DROP TABLE IF EXISTS [msdb].[dbo].[StockItemIDs];
GO

SELECT 
	DISTINCT [StockItemID], 
	DENSE_RANK() OVER (ORDER BY [StockItemID]) AS RowNum
INTO [msdb].[dbo].[StockItemIDs]
FROM [WideWorldImporters].[Sales].[OrderLines];
GO

*/
USE [WideWorldImporters];

SET NOCOUNT ON;
SET ARITHABORT OFF;

DECLARE @StockItemID INT;
DECLARE @RowNum INT = 1;
DECLARE @TotalRows INT;

SELECT @TotalRows = COUNT(*) FROM [msdb].[dbo].[StockItemIDs]


WHILE 1=1
BEGIN

	SELECT @StockItemID = (
		SELECT [StockItemID]
		FROM [msdb].[dbo].[StockItemIDs]
		WHERE RowNum = @RowNum)

	EXEC [Sales].[usp_GetFullProductInfo] @StockItemID;

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