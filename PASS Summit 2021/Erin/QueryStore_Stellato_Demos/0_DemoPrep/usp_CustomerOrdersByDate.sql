/*

USE [msdb];
GO

DROP TABLE IF EXISTS [msdb].[dbo].[OrderDates];
GO

SELECT 
	DISTINCT [OrderDate], 
	DENSE_RANK() OVER (ORDER BY [OrderDate]) AS RowNum
INTO [msdb].[dbo].[OrderDates]
FROM [WideWorldImporters].[Sales].[Orders];
GO

*/
SET NOCOUNT ON;

USE [WideWorldImporters];

DECLARE @RowNum INT = 1;
DECLARE @TotalRows INT;
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
DECLARE @DateRange INT;



SELECT @TotalRows = COUNT(*) FROM [msdb].[dbo].[OrderDates]

WHILE 1=1
BEGIN

	SELECT @StartDate = (
		SELECT [OrderDate] 
		FROM [msdb].[dbo].[OrderDates]
		WHERE RowNum = @RowNum)

	SET @EndDate = DATEADD(DAY, CONVERT (INT, RAND () * 50) + 1,@StartDate)
	

	EXEC [Sales].[usp_CustomerOrdersByDate] @StartDate, @EndDate 

	IF @RowNum <= @TotalRows
	BEGIN
		SET @RowNum = @RowNum + 1
	END
	ELSE
	BEGIN
		SET @RowNum = 1
	END
END