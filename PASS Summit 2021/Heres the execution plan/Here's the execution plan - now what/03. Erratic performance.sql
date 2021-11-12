USE AdventureWorks2017;
GO

/*
A search function in the user interface has erratic performance.
You ask which specific search request is slow, but the users say that all of them are sometime slow, sometimes fast.
Looking at the Query Store data, you can confirm that this query does indeed have huge performance changes.
You also see that there are multiple execution plans for the same query, and all of them have irregular performance.
(HINT: When presenting the session you can find the query in Top Resource Consumers)
*/

-- This is the stored procedure that contains the problem query.
-- Let SQLPrompt supply the parameters and execute with execution plan plus enabled.
EXEC dbo.FindOrders;

-- That's weird. We don't see the problem plan at all!
-- Check the source of the stored procedure.
-- AHA! The problem query is skipped when @SalesOrderID is not NULL.
-- Let's instead ask the users to give us a typical sample usage.
EXEC dbo.FindOrders @ProductID = 709, @ShipMonth = '201202';

-- Caching execution plans is a good thing. It reduces CPU overhead for repeated optimizations.
-- Sniffing parameters is also a good thing. It often results in better, more optimized plans.
-- But in SOME cases, the two interact in a bad way --> bad parameter sniffing.
-- Typical cases:
-- * Procedures with a larger than / less than --> might benefit hugely, OR suffer hugely!
-- * Procedures with search on column(s) with very skewed distribution
-- * Procedures with optional parameters used in filters

-- If (as we suspect) bad parameter sniffing is the root cause, then a new plan would be better.
-- First check total I/O (better measurement on this small sample databases) before recompile
SET STATISTICS IO ON;
EXEC dbo.FindOrders @ProductID = 709, @ShipMonth = '201202';
-- Fetch the plan handle fir this query, then paste it below to remove it from the plan cache.
SELECT      plan_handle,
            st.text
FROM        sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text (plan_handle) AS st
WHERE       st.text LIKE N'%INSERT INTO @SalesOrders (SalesOrderID)%';
DBCC FREEPROCCACHE (0x05000500DB792E5B402A03E7B501000001000000000000000000000000000000000000000000000000000000);
-- Do we get better performance now?
EXEC dbo.FindOrders @ProductID = 709, @ShipMonth = '201202';
-- But now this plan will be reused in other cases and hurt performance
EXEC dbo.FindOrders @CustomerLastName = 'Adams';

-- Full coverage of bad parameter sniffing is beyond the scope of this session.
-- Typically recommended fixes include (but are not limited to)
-- 1. Add OPTION (RECOMPILE) to the query.
--    Guarantees always best possible plan, at the price of much more CPU usage for compilations.
--    Let's assume that is not acceptable in this case.
-- 2. Use OPTION (OPTIMIZE FOR UNKNOWN) or OPTION (OPTIMIZE FOR (@Parm = xxx, ...))
--    Guarantees always the same plan.
--    Good solution if there is a single plan that is good enough for all important cases.
--    Often good for skewed filtes, but not for optional filters.
-- 3. Use separate stored procedures for all (or relevant) distinct cases.
--    May help for both skewed distribution (separate proc for outlier values) and optional filters.
--    Becomes unmanageable when number of cases is too high
-- 4. Use dynamic SQL to build a query on the fly.
--    IMPORTANT: Use sp_executesql, not EXEC (@sql). And no user input anywhere in the query string!
--    Won't help with skewed data, but can be perfect solution for optional filters.

-- In our case, @SalesOrderID is a very different scenario, so we choose a combination
-- of option 3 (for @SalesOrderID null or not null) and option 4 (for the other 6 parameters).

-- First: Special case procedure for SalesOrderID is not null
DROP PROCEDURE IF EXISTS dbo.FindOrdersBySalesOrderID;
GO

CREATE PROCEDURE dbo.FindOrdersBySalesOrderID @SalesOrderID int
AS
BEGIN;
    -- We have the SalesOrderID value in @SalesOrderID
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
    WHERE      soh.SalesOrderID = @SalesOrderID;
END;
GO

-- Second: Dynamic SQL version for when SalesOrderID is not null
DROP PROCEDURE IF EXISTS dbo.FindOrdersByDynamicSearch;
GO

CREATE PROCEDURE dbo.FindOrdersByDynamicSearch
    @OrderMonth       char(6)      = NULL, -- Format YYYYMM
    @ShipMonth        char(6)      = NULL, -- Format YYYYMM
    @CustomerID       int          = NULL,
    @SalesPersonID    int          = NULL,
    @ProductID        int          = NULL,
    @CustomerLastName nvarchar(50) = NULL
AS
BEGIN;
    -- First find all orders based on the supplied search parameters.
    CREATE TABLE #SalesOrders -- Has to be temporary table - dynamic SQL restriction
        (SalesOrderID int NOT NULL PRIMARY KEY);

    DECLARE @Query nvarchar(MAX);
    SET @Query = N'INSERT INTO #SalesOrders (SalesOrderID)
SELECT     soh.SalesOrderID
FROM       Sales.SalesOrderHeader AS soh
INNER JOIN Sales.Customer         AS c
    ON     c.CustomerID            = soh.CustomerID
INNER JOIN Person.Person          AS p
    ON     p.BusinessEntityID      = c.PersonID
WHERE      1 = 1'; -- The "1 = 1" makes the rest easier

    IF @OrderMonth IS NOT NULL
    BEGIN;
        SET @Query += N' AND FORMAT (soh.OrderDate, ''yyyyMM'') = @OrderMonth';
    END;

    IF @ShipMonth IS NOT NULL
    BEGIN;
        SET @Query += N' AND FORMAT (soh.ShipDate, ''yyyyMM'') = @ShipMonth';
    END;

    IF @CustomerID IS NOT NULL
    BEGIN;
        SET @Query += N' AND soh.CustomerID = @CustomerID';
    END;

    IF @SalesPersonID IS NOT NULL
    BEGIN;
        SET @Query += N' AND soh.SalesPersonID = @SalesPersonID';
    END;

    IF @ProductID IS NOT NULL
    BEGIN;
        SET @Query += N' AND EXISTS
        (SELECT *
         FROM   Sales.SalesOrderDetail AS sod
         WHERE  sod.SalesOrderID = soh.SalesOrderID
         AND    sod.ProductID    = @ProductID)';
    END;

    IF @CustomerLastName IS NOT NULL
    BEGIN;
        SET @Query += N' AND p.LastName = @CustomerLastName';
    END;

    -- Query string is complete, now execute it.
    -- We can supply all parameters, whether used or not
    EXEC sys.sp_executesql @Query,
                           N'@OrderMonth       char(6),
						     @ShipMonth        char(6),
							 @CustomerID       int,
							 @SalesPersonID    int,
							 @ProductID        int,
							 @CustomerLastName nvarchar(50)',
                           @OrderMonth,
                           @ShipMonth,
                           @CustomerID,
                           @SalesPersonID,
                           @ProductID,
                           @CustomerLastName;

    -- We now have the SalesOrderID values in the table
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
    WHERE      soh.SalesOrderID IN
                   (SELECT so.SalesOrderID FROM #SalesOrders AS so);
END;
GO


-- Last step: Replace the original stored procedure with one that calls one of the two special cases
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
    IF @SalesOrderID IS NULL
    BEGIN;
        EXEC dbo.FindOrdersByDynamicSearch @OrderMonth = @OrderMonth,
                                           @ShipMonth = @ShipMonth,
                                           @CustomerID = @CustomerID,
                                           @SalesPersonID = @SalesPersonID,
                                           @ProductID = @ProductID,
                                           @CustomerLastName = @CustomerLastName;
    END;
    ELSE
    BEGIN;
        EXEC dbo.FindOrdersBySalesOrderID @SalesOrderID = @SalesOrderID;
    END;
END;
GO

-- Run a few test cases and check execution plans.
EXEC dbo.FindOrders @SalesOrderID = 43729;
EXEC dbo.FindOrders @OrderMonth = '201311', @ShipMonth = '201312';
EXEC dbo.FindOrders @CustomerID = 28645;
EXEC dbo.FindOrders @SalesPersonID = 281, @CustomerLastName = 'Adams';
EXEC dbo.FindOrders @ProductID = 709, @ShipMonth = '201202';

-- Check that plans do get reused when the same set of parameters is given (but different values)
-- This means you are still vulnerable to skewed distribution!
EXEC dbo.FindOrders @SalesPersonID = 279, @CustomerLastName = 'Meyer';

-- As in the previous examples, I have not tried to fix all issues.
-- A big one is the way the YYYYMM filter on @OrderMonth and @ShipMonth is done;
-- it would be better to convert the parameter to a begin and end value for a range.
-- Also, the query to search salesorders and the query to report them do a lot of double work.
-- Is the intermediate step of a temporary table even needed?

-- But we did fix the immediate issue.
-- No more erratic behaviour. No more extreme unpredictable slowness. Good enough speed, always.
-- And without burdening the system with excessive CPU due to constant recompilation.
