/*

USE [msdb];
GO

DROP TABLE IF EXISTS [msdb].[dbo].[CustomerIDs];
GO

SELECT 
	DISTINCT [CustomerID], 
	DENSE_RANK() OVER (ORDER BY [CustomerID]) AS RowNum
INTO [msdb].[dbo].[CustomerIDs]
FROM [WideWorldImporters].[Sales].[CustomerTransactions];
GO
select *
from
[msdb].[dbo].[CustomerIDs]
order by rownum

*/

USE [WideWorldImporters];

SET NOCOUNT ON;


DECLARE @CustomerID INT;
DECLARE @RowNum INT = 1;
DECLARE @TotalRows INT;

SELECT @TotalRows = COUNT(*) FROM [msdb].[dbo].[CustomerIDs]

DBCC FREEPROCCACHE

EXEC [Sales].[usp_CustomerTransactionInfo] 1080

WHILE 1=1
BEGIN

	SELECT @CustomerID = (
		SELECT [CustomerID] 
		FROM [msdb].[dbo].[CustomerIDs]
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