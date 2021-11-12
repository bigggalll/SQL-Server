USE AdventureWorks2014
GO


IF OBJECT_ID('fn_GetProductIDList') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.fn_GetProductIDList;
END
GO

CREATE FUNCTION [dbo].[fn_GetProductIDList]
(
	@SalesOrderID INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @product_ids NVARCHAR(MAX);

	SELECT @product_ids = COALESCE(@product_ids + ',', '') +  CAST(ProductID AS VARCHAR)
	FROM Sales.SalesOrderDetailEnlarged AS sod
	WHERE SalesOrderID = @SalesOrderID 

	RETURN @product_ids;
END
GO

SET NOCOUNT ON
SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT 
	SalesOrderID, 
	CustomerID, 
	OrderDate, 
	[dbo].[fn_GetProductIDList](SalesOrderID) AS ProductIDList
FROM Sales.SalesOrderHeader
WHERE SalesPersonID = 285
GO

SELECT 
	SalesOrderID, 
	CustomerID, 
	OrderDate, 
	[dbo].[fn_GetProductIDList](SalesOrderID) AS ProductIDList
FROM Sales.SalesOrderHeaderEnlarged
WHERE SalesPersonID = 277
GO



-- Open XE Session to watch activity


IF OBJECT_ID('fn_GetProductIDList') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.fn_GetProductIDList;
END
GO

CREATE FUNCTION [dbo].[fn_GetProductIDList]
(
	@SalesOrderID INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @product_ids NVARCHAR(MAX);

	SELECT @product_ids = STUFF((
								SELECT ',' + CAST(ProductID AS VARCHAR)
								FROM Sales.SalesOrderDetailEnlarged AS sod
								WHERE SalesOrderID = @SalesOrderID
								FOR XML PATH(''))
								,1,1,'') 

	RETURN @product_ids;
END
GO


SELECT 
	SalesOrderID, 
	CustomerID, 
	OrderDate, 
	[dbo].[fn_GetProductIDList](SalesOrderID) AS ProductIDList
FROM Sales.SalesOrderHeader
WHERE SalesPersonID = 285
GO

SELECT 
	SalesOrderID, 
	CustomerID, 
	OrderDate, 
	[dbo].[fn_GetProductIDList](SalesOrderID) AS ProductIDList
FROM Sales.SalesOrderHeaderEnlarged
WHERE SalesPersonID = 277
GO



-- No function at all - 


SELECT 
	SalesOrderID, 
	CustomerID, 
	OrderDate, 
	STUFF((
			SELECT ',' + CAST(ProductID AS VARCHAR)
			FROM Sales.SalesOrderDetailEnlarged AS sod
			WHERE sod.SalesOrderID = soh.SalesOrderID
			FOR XML PATH(''))
			,1,1,'')  AS ProductIDList
FROM Sales.SalesOrderHeader AS soh
WHERE SalesPersonID = 285
GO

SELECT 
	SalesOrderID, 
	CustomerID, 
	OrderDate, 
	STUFF((
			SELECT ',' + CAST(ProductID AS VARCHAR)
			FROM Sales.SalesOrderDetailEnlarged AS sod
			WHERE sod.SalesOrderID = soh.SalesOrderID
			FOR XML PATH(''))
			,1,1,'')  AS ProductIDList
FROM Sales.SalesOrderHeaderEnlarged AS soh
WHERE SalesPersonID = 277
GO





IF OBJECT_ID('tvf_GetProductIDList') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.tvf_GetProductIDList;
END
GO

CREATE FUNCTION [dbo].[tvf_GetProductIDList]
(
	@SalesOrderID INT
)
RETURNS TABLE
AS RETURN
(
	SELECT ProductIDList = STUFF((
						SELECT ',' + CAST(ProductID AS VARCHAR)
						FROM Sales.SalesOrderDetailEnlarged AS sod
						WHERE SalesOrderID = @SalesOrderID
						FOR XML PATH(''))
						,1,1,'')        
)

GO



SELECT 
	SalesOrderID, 
	CustomerID, 
	OrderDate, 
	p.ProductIDList
FROM Sales.SalesOrderHeader AS soh
CROSS APPLY [dbo].[tvf_GetProductIDList](SalesOrderID) AS p
WHERE SalesPersonID = 285
GO

SELECT 
	SalesOrderID, 
	CustomerID, 
	OrderDate, 
	p.ProductIDList
FROM Sales.SalesOrderHeaderEnlarged
CROSS APPLY [dbo].[tvf_GetProductIDList](SalesOrderID) AS p
WHERE SalesPersonID = 277
GO