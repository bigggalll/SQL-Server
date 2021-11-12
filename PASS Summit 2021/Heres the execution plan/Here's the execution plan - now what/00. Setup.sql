/*
This script contains all setup code for the demo queries.
Make sure to execute it before the presentation.
Contents should not be shown during the presentation.
*/

USE AdventureWorks2017;
GO

-- Make sure we're in the right database compatibility level for our demos
ALTER DATABASE AdventureWorks2017 SET COMPATIBILITY_LEVEL = 140;

-- Set up the query store. Clear out old stuff first, then configure
-- These values are NOT recommended for production work!!!!
ALTER DATABASE AdventureWorks2017 SET QUERY_STORE CLEAR;
ALTER DATABASE AdventureWorks2017
SET QUERY_STORE
        (OPERATION_MODE = READ_WRITE,
         DATA_FLUSH_INTERVAL_SECONDS = 60,
         INTERVAL_LENGTH_MINUTES = 1);
GO


-- Stored procedure for demo 01. Excessive IO.
DROP PROCEDURE IF EXISTS dbo.SalesByRegions;
GO

CREATE PROCEDURE dbo.SalesByRegions
    @BillRegion        nvarchar(50),
    @ShipRegion        nvarchar(50),
    @SalespersonRegion nvarchar(50)
AS
BEGIN;
    -- We need to join SalesOrderHeader --> Address --> StateProvince --> SalesTerritory --> CountryRegion two times.
    -- We also need to join SalesOrderHeader --> SalesPerson --> SalesTerritory --> CountryRegion once.
    -- To reduce code duplication and increase speed, we will first do these joins
    -- (SP --> ST --> CR and A --> SP --> ST --> CR) and store the result in table variables.
    -- The join to SalesPerson then becomes much more efficient

    -- First do the join SalesTerritory --> CountryRegion
    DECLARE @SalesTerritoryToCountryRegionName table
        (TerritoryID       int          NOT NULL,
         CountryRegionName nvarchar(50) NOT NULL);

    INSERT INTO @SalesTerritoryToCountryRegionName (TerritoryID,
                                                    CountryRegionName)
    SELECT     st.TerritoryID,
               cr.Name
    FROM       Sales.SalesTerritory AS st
    INNER JOIN Person.CountryRegion AS cr
       ON      cr.CountryRegionCode = st.CountryRegionCode;

    -- Now SalesPersion --> SalesTerritory --> CountryRegion
    DECLARE @SalesPersonToCountryRegionName table
        (SalesPersonID     int          NOT NULL,
         CountryRegionName nvarchar(50) NOT NULL);

    INSERT INTO @SalesPersonToCountryRegionName (SalesPersonID,
                                                 CountryRegionName)
    SELECT     sp.BusinessEntityID,
               sttcrn.CountryRegionName
    FROM       Sales.SalesPerson                  AS sp
    INNER JOIN @SalesTerritoryToCountryRegionName AS sttcrn
       ON      sttcrn.TerritoryID = sp.TerritoryID;

    -- And finally Address --> StateProvince --> SalesTerritory --> CountryRegion
    DECLARE @AddressToCountryRegionName table
        (AddressID         int          NOT NULL,
         CountryRegionName nvarchar(50) NOT NULL);

    INSERT INTO @AddressToCountryRegionName (AddressID,
                                             CountryRegionName)
    SELECT     a.AddressID,
               cr.Name
    FROM       Person.Address       AS a
    INNER JOIN Person.StateProvince AS sp
       ON      sp.StateProvinceID   = a.StateProvinceID
    INNER JOIN Sales.SalesTerritory AS st
       ON      st.TerritoryID       = sp.TerritoryID
    INNER JOIN Person.CountryRegion AS cr
       ON      cr.CountryRegionCode = st.CountryRegionCode;

    -- Now let's do the actual query
    SELECT     p.Color,
               COUNT (DISTINCT sod.ProductID)    AS NumProducts,
               COUNT (DISTINCT sod.SalesOrderID) AS NumOrders,
               SUM (sod.OrderQty)                AS TotalQty,
               SUM (soh.SubTotal)                AS TotalPrice
    FROM       Sales.SalesOrderHeader          AS soh
    INNER JOIN Sales.SalesOrderDetail          AS sod
       ON      sod.SalesOrderID       = soh.SalesOrderID
    INNER JOIN Production.Product              AS p
       ON      p.ProductID            = sod.ProductID
    INNER JOIN @AddressToCountryRegionName     AS BillRegion
       ON      BillRegion.AddressID   = soh.BillToAddressID
    INNER JOIN @AddressToCountryRegionName     AS ShipRegion
       ON      ShipRegion.AddressID   = soh.ShipToAddressID
    INNER JOIN @SalesPersonToCountryRegionName AS SpRegion
       ON      SpRegion.SalesPersonID = soh.SalesPersonID
    WHERE      BillRegion.CountryRegionName = @BillRegion
    AND        ShipRegion.CountryRegionName        = @ShipRegion
    AND        SpRegion.CountryRegionName          = @SalespersonRegion
    GROUP BY   p.Color
    ORDER BY   TotalPrice DESC,
               TotalQty DESC;
END;
GO


-- Stored procedure for demo 02. Resource semaphore.
DROP PROCEDURE IF EXISTS dbo.PaginatedSalesReport;
GO

CREATE PROCEDURE dbo.PaginatedSalesReport @PageNum int = 1
AS
BEGIN;
    CREATE TABLE #AllResults
        (RowID         int          NOT NULL IDENTITY PRIMARY KEY,
         ProductNumber nvarchar(25) NOT NULL,
         DiscountPct   smallmoney   NOT NULL,
         OrderDate     datetime     NOT NULL,
         LastName      nvarchar(50) NOT NULL,
         TotalOrderQty int          NOT NULL);

    WITH AggregatedSalesData
      AS (SELECT     sod.ProductID,
                     sod.SpecialOfferID,
                     soh.OrderDate,
                     soh.CustomerID,
                     SUM (sod.OrderQty) AS TotalOrderQty
          FROM       Sales.SalesOrderDetail AS sod
          INNER JOIN Sales.SalesOrderHeader AS soh
             ON      soh.SalesOrderID = sod.SalesOrderID
          GROUP BY   sod.ProductID,
                     sod.SpecialOfferID,
                     soh.OrderDate,
                     soh.CustomerID)
    INSERT INTO #AllResults (ProductNumber,
                             DiscountPct,
                             OrderDate,
                             LastName,
                             TotalOrderQty)
    SELECT     p.ProductNumber,
               so.DiscountPct,
               asd.OrderDate,
               p2.LastName,
               asd.TotalOrderQty
    FROM       AggregatedSalesData AS asd
    INNER JOIN Production.Product  AS p
       ON      p.ProductID         = asd.ProductID
    INNER JOIN Sales.SpecialOffer  AS so
       ON      so.SpecialOfferID   = asd.SpecialOfferID
    INNER JOIN Sales.Customer      AS c
       ON      c.CustomerID        = asd.CustomerID
    INNER JOIN Person.Person       AS p2
       ON      p2.BusinessEntityID = c.PersonID
    ORDER BY   asd.TotalOrderQty DESC;

    SELECT ProductNumber,
           DiscountPct,
           OrderDate,
           LastName,
           TotalOrderQty
    FROM   #AllResults
    WHERE  RowID BETWEEN @PageNum * 20 - 19
                 AND     @PageNum * 20;
END;
GO


-- Stored procedure for demo 03. Erratic performance.
DROP PROCEDURE IF EXISTS dbo.FindOrders;
GO

CREATE PROCEDURE dbo.FindOrders
    @SalesOrderID     int          = NULL,
    @OrderMonth       char(6)      = NULL, -- Format YYYYMM
    @ShipMonth        char(6)      = NULL, -- Format YYYYMM
    @CustomerID       int          = NULL,
    @SalesPersonID    int          = NULL,
    @ProductID        int          = NULL,
    @CustomerLastName nvarchar(50) = NULL
AS
BEGIN;
    -- First find all orders based on the supplied search parameters.
    -- We can skip this step is @SalesOrderID is given
    IF @SalesOrderID IS NULL
    BEGIN;
        DECLARE @SalesOrders table
            (SalesOrderID int NOT NULL PRIMARY KEY);

        INSERT INTO @SalesOrders (SalesOrderID)
        SELECT     soh.SalesOrderID
        FROM       Sales.SalesOrderHeader AS soh
        INNER JOIN Sales.Customer         AS c
           ON      c.CustomerID       = soh.CustomerID
        INNER JOIN Person.Person          AS p
           ON      p.BusinessEntityID = c.PersonID
        WHERE      (@SalesOrderID IS NULL
                 OR soh.SalesOrderID          = @SalesOrderID)
        AND
                   (@OrderMonth IS NULL
                 OR FORMAT (soh.OrderDate, 'yyyyMM') = @OrderMonth)
        AND
                   (@ShipMonth IS NULL
                 OR FORMAT (soh.ShipDate, 'yyyyMM')  = @ShipMonth)
        AND
                   (@CustomerID IS NULL
                 OR soh.CustomerID                   = @CustomerID)
        AND
                   (@SalesPersonID IS NULL
                 OR soh.SalesPersonID                = @SalesPersonID)
        AND
                   (@ProductID IS NULL
                 OR EXISTS
            (SELECT *
             FROM   Sales.SalesOrderDetail AS sod
             WHERE  sod.SalesOrderID = soh.SalesOrderID
             AND    sod.ProductID       = @ProductID))
        AND
                   (@CustomerLastName IS NULL
                 OR p.LastName                       = @CustomerLastName);
    END;

    -- We have the SalesOrderID values in the table or in @SalesOrderID
    -- Now we can return the data
    SELECT     soh.SalesOrderID,
               soh.OrderDate,
               soh.ShipDate,
               soh.Status,
               soh.SalesOrderNumber,
               p.FirstName,
               p.LastName,
               sp.SalesYTD,
               soh.SubTotal,
               sod.TotalQty,
               sod.AvgPrice
    FROM       Sales.SalesOrderHeader                      AS soh
    CROSS APPLY
               (SELECT SUM (sod.OrderQty)  AS TotalQty,
                       AVG (sod.UnitPrice) AS AvgPrice
                FROM   Sales.SalesOrderDetail AS sod
                WHERE  sod.SalesOrderID = soh.SalesOrderID) AS sod
    INNER JOIN Sales.Customer    AS c
       ON      c.CustomerID        = soh.CustomerID
    INNER JOIN Person.Person     AS p
       ON      p.BusinessEntityID  = c.PersonID
    LEFT JOIN  Sales.SalesPerson AS sp
      ON       sp.BusinessEntityID = soh.SalesPersonID
    WHERE      soh.SalesOrderID = @SalesOrderID
    OR         soh.SalesOrderID IN
                   (SELECT so.SalesOrderID FROM @SalesOrders AS so);
END;
GO

-- Now run a bunch of sample executions to mimic a workload,
-- with some simulated evicitions of the execution plan from the plan cache
EXEC dbo.FindOrders @SalesOrderID = 43729;
EXEC dbo.FindOrders @OrderMonth = '201311', @ShipMonth = '201312';
EXEC dbo.FindOrders @CustomerID = 28645;
EXEC dbo.FindOrders @SalesPersonID = 281, @CustomerLastName = 'Adams';
EXEC dbo.FindOrders @ProductID = 709, @ShipMonth = '201202';
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
EXEC dbo.FindOrders @OrderMonth = '201311', @ShipMonth = '201312';
EXEC dbo.FindOrders @CustomerID = 28645;
EXEC dbo.FindOrders @SalesPersonID = 281, @CustomerLastName = 'Adams';
EXEC dbo.FindOrders @ProductID = 709, @ShipMonth = '201202';
EXEC dbo.FindOrders @SalesOrderID = 43729;
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
EXEC dbo.FindOrders @CustomerID = 28645;
EXEC dbo.FindOrders @SalesPersonID = 281, @CustomerLastName = 'Adams';
EXEC dbo.FindOrders @ProductID = 709, @ShipMonth = '201202';
EXEC dbo.FindOrders @SalesOrderID = 43729;
EXEC dbo.FindOrders @OrderMonth = '201311', @ShipMonth = '201312';
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
EXEC dbo.FindOrders @SalesPersonID = 281, @CustomerLastName = 'Adams';
EXEC dbo.FindOrders @ProductID = 709, @ShipMonth = '201202';
EXEC dbo.FindOrders @SalesOrderID = 43729;
EXEC dbo.FindOrders @OrderMonth = '201311', @ShipMonth = '201312';
EXEC dbo.FindOrders @CustomerID = 28645;
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
EXEC dbo.FindOrders @SalesPersonID = 281, @CustomerLastName = 'Adams';
EXEC dbo.FindOrders @ProductID = 709, @ShipMonth = '201202';
EXEC dbo.FindOrders @SalesOrderID = 43729;
EXEC dbo.FindOrders @OrderMonth = '201311', @ShipMonth = '201312';
EXEC dbo.FindOrders @CustomerID = 28645;
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
EXEC dbo.FindOrders @CustomerID = 28645;
GO
