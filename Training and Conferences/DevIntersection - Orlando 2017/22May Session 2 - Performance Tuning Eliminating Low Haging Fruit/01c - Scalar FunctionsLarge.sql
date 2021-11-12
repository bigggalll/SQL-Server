USE AdventureWorks2014
GO
IF OBJECT_ID('dbo.ufn_GetSalesTotalByProductID') IS NOT NULL
	DROP FUNCTION dbo.ufn_GetSalesTotalByProductID
GO
CREATE FUNCTION dbo.ufn_GetSalesTotalByProductID(@ProductID int)
RETURNS money
AS
BEGIN
	DECLARE @Total money	

	SELECT @Total = SUM(LineTotal)
	FROM Sales.SalesOrderDetailEnlarged sd 
	WHERE sd.ProductID = @ProductID 

	RETURN(@Total)
END
GO
IF OBJECT_ID('dbo.ufn_GetDiscountTotalByProductID') IS NOT NULL	
	DROP FUNCTION dbo.ufn_GetDiscountTotalByProductID
GO
CREATE FUNCTION dbo.ufn_GetDiscountTotalByProductID(@ProductID int)
RETURNS money
AS
BEGIN
	DECLARE @Total money	

	SELECT @Total = SUM(LineTotal*UnitPriceDiscount) 
	FROM Sales.SalesOrderDetailEnlarged sd 
	WHERE sd.ProductID = @ProductID 

	RETURN(@Total)
END

GO

SET NOCOUNT ON

DECLARE @StartTime DATETIME
SET @StartTime = GETDATE()

SELECT	ProductID, 
		ProductNumber,
		dbo.ufn_GetSalesTotalByProductID(ProductID) as SumTotal,
		dbo.ufn_GetDiscountTotalByProductID(ProductID) as SumDiscount
FROM Production.Product p
WHERE ProductNumber like 'BK%'
  AND 	dbo.ufn_GetSalesTotalByProductID(ProductID) IS NOT NULL
  AND	dbo.ufn_GetDiscountTotalByProductID(ProductID) > dbo.ufn_GetSalesTotalByProductID(ProductID)*0.01

PRINT 'Duration with Scalar UDF: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) AS varchar(10)) + ' ms'

SET @StartTime = GETDATE()

SELECT p.ProductID, ProductNumber, SumTotal, SumDiscount
FROM Production.Product p
INNER JOIN (
				SELECT ProductID, SUM(LineTotal) SumTotal, SUM(LineTotal*UnitPriceDiscount) SumDiscount 
				FROM Sales.SalesOrderDetailEnlarged 
				GROUP BY ProductID
				HAVING SUM(LineTotal*UnitPriceDiscount) > SUM(LineTotal)*0.01 
			) SalesTotals on p.ProductID = SalesTotals.ProductID
WHERE ProductNumber like 'BK%'

PRINT 'Duration with derived table: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) AS varchar(10)) + ' ms'

GO

IF OBJECT_ID('dbo.tvf_GetSalesTotalByProductID') IS NOT NULL
	DROP FUNCTION dbo.tvf_GetSalesTotalByProductID
GO
CREATE FUNCTION dbo.tvf_GetSalesTotalByProductID(@ProductID int)
RETURNS TABLE
AS RETURN (
	SELECT SUM(LineTotal) AS ProductTotal
	FROM Sales.SalesOrderDetailEnlarged sd 
	WHERE sd.ProductID = @ProductID 
)

GO
IF OBJECT_ID('dbo.tvf_GetDiscountTotalByProductID') IS NOT NULL	
	DROP FUNCTION dbo.tvf_GetDiscountTotalByProductID
GO
CREATE FUNCTION dbo.tvf_GetDiscountTotalByProductID(@ProductID int)
RETURNS TABLE
AS RETURN (
	SELECT SUM(LineTotal*UnitPriceDiscount) AS DiscountTotal
	FROM Sales.SalesOrderDetailEnlarged sd 
	WHERE sd.ProductID = @ProductID 
)
GO


DECLARE @StartTime DATETIME
SET @StartTime = GETDATE()

SELECT p.ProductID, ProductNumber, st.ProductTotal AS SumTotal, d.DiscountTotal AS SumDiscount
FROM Production.Product p
CROSS APPLY dbo.tvf_GetDiscountTotalByProductID(p.ProductID) AS d
CROSS APPLY dbo.tvf_GetSalesTotalByProductID(p.ProductID) AS st
WHERE ProductNumber like 'BK%'

PRINT 'Duration with inline TVF: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) AS varchar(10)) + ' ms'

GO

-- Chagne to InnerJoin without param
DECLARE @StartTime DATETIME
SET @StartTime = GETDATE()

SELECT p.ProductID, ProductNumber, st.ProductTotal AS SumTotal, d.DiscountTotal AS SumDiscount
FROM Production.Product p
CROSS APPLY dbo.tvf_GetDiscountTotalByProductID(p.ProductID) AS d
CROSS APPLY dbo.tvf_GetSalesTotalByProductID(p.ProductID) AS st
WHERE ProductNumber like 'BK%'

PRINT 'Duration with inline TVF: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) AS varchar(10)) + ' ms'

GO