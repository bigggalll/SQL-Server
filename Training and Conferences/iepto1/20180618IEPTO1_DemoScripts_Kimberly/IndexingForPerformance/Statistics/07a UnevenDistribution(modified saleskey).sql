/*============================================================================
  File:     Uneven distribution (AdventureWorksDW2008_ModifiedSalesKey).sql

  Summary:  Skewed distribution across multiple columns - what happens?

  SQL Server Version: 2008+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp & Paul S. Randal, SQLskills.com

  For more scripts and sample code, check out http://www.SQLskills.com

  This script is intended as a supplement to the SQL Server 2008 Jumpstart or
  Metro training.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- Here's the dropbox link to the backup of this database
https://www.dropbox.com/sh/wbvcjsdnbj7hcw6/AAB6LRvEyghxn9qZv0zDI0gPa?dl=0

USE AdventureWorksDW2008_ModifiedSalesKey
go

-- Clean up?
DROP INDEX [FactInternetSales].ShipDateOrderDateInd
DROP INDEX [FactInternetSales].ShipDateOrderDateInd_SeekableForMin
DROP STATISTICS factinternetsales.[SalesByCustomer_R11000-12000]
DROP STATISTICS factinternetsales.[SalesByCustomer_11142-11185]
GO

EXEC [sp_SQLskills_DropAllColumnStats]	
		'dbo', 'factinternetsales', 'customerkey', 'TRUE';
GO

sp_helpindex FactInternetSales
exec sp_helpstats FactInternetSales, 'all'
go

DBCC SHOW_STATISTICS(factinternetsales, IX_FactInternetSales_OrderDateKey)
DBCC SHOW_STATISTICS(factinternetsales, IX_FactIneternetSales_ShipDateKey)

-- nulls?
select 146887.00/30923776
select 30923776.00/146887

SELECT TOP 100 * FROM FactInternetSales
ORDER BY OrderDateKey DESC
go

-- You can get my version of sp_helpindex 
-- here: https://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/
EXEC sp_SQLskills_helpindex FactInternetSales;
go

------------------------------------------------------------------------------
-- Look at what happens during optimization with uneven distribution
------------------------------------------------------------------------------

SET STATISTICS IO ON
SET STATISTICS TIME ON
GO

-- Find the oldest unshipped item with a table scan:
SELECT MIN(OrderDateKey)
FROM FactInternetSales WITH (INDEX (0))
WHERE ShipDateKey IS NULL
-- 480,723 logical reads

-- Find the oldest unshipped item:
SELECT MIN(OrderDateKey)
FROM FactInternetSales
WHERE ShipDateKey IS NULL
-- 123,882,667 logical reads

-- Force the Shipped date index lookups
SELECT MIN(OrderDateKey)
FROM FactInternetSales 
	WITH (INDEX([IX_FactIneternetSales_ShipDateKey]))
WHERE ShipDateKey IS NULL
-- 597,102 logical reads plus a worktable


------------------------------------------------------------------------------
-- Where did this estimate come from?
------------------------------------------------------------------------------
-- select COUNT(*) FROM FactInternetSales
-- Total rows = 30,923,776

 --SELECT COUNT(*) FROM FactInternetSales
 --WHERE ShipDateKey IS NULL
--Total rows where shipped date is null = 146,887

-- SELECT 30923776/146887 = 210 --(they think they'll find one within ~210 rows)
-- However, they're horribly wrong as the unshipped items are all at the end of the table. Instead of finding the row
-- within only 24 (one in 24 is NULL) they don't encounter a NULL until the end.


------------------------------------------------------------------------------
-- Cold cache numbers and performance
------------------------------------------------------------------------------

-- Let's look at the cold cache numbers
DBCC DROPCLEANBUFFERS
go

-- Table scan
DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales WITH (INDEX(0))
    WHERE ShipDateKey IS NULL
SELECT [Total Time: Table Scan] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go -- time on KLTripp laptop: 8664 (~9 seconds)

DBCC DROPCLEANBUFFERS
go

-- No hints
DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales
    WHERE ShipDateKey IS NULL
SELECT [Total Time: Lookup for NULL] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go -- time on KLTripp laptop: 85653 (1 min, 26 seconds)

DBCC DROPCLEANBUFFERS
go

-- Force the shipped date
DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales WITH (INDEX([IX_FactIneternetSales_ShipDateKey]))
    WHERE ShipDateKey IS NULL
SELECT [Total Time: All NULLs plus temp table] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go -- time on KLTripp laptop: 172 (< .5 second)


------------------------------------------------------------------------------
-- What if we had a better index that correlated the columns
------------------------------------------------------------------------------

-- Finally, what if we had a better index that understands the 
-- correlation between the columns?

-- recommended through the Missing Index DMVs (through showplan)
CREATE NONCLUSTERED INDEX ShipDateOrderDateInd
ON [dbo].[FactInternetSales] ([ShipDateKey])
INCLUDE ([OrderDateKey])
GO

-- my recommendation is to add the order date to the key so that the order date is ordered
-- min is the first record on the first page
CREATE INDEX ShipDateOrderDateInd_SeekableForMin
ON FactInternetSales (ShipDateKey, OrderDateKey)
go

------------------------------------------
-- Execute everything in this section
-- to compare the costs
------------------------------------------

SET STATISTICS TIME ON
go

DBCC DROPCLEANBUFFERS
go

DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales WITH (INDEX(0))
    WHERE ShipDateKey IS NULL
SELECT [Total Time: Table Scan] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go  -- time on KLTripp laptop: 23709 (24 seconds)
    -- 477,808 logical IOs

DBCC DROPCLEANBUFFERS
go

DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales WITH (INDEX ([IX_FactInternetSales_OrderDateKey]))
    WHERE ShipDateKey IS NULL
SELECT [Total Time: Lookup for NULL] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go  -- time on KLTripp laptop: 119399 (1 minute, 59 seconds)
    -- 123,931,830 logical IOs
    
DBCC DROPCLEANBUFFERS
go

DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales WITH (INDEX([IX_FactIneternetSales_ShipDateKey]))
    WHERE ShipDateKey IS NULL
SELECT [Total Time: All NULLs plus temp table] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go  -- time on KLTripp laptop: 1208 (1 second)
    -- 639,507 logical IOs plus a worktable


DBCC DROPCLEANBUFFERS
go

DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales WITH (INDEX (ShipDateOrderDateInd))
    WHERE ShipDateKey IS NULL
SELECT [Total Time: Unordered (non-seekable)] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go  -- time on KLTripp laptop: 36 ms
    -- 348 logical IOs 

DBCC DROPCLEANBUFFERS
go

DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales --WITH (INDEX (ShipDateOrderDateInd_SeekableForMin)) 
    WHERE ShipDateKey IS NULL
SELECT [Total Time: Ordered (seekable)] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go  -- time on KLTripp laptop: 20 ms
    -- 3 logical IOs 

DBCC DROPCLEANBUFFERS
go
SELECT GETDATE()
go

------------------------------------------
-- Need these last couple to get rid
-- of UI/grid/showplan overhead
------------------------------------------

-- Cleanup
USE [AdventureWorksDW2008_ModifiedSalesKey];
GO

DROP INDEX FactInternetSales.ShipDateOrderDateInd
DROP INDEX FactInternetSales.ShipDateOrderDateInd_SeekableForMin
--DROP STATISTICS factinternetsales.[SalesByCustomer_R11000-12000]
EXEC [sp_SQLskills_DropAllColumnStats]
		  @schemaname		= N'dbo'
		, @objectname		= N'factinternetsales'
		, @columnname		= N'customerkey'
		, @dropall			= N'TRUE';
GO

------------------------------------------
-- Should we create the index?
-- But, how long does it take to create (and test)

-- What about autopilot?

-- Check out this great article on Simple Talk
-- "Hypothetical Indexes on SQL Server"
-- https://www.simple-talk.com/sql/database-administration/hypothetical-indexes-on-sql-server/
------------------------------------------

CREATE NONCLUSTERED INDEX [TestIndex1]
ON [dbo].[FactInternetSales] 
	([ShipDateKey])
INCLUDE 
	([OrderDateKey])
WITH STATISTICS_ONLY = -1 
GO

CREATE NONCLUSTERED INDEX [TestIndex2]
ON [dbo].[FactInternetSales]
	 ([ShipDateKey], [OrderDateKey])
WITH STATISTICS_ONLY = -1 
go

EXEC [sp_SQLskills_helpindex] 'dbo.factinternetsales'
go

SELECT db_id(), object_id('factinternetsales')
GO

DBCC AUTOPILOT(0, 5,2053582354, 2);
DBCC AUTOPILOT(0, 5,2053582354, 3);
GO

SET AUTOPILOT ON;
GO

SELECT MIN([fis].[OrderDateKey])
FROM [dbo].[FactInternetSales] AS [fis]
WHERE [fis].[ShipDateKey] IS NULL;
GO

SET AUTOPILOT OFF;
GO