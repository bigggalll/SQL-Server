USE AdventureWorks2014
GO

-- Catch all queries
SET NOCOUNT ON
DECLARE @OrderDate datetime
DECLARE @AccountNumber AccountNumber

DECLARE @StartTime DATETIME

--Set @OrderDate = '2003-01-17'
SET @AccountNumber = '10-4020-000118'
SET @StartTime = GETDATE()


SELECT AccountNumber, OrderDate, ProductID, SUM(OrderQty) 
FROM Sales.SalesOrderHeader
JOIN Sales.SalesOrderDetail ON SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID
WHERE (OrderDate >= @OrderDate OR @OrderDate IS NULL)
  AND (AccountNumber = @AccountNumber OR @AccountNumber IS NULL)
GROUP BY AccountNumber, OrderDate, ProductID

print 'Duration with catch all: ' + CAST(DATEDIFF(ms, @StartTime, getdate()) as varchar(10)) + ' ms'

SET @StartTime = GETDATE()

DECLARE @sql nvarchar(max)

SELECT @sql = 'SELECT AccountNumber, OrderDate, ProductID, SUM(OrderQty) 
FROM Sales.SalesOrderHeader
JOIN Sales.SalesOrderDetail ON SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID
WHERE 1=1
' + 
CASE 
	WHEN @OrderDate IS NOT NULL 
	 THEN 'AND (OrderDate >= @OrderDate)
' 
	ELSE '' 
END + 
CASE
	WHEN @AccountNumber IS NOT NULL
	 THEN 'AND (AccountNumber = @AccountNumber)
'
	ELSE '' 
END +
'GROUP BY AccountNumber, OrderDate, ProductID
'


EXEC sp_executesql 
			@sql, 
			N'@OrderDate datetime, @AccountNumber AccountNumber',
			@OrderDate = @OrderDate, @AccountNumber = @AccountNumber
	
print 'Duration with specific filter: ' + CAST(DATEDIFF(ms, @StartTime, getdate()) as varchar(10)) + ' ms'
