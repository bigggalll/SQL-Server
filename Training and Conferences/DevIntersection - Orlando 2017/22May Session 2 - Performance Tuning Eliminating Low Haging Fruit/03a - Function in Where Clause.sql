USE AdventureWorks2014
GO 
-- using function in the filter criteria

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_SalesOrderHeader_OrderDate')
	DROP INDEX IX_SalesOrderHeader_OrderDate ON [Sales].[SalesOrderHeader];
GO
CREATE NONCLUSTERED INDEX IX_SalesOrderHeader_OrderDate
ON [Sales].[SalesOrderHeader] ([OrderDate])
INCLUDE ([AccountNumber])
GO

SET NOCOUNT ON

DECLARE @StartTime DATETIME
SET @StartTime = GETDATE()

SELECT AccountNumber
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2011

PRINT 'Duration with function: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) AS varchar(10)) + ' ms'

SET @StartTime = GETDATE()

SELECT AccountNumber
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '2011-01-01' 
  AND OrderDate < '2012-01-01'

PRINT 'Duration without function: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) AS varchar(10)) + ' ms'