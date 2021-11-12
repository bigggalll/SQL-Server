USE AdventureWorks2017;
GO

/*
Your users complain that the system is often slow.
A dashboard application that is critical for the business does not update fast enough.
Your DBA, or you, correlates periods with lots of complaints to high RESOURCE_SEMAPHORE waits.
More information: https://www.sqlskills.com/help/waits/resource_semaphore/.
High RESOURCE_SEMAPHORE means queries have to wait for available memory.
This means that there are many concurrent queries with a high Memory Grant.

Your senior DBA uses some tools (beyond scope of this session) to identify the root cause.
She identifies the PaginatedSalesReport procedure as a likely issue and asks you to fix it.
*/

EXEC dbo.PaginatedSalesReport;
GO

-- Check the text of the stored procedure. Don't y'all love it when coworkers use zero comments?

-- Run the stored procedure with execution plan plus run-time statistics.
-- We see a high Memory Grant indeed (for the sake of this demo, assume 49MB is high, okay?)
-- But what operator(s) is or are the root cause?

-- The execution plan's Memory Grant is based on estimated memory needed for each operator,
-- combined with the optimizer's understanding of which operators run concurrently
-- and which run after each other and can hence reuse the same memory.
-- Some of this is tracked in the form of the Memory Fractions properties.
-- Sadly, the raw "memory needed for this operator" is not itself exposed. :(

-- On newer versions, the execution plan plus does track actual memory used per operator.
-- For older versions, or execution plan only, estimated data input size is all we have.


-- The biggest issue is clearly having to sort over 100K rows.
-- This procedure runs thousands of times per day from a dashboard that always asks page 1.
-- It is only rarely used to return data from later pages.
-- The Sort operator has a special operation, Top N Sort, that uses less memory when N < 100.
-- So perhaps we should set up a special code path for the "common" case of @PageNum = 1?

ALTER PROCEDURE dbo.PaginatedSalesReport @PageNum int = 1
AS
BEGIN;
    IF @PageNum = 1
    BEGIN;
        -- Optimized code path to return the first 20 rows with much lower memory grant
        -- Note that this query is used twice in the procedure now,
        -- make sure to change BOTH in case of future maintenance!!!
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
        SELECT     TOP (20) p.ProductNumber,
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
    END;
    ELSE
    BEGIN;
        -- Default code path to return any page, with higher memory usage
        -- Note that this query is used twice in the procedure now,
        -- make sure to change BOTH in case of future maintenance!!!
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
END;
GO

-- Does this help?
EXEC dbo.PaginatedSalesReport;
GO

-- The memory grant is lower, but still 26MB.
-- The optimizer decided that it's cheaper to sort the full set, then do lookups for only 20 rows
-- than it is to do lookups for the full set and then do a Top N Sort.

-- The lookups IN THIS CASE always produce exactly one hit.
-- So we can try to put the TOP (20) in the CTE already.

ALTER PROCEDURE dbo.PaginatedSalesReport @PageNum int = 1
AS
BEGIN;
    IF @PageNum = 1
    BEGIN;
        -- Optimized code path to return the first 20 rows with much lower memory grant
        -- Note that this query is used twice in the procedure now,
        -- make sure to change BOTH in case of future maintenance!!!
        WITH AggregatedSalesData
          AS (SELECT     TOP (20) sod.ProductID,
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
                         soh.CustomerID
              ORDER BY   TotalOrderQty DESC)
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
           ON      p2.BusinessEntityID = c.PersonID;
    END;
    ELSE
    BEGIN;
        -- Default code path to return any page, with higher memory usage
        -- Note that this query is used twice in the procedure now,
        -- make sure to change BOTH in case of future maintenance!!!
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
END;
GO

-- Does this help?
EXEC dbo.PaginatedSalesReport;
GO

-- We're down from 49MB to 14MB. That's needed for the aggregation in the CTE.
-- If this still is too much, then we'll have to ask for more memory in the server;
-- the user requirement simply cannot be fulfilled without this aggregation.

-- Okay, if pressed hard enough there are ways. There (almost) always are.
-- Most of the time they are not free. You win some here, you lose some elsewhere.
-- But that's beyond the scope of today's session.

-- Note that once more I didn't even look at optimizing the @PageNum > 1 option.
-- I had a problem to solve, I solved it.
-- That does not mean the code is now perfect. It just means I fixed the problem.
