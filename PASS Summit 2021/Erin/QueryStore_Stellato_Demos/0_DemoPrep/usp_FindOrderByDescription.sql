
/*
USE [msdb];
GO

DROP TABLE IF EXISTS [msdb].[dbo].[OrderLinesList];

SELECT 
	DISTINCT [Description], 
	DENSE_RANK() OVER (ORDER BY [Description]) AS RowNum
INTO [msdb].[dbo].[OrderLinesList]
FROM [WideWorldImportersB].[Sales].[OrderLines]

*/

SET NOCOUNT ON;

USE [WideWorldImporters];

DECLARE @RowNum INT = 1;
DECLARE @Description VARCHAR(100);
DECLARE @TotalRows INT


SELECT @TotalRows = COUNT(*) FROM [msdb].[dbo].[OrderLinesList]

WHILE 1=1
BEGIN

	SELECT @Description = (
		SELECT [Description] 
		FROM [msdb].[dbo].[OrderLinesList]
		WHERE RowNum = @RowNum)

	IF CHARINDEX('''',@Description) > 0
	BEGIN
		SET @Description = REPLACE(@Description, '''', '''''')
	END

	EXEC [Sales].[usp_FindOrderByDescription] @Description 

	IF @RowNum <= @TotalRows
	BEGIN
		SET @RowNum = @RowNum + 1
	END
	ELSE
	BEGIN
		SET @RowNum = 1
	END
END
