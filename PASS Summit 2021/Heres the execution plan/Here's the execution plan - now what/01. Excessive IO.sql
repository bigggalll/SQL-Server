USE AdventureWorks2017;
GO

/*
Your DBA, or you, have identified a stored procedure that causes excessive I/O.
You need to identify the query (or queries) within the stored procedure that cause this;
find out why that query (or those queries) cause such high I/O;
and (obviously) find a way to resolve the issue.

Note that in this demo, there are only logical I/Os because the demo database is relatively small;
in a real life production system with a large database and many concurrent users, this might be physical I/O.
*/

-- Execute the query first. Seems fast enough.
EXEC dbo.SalesByRegions @BillRegion = N'United States',
                        @ShipRegion = N'United States',
                        @SalespersonRegion = N'United States';
GO

-- Open the text of the stored procedure. Hmmm. Where to start?

-- Request execution plan only (aka "estimated plan") for the stored procedure. Hmmm.

-- Let's try to identify the problem statement(s)
SET STATISTICS IO, TIME ON;
EXEC dbo.SalesByRegions @BillRegion = N'United States',
                        @ShipRegion = N'United States',
                        @SalespersonRegion = N'United States';
GO

-- Now run with execution plan plus run-time statistics
EXEC dbo.SalesByRegions @BillRegion = N'United States',
                        @ShipRegion = N'United States',
                        @SalespersonRegion = N'United States';
GO

-- Our biggest problem appears to be the table variables that
-- (a) have no statistics; and
-- (b) don't trigger recompiles when they are populated.
-- So the estimates are based on empty tables.
-- Let's use temporary tables instead
ALTER PROCEDURE dbo.SalesByRegions
    @BillRegion        nvarchar(50),
    @ShipRegion        nvarchar(50),
    @SalespersonRegion nvarchar(50)
AS
BEGIN;
    -- We need to join SalesOrderHeader --> Address --> StateProvince --> SalesTerritory --> CountryRegion two times.
    -- We also need to join SalesOrderHeader --> SalesPerson --> SalesTerritory --> CountryRegion once.
    -- To reduce code duplication and increase speed, we will first do these joins
    -- (SP --> ST --> CR and A --> SP --> ST --> CR) and store the result in temporary tables.
    -- The join to SalesPerson then becomes much more efficient

    -- First do the join SalesTerritory --> CountryRegion
    CREATE TABLE #SalesTerritoryToCountryRegionName
        (TerritoryID       int          NOT NULL,
         CountryRegionName nvarchar(50) NOT NULL);

    INSERT INTO #SalesTerritoryToCountryRegionName (TerritoryID,
                                                    CountryRegionName)
    SELECT     st.TerritoryID,
               cr.Name
    FROM       Sales.SalesTerritory AS st
    INNER JOIN Person.CountryRegion AS cr
       ON      cr.CountryRegionCode = st.CountryRegionCode;

    -- Now SalesPersion --> SalesTerritory --> CountryRegion
    CREATE TABLE #SalesPersonToCountryRegionName
        (SalesPersonID     int          NOT NULL,
         CountryRegionName nvarchar(50) NOT NULL);

    INSERT INTO #SalesPersonToCountryRegionName (SalesPersonID,
                                                 CountryRegionName)
    SELECT     sp.BusinessEntityID,
               sttcrn.CountryRegionName
    FROM       Sales.SalesPerson                  AS sp
    INNER JOIN #SalesTerritoryToCountryRegionName AS sttcrn
       ON      sttcrn.TerritoryID = sp.TerritoryID;

    -- And finally Address --> StateProvince --> SalesTerritory --> CountryRegion
    CREATE TABLE #AddressToCountryRegionName
        (AddressID         int          NOT NULL,
         CountryRegionName nvarchar(50) NOT NULL);

    INSERT INTO #AddressToCountryRegionName (AddressID,
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
    INNER JOIN #AddressToCountryRegionName     AS BillRegion
       ON      BillRegion.AddressID   = soh.BillToAddressID
    INNER JOIN #AddressToCountryRegionName     AS ShipRegion
       ON      ShipRegion.AddressID   = soh.ShipToAddressID
    INNER JOIN #SalesPersonToCountryRegionName AS SpRegion
       ON      SpRegion.SalesPersonID = soh.SalesPersonID
    WHERE      BillRegion.CountryRegionName = @BillRegion
    AND        ShipRegion.CountryRegionName        = @ShipRegion
    AND        SpRegion.CountryRegionName          = @SalespersonRegion
    GROUP BY   p.Color
    ORDER BY   TotalPrice DESC,
               TotalQty DESC;
END;
GO

-- Does this help?
EXEC dbo.SalesByRegions @BillRegion = N'United States',
                        @ShipRegion = N'United States',
                        @SalespersonRegion = N'United States';
GO

-- We did not fix all the issues.
-- We did get rid of 70K reads on the Product table, and one of the spills. It's a start.
-- The biggest remaining problem appears to be that there is still a bad estimate.
-- This is caused by correlation. The three "US" filters are highly correlated.
-- None of the cardinality estimator versions get that right.
-- And the filter being indirect (through joins) makes it even worse.
-- So let's accept that we get a bad estimate on the SalesOrderHeader table,
-- but try to prevent it from affecting the rest ... by using yet another temp table.

ALTER PROCEDURE dbo.SalesByRegions
    @BillRegion        nvarchar(50),
    @ShipRegion        nvarchar(50),
    @SalespersonRegion nvarchar(50)
AS
BEGIN;
    -- We need to join SalesOrderHeader --> Address --> StateProvince --> SalesTerritory --> CountryRegion two times.
    -- We also need to join SalesOrderHeader --> SalesPerson --> SalesTerritory --> CountryRegion once.
    -- To reduce code duplication and increase speed, we will first do these joins
    -- (SP --> ST --> CR and A --> SP --> ST --> CR) and store the result in temporary tables.
    -- The join to SalesPerson then becomes much more efficient

    -- First do the join SalesTerritory --> CountryRegion
    CREATE TABLE #SalesTerritoryToCountryRegionName
        (TerritoryID       int          NOT NULL,
         CountryRegionName nvarchar(50) NOT NULL);

    INSERT INTO #SalesTerritoryToCountryRegionName (TerritoryID,
                                                    CountryRegionName)
    SELECT     st.TerritoryID,
               cr.Name
    FROM       Sales.SalesTerritory AS st
    INNER JOIN Person.CountryRegion AS cr
       ON      cr.CountryRegionCode = st.CountryRegionCode;

    -- Now SalesPersion --> SalesTerritory --> CountryRegion
    CREATE TABLE #SalesPersonToCountryRegionName
        (SalesPersonID     int          NOT NULL,
         CountryRegionName nvarchar(50) NOT NULL);

    INSERT INTO #SalesPersonToCountryRegionName (SalesPersonID,
                                                 CountryRegionName)
    SELECT     sp.BusinessEntityID,
               sttcrn.CountryRegionName
    FROM       Sales.SalesPerson                  AS sp
    INNER JOIN #SalesTerritoryToCountryRegionName AS sttcrn
       ON      sttcrn.TerritoryID = sp.TerritoryID;

    -- And finally Address --> StateProvince --> SalesTerritory --> CountryRegion
    CREATE TABLE #AddressToCountryRegionName
        (AddressID         int          NOT NULL,
         CountryRegionName nvarchar(50) NOT NULL);

    INSERT INTO #AddressToCountryRegionName (AddressID,
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

    -- Find all the matching SalesOrderHeader rows first,
    -- so we get better estimates for the rest of the query.
    CREATE TABLE #SelectedSalesOrderHeaders
        (SalesOrderID int   NOT NULL PRIMARY KEY,
         SubTotal     money NOT NULL);

    INSERT INTO #SelectedSalesOrderHeaders (SalesOrderID,
                                            SubTotal)
    SELECT     soh.SalesOrderID,
               soh.SubTotal
    FROM       Sales.SalesOrderHeader          AS soh
    INNER JOIN #AddressToCountryRegionName     AS BillRegion
       ON      BillRegion.AddressID   = soh.BillToAddressID
    INNER JOIN #AddressToCountryRegionName     AS ShipRegion
       ON      ShipRegion.AddressID   = soh.ShipToAddressID
    INNER JOIN #SalesPersonToCountryRegionName AS SpRegion
       ON      SpRegion.SalesPersonID = soh.SalesPersonID
    WHERE      BillRegion.CountryRegionName = @BillRegion
    AND        ShipRegion.CountryRegionName        = @ShipRegion
    AND        SpRegion.CountryRegionName          = @SalespersonRegion;

    -- Now let's do the actual query
    SELECT     p.Color,
               COUNT (DISTINCT sod.ProductID)    AS NumProducts,
               COUNT (DISTINCT sod.SalesOrderID) AS NumOrders,
               SUM (sod.OrderQty)                AS TotalQty,
               SUM (ssoh.SubTotal)               AS TotalPrice
    FROM       #SelectedSalesOrderHeaders AS ssoh
    INNER JOIN Sales.SalesOrderDetail     AS sod
       ON      sod.SalesOrderID = ssoh.SalesOrderID
    INNER JOIN Production.Product         AS p
       ON      p.ProductID      = sod.ProductID
    GROUP BY   p.Color
    ORDER BY   TotalPrice DESC,
               TotalQty DESC;
END;
GO

-- Does this help?
EXEC dbo.SalesByRegions @BillRegion = N'United States',
                        @ShipRegion = N'United States',
                        @SalespersonRegion = N'United States';
GO

-- This fixes the high logical reads on SalesOrderDetail, and the spills. Well done!
-- We still have the 70K logical reads on the Table Spool.
-- This is a direct result of a user requirement - COUNT(DISTINCT ...) is always expensive.
-- At this point, if the IO is still excessive, I would check to see if the requirements are negotiable.

-- There still are many other issues with the stored procedure.
-- Some of the temporary tables "for performance" probably don't benefit performance at all.
-- It might be better to use CTEs instead.
-- If the temporary tables are kept, they should probably have a clustered index.
-- But our task was to reduce the IOs. We completed that as far as possible.
-- The remaining 70K cannot be reduced without changed requirements.
-- So our task is finished. I might put in a backlog item for future further optimization.
