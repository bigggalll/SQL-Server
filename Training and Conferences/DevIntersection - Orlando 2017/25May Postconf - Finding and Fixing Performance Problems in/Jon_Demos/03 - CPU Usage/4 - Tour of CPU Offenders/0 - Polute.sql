USE AdventureWorks2014
GO

SET ROWCOUNT 1000
GO
    
/*
USE AdventureWorks2014
GO
DROP TABLE Sales.Tmp_SalesOrderDetail
GO
CREATE TABLE Sales.Tmp_SalesOrderDetail
	(
	SalesOrderID int NOT NULL,
	SalesOrderDetailID int NOT NULL IDENTITY (1, 1),
	CarrierTrackingNumber varchar(25) NULL,
	OrderQty smallint NOT NULL,
	ProductID int NOT NULL,
	SpecialOfferID int NOT NULL,
	UnitPrice money NOT NULL,
	UnitPriceDiscount money NOT NULL,
	LineTotal  AS (isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0))),
	rowguid uniqueidentifier NOT NULL ROWGUIDCOL,
	ModifiedDate datetime NOT NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT Sales.Tmp_SalesOrderDetail ON
GO
IF EXISTS(SELECT * FROM Sales.SalesOrderDetail)
	 EXEC('INSERT INTO Sales.Tmp_SalesOrderDetail (SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate)
		SELECT SalesOrderID, SalesOrderDetailID, CONVERT(varchar(25), CarrierTrackingNumber), OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate FROM Sales.SalesOrderDetail WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT Sales.Tmp_SalesOrderDetail OFF
GO
ALTER TABLE Sales.Tmp_SalesOrderDetail ADD CONSTRAINT
	PK_Tmp_SalesOrderDetail_SalesOrderID_SalesOrderDetailID PRIMARY KEY CLUSTERED 
	(
	SalesOrderID,
	SalesOrderDetailID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX AK_Tmp_SalesOrderDetail_rowguid ON Sales.Tmp_SalesOrderDetail
	(
	rowguid
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX IX_Tmp_SalesOrderDetail_ProductID ON Sales.Tmp_SalesOrderDetail
	(
	ProductID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

USE AdventureWorks2014
GO
DROP FUNCTION ufn_GetSalesTotalByProductID
GO
CREATE FUNCTION ufn_GetSalesTotalByProductID(@ProductID int)
RETURNS money
AS
BEGIN
	DECLARE @Total money	

	SELECT @Total = SUM(LineTotal)
	FROM Sales.SalesOrderDetail sd 
	WHERE sd.ProductID = @ProductID 

	RETURN(@Total)
END
GO
DROP FUNCTION ufn_GetDiscountTotalByProductID
GO
CREATE FUNCTION ufn_GetDiscountTotalByProductID(@ProductID int)
RETURNS money
AS
BEGIN
	DECLARE @Total money	

	SELECT @Total = SUM(LineTotal*UnitPriceDiscount) 
	FROM Sales.SalesOrderDetail sd 
	WHERE sd.ProductID = @ProductID 

	RETURN(@Total)
END
GO
*/

    SELECT p.Size AS ProductSize,
           SUM(p.ListPrice) AS TotalPrice
    FROM Production.Product AS p
    INNER JOIN Production.ProductCategory AS pc
    ON p.ProductSubcategoryID = pc.ProductCategoryID
    WHERE p.Color = 'Blue'
    GROUP BY p.Size
    ORDER BY ProductSize, TotalPrice;
GO

    SELECT p.Size AS ProductSize,
           SUM(p.ListPrice) AS TotalPrice
    FROM Production.Product AS p
    INNER JOIN Production.ProductCategory AS pc
    ON p.ProductSubcategoryID = pc.ProductCategoryID
    WHERE p.Color = 'Red'
    GROUP BY p.Size
    ORDER BY ProductSize, TotalPrice;  
    
    GO
    
    SELECT p.Size AS ProductSize,
           SUM(p.ListPrice) AS TotalPrice
    FROM Production.Product AS p
    INNER JOIN Production.ProductCategory AS pc
    ON p.ProductSubcategoryID = pc.ProductCategoryID
    WHERE p.Color = 'Black'
    GROUP BY p.Size
    ORDER BY ProductSize, TotalPrice;  
    
GO

SELECT soh.SalesOrderID, COUNT(*) as DetailCount
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod 
	ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.SalesOrderID > 1
GROUP BY soh.SalesOrderID
GO

SELECT soh.SalesOrderID, SUM(sod.LineTotal) as DetailTotal
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod 
	ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.SalesOrderID > 15
GROUP BY soh.SalesOrderID
GO


SELECT soh.SalesOrderID, SUM(sod.LineTotal) as DetailTotal
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod 
	ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.SalesOrderID > 50000
GROUP BY soh.SalesOrderID
GO

SELECT soh.SalesOrderID, SUM(sod.LineTotal) as DetailTotal
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod 
	ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.SalesOrderID > 45000
GROUP BY soh.SalesOrderID
GO

USE AdventureWorks2014
GO
SELECT P.BusinessEntityID, P.FirstName, P.LastName, A.AddressLine1, A.City, 
    StP.Name AS State, CR.Name AS CountryRegion
FROM Person.Person AS P
    JOIN Person.BusinessEntityAddress AS BEA ON BEA.BusinessEntityID = P.BusinessEntityID
    JOIN Person.Address AS A ON A.AddressID = BEA.BusinessEntityID
    JOIN Person.StateProvince StP ON 
        StP.StateProvinceID = A.StateProvinceID
    JOIN Person.CountryRegion CR ON 
        CR.CountryRegionCode = StP.CountryRegionCode
ORDER BY P.BusinessEntityID ;
GO
SELECT S.Name AS Store, P.FirstName, P.LastName, CT.Name AS Title 
FROM Person.Person AS P 
	JOIN Person.BusinessEntityContact AS BEC ON P.BusinessEntityID = BEC.BusinessEntityID
    JOIN Sales.Customer AS SC ON P.BusinessEntityID = SC.PersonID
    JOIN Person.ContactType AS CT ON 
        CT.ContactTypeID = BEC.BusinessEntityID 
    JOIN Sales.Store AS S ON S.BusinessEntityID = SC.CustomerID
ORDER BY S.Name ;
GO
SELECT Name, SalesOrderNumber, OrderDate, TotalDue
FROM Sales.Store AS S
    JOIN Sales.SalesOrderHeader AS SO ON S.BusinessEntityID = SO.CustomerID
ORDER BY Name, OrderDate ;
GO
SELECT PM.ProductModelID, PM.Name AS [Product Model], Description, PL.CultureID, CL.Name AS Language
FROM Production.ProductModel AS PM 
    JOIN Production.ProductModelProductDescriptionCulture AS PL 
        ON PM.ProductModelID = PL.ProductModelID
    JOIN Production.Culture AS CL ON CL.CultureID = PL.CultureID
    JOIN Production.ProductDescription AS PD 
        ON PD.ProductDescriptionID = PL.ProductDescriptionID
ORDER BY PM.ProductModelID ;
GO
WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS
(
    SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty,
        b.EndDate, 0 AS ComponentLevel
    FROM Production.BillOfMaterials AS b
    WHERE b.ProductAssemblyID = 800
          AND b.EndDate IS NULL
    UNION ALL
    SELECT bom.ProductAssemblyID, bom.ComponentID, p.PerAssemblyQty,
        bom.EndDate, ComponentLevel + 1
    FROM Production.BillOfMaterials AS bom 
        INNER JOIN Parts AS p
        ON bom.ProductAssemblyID = p.ComponentID
        AND bom.EndDate IS NULL
)
SELECT AssemblyID, ComponentID, Name, PerAssemblyQty, EndDate,
        ComponentLevel 
FROM Parts AS p
    INNER JOIN Production.Product AS pr
    ON p.ComponentID = pr.ProductID
ORDER BY ComponentLevel, AssemblyID, ComponentID;
GO
SELECT PM.ProductModelID, PM.Name AS [Product Model], Description, PL.CultureID, CL.Name AS Language
FROM Production.ProductModel AS PM 
    JOIN Production.ProductModelProductDescriptionCulture AS PL 
        ON PM.ProductModelID = PL.ProductModelID
    JOIN Production.Culture AS CL ON CL.CultureID = PL.CultureID
    JOIN Production.ProductDescription AS PD 
        ON PD.ProductDescriptionID = PL.ProductDescriptionID
WHERE PM.Name LIKE '%Tour%'
ORDER BY PM.ProductModelID ;
GO
SELECT PC.Name AS Category, PSC.Name AS Subcategory,
    PM.Name AS Model, P.Name AS Product
FROM Production.Product AS P
    FULL JOIN Production.ProductModel AS PM ON PM.ProductModelID = P.ProductModelID
    FULL JOIN Production.ProductSubcategory AS PSC ON PSC.ProductSubcategoryID = P.ProductSubcategoryID
    JOIN Production.ProductCategory AS PC ON PC.ProductCategoryID = PSC.ProductCategoryID
ORDER BY PC.Name, PSC.Name ;
GO
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
GO
SELECT p.ProductID, ProductNumber, SumTotal, SumDiscount
FROM Production.Product p
INNER JOIN (
				SELECT ProductID, SUM(LineTotal) SumTotal, 
								SUM(LineTotal*UnitPriceDiscount) SumDiscount 
				FROM Sales.SalesOrderDetail 
				GROUP BY ProductID
				HAVING SUM(LineTotal*UnitPriceDiscount) > SUM(LineTotal)*0.01 
			) SalesTotals on p.ProductID = SalesTotals.ProductID
WHERE ProductNumber like 'BK%'
GO
SELECT	ProductID, 
		ProductNumber,
		dbo.ufn_GetSalesTotalByProductID(ProductID) as SumTotal,
		dbo.ufn_GetDiscountTotalByProductID(ProductID) as SumDiscount
FROM Production.Product p
WHERE ProductNumber like 'BK%'
  AND 	dbo.ufn_GetSalesTotalByProductID(ProductID) IS NOT NULL
  AND	dbo.ufn_GetDiscountTotalByProductID(ProductID) > dbo.ufn_GetSalesTotalByProductID(ProductID)*0.01
GO
SELECT p.ProductID, ProductNumber, SumTotal, SumDiscount
FROM Production.Product p
INNER JOIN (
				SELECT ProductID, SUM(LineTotal) SumTotal, SUM(LineTotal*UnitPriceDiscount) SumDiscount 
				FROM Sales.SalesOrderDetail 
				GROUP BY ProductID
				HAVING SUM(LineTotal*UnitPriceDiscount) > SUM(LineTotal)*0.01 
			) SalesTotals on p.ProductID = SalesTotals.ProductID
WHERE ProductNumber like 'BK%'
GO
SELECT AccountNumber
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2003
GO
SELECT AccountNumber
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '2003-01-01' 
  AND OrderDate < '2004-01-01'
GO