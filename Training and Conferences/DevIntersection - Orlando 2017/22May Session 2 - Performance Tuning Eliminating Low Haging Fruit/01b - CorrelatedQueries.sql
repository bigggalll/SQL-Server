USE AdventureWorks2014
GO

SET NOCOUNT ON

DECLARE @StartTime DATETIME
SET @StartTime = GETDATE()

SELECT	ProductID, 
		ProductNumber,
		(
			SELECT SUM(LineTotal) SumTotal 
			FROM Sales.SalesOrderDetail sd 
			WHERE sd.ProductID = p.ProductID 
		) as SumTotal,
		(
			SELECT SUM(LineTotal*UnitPriceDiscount) SumDiscount 
			FROM Sales.SalesOrderDetail sd 
			WHERE sd.ProductID = p.ProductID 
		) as SumDiscount
FROM Production.Product p
WHERE ProductNumber like 'BK%'
  AND 	(
			SELECT SUM(LineTotal) SumTotal 
			FROM Sales.SalesOrderDetail sd 
			WHERE sd.ProductID = p.ProductID 
		) IS NOT NULL
  AND	(
			SELECT SUM(LineTotal*UnitPriceDiscount) SumDiscount 
			FROM Sales.SalesOrderDetail sd 
			WHERE sd.ProductID = p.ProductID 
		) > (
				SELECT SUM(LineTotal) SumTotal 
				FROM Sales.SalesOrderDetail sd 
				WHERE sd.ProductID = p.ProductID 
			)*0.01

PRINT 'Duration with correlated subqueries: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) AS varchar(10)) + ' ms'

SET @StartTime = GETDATE()

SELECT p.ProductID, ProductNumber, SumTotal, SumDiscount
FROM Production.Product p
INNER JOIN (
				SELECT ProductID, SUM(LineTotal) SumTotal, SUM(LineTotal*UnitPriceDiscount) SumDiscount 
				FROM Sales.SalesOrderDetail 
				GROUP BY ProductID
				HAVING SUM(LineTotal*UnitPriceDiscount) > SUM(LineTotal)*0.01 
			) SalesTotals on p.ProductID = SalesTotals.ProductID
WHERE ProductNumber like 'BK%'

PRINT 'Duration with derived table: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) AS varchar(10)) + ' ms'

