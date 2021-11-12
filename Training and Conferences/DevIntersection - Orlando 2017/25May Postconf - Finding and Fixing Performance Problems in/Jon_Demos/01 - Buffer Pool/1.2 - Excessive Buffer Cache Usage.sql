USE AdventureWorks2014;
GO

WHILE 1=1
BEGIN

DECLARE @SalesOrderID INT, @AccountNumber NVARCHAR(30), @TotalFreight MONEY, 
	@DistinctItemTotal INT, @TotalItemCount INT

-- Create a significant I/O and tempdb query
SELECT 
	@SalesOrderID = soh.SalesOrderID, 
	@AccountNumber = soh.AccountNumber, 
	@TotalFreight = SUM(soh.Freight),
	@DistinctItemTotal = COUNT(DISTINCT sod.ProductID),
	@TotalItemCount = SUM(OrderQty)
FROM Sales.SalesOrderHeaderEnlarged AS soh
INNER HASH JOIN Sales.SalesOrderDetailEnlarged AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.OrderDate BETWEEN '01/01/2009' AND '01/01/2015'
GROUP BY 
	soh.SalesOrderID, 
	soh.AccountNumber

END

