/*============================================================================
  File:     Uneven distribution.sql

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

-- You can get AdventureWorks2012 here: http://msftdbprodsamples.codeplex.com/
-- Or, you can use this same script with AdventureWorks2008 or 2008R2 (same location)

USE AdventureWorksDW2012
go

IF OBJECTPROPERTY(object_id('FactInternetSales2'), 'IsUserTable') = 1
    DROP TABLE FactInternetSales2
go

SELECT * 
INTO FactInternetSales2
FROM FactInternetSales
go

sp_help FactInternetSales2
go

SELECT TOP 100 * FROM FactInternetSales
go

------------------------------------------------------------------------------
-- Setup a copy of the FactInternetSales table
-- Make the ShipDateKey nullable
-- Make a small number of them nullable (under 5%)
------------------------------------------------------------------------------

-- Create a nullable shipped date
ALTER TABLE FactInternetSales2
ALTER COLUMN ShipDateKey int NULL
go

-- Set a small number of rows (2,541 rows out of 61K is under 5%)
UPDATE FactInternetSales2
    SET ShipDateKey = NULL
WHERE SalesOrderNumber > 'SO72000'
    AND CONVERT(int, RIGHT(SalesOrderNumber, 5)) % 3 = 0
go --(2541 row(s) affected)

--select 60398/2541.0

--HEAP or CL, same problem with the correlation between columns
-- Start with a heap

--DROP INDEX FactInternetSales2.OrderDateInd 
--DROP INDEX FactInternetSales2.ShipDateInd 


CREATE INDEX OrderDateInd 
ON FactInternetSales2 (OrderDateKey)
go

CREATE INDEX ShipDateInd 
ON FactInternetSales2 (ShipDateKey)
go

-- You can get my version of sp_helpindex 
-- here: https://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/
EXEC sp_SQLskills_helpindex FactInternetSales2;
go

------------------------------------------------------------------------------
-- Look at what happens during optimization with uneven distribution
------------------------------------------------------------------------------
SET STATISTICS TIME ON
SET STATISTICS IO ON
GO

-- Find the oldest unshipped item with a table scan:
SELECT MIN(OrderDateKey)
FROM FactInternetSales2 WITH (INDEX (0))
WHERE ShipDateKey IS NULL
-- 1141 logical reads

-- Find the oldest unshipped item:
SELECT MIN(OrderDateKey)
FROM FactInternetSales2
WHERE ShipDateKey IS NULL
-- 52878 logical reads

-- Force the Shipped date index lookups
SELECT MIN(OrderDateKey)
FROM FactInternetSales2 
    WITH (INDEX(ShipDateInd))
WHERE ShipDateKey IS NULL
-- 2549 logical reads

--Total rows = 60398
--Total rows where shipped date is null = 2541
--select convert(decimal(10,2), 60398)/2541 = 23.7693821 --(they think they'll find one within ~24 rows)
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
    FROM FactInternetSales2 WITH (INDEX(0))
    WHERE ShipDateKey IS NULL
SELECT [Total Time: Table Scan] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go

DBCC DROPCLEANBUFFERS
go

-- No hints
DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales2
    WHERE ShipDateKey IS NULL
SELECT [Total Time: Lookup for NULL] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go -- 52563 logical reads

DBCC DROPCLEANBUFFERS
go

-- Force the shipped date
DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales2 WITH (INDEX(ShipDateInd))
    WHERE ShipDateKey IS NULL
SELECT [Total Time: All NULLs plus temp table] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go -- 2645 logical reads


------------------------------------------------------------------------------
-- Cold cache numbers and performance - with a clustered index
------------------------------------------------------------------------------

-- What about if the table is clustered?
CREATE UNIQUE CLUSTERED INDEX SONumberCL 
ON FactInternetSales2 
(SalesOrderNumber, SalesOrderLineNumber)
go

sp_recompile FactInternetSales2 
-- Let's look at the cold cache numbers
DBCC DROPCLEANBUFFERS
go

-- Table scan
DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales2 WITH (INDEX(0))
    WHERE ShipDateKey IS NULL
SELECT [Total Time: Table Scan] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go

DBCC DROPCLEANBUFFERS
go

-- No hints
DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales2
    WHERE ShipDateKey IS NULL
SELECT [Total Time: Lookup for NULL] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go -- 52563 logical reads

DBCC DROPCLEANBUFFERS
go

-- Force the shipped date
DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales2 WITH (INDEX(ShipDateInd))
    WHERE ShipDateKey IS NULL
SELECT [Total Time: All NULLs plus temp table] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go -- 2645 logical reads


------------------------------------------------------------------------------
-- What if we had a better index that correlated the columns
------------------------------------------------------------------------------

-- Finally, what if we had a better index that understands the correlation between the columns

-- recommended through the Missing Index DMVs (through showplan)
CREATE NONCLUSTERED INDEX ShipDateOrderDateInd
ON [dbo].[FactInternetSales2] ([ShipDateKey])
INCLUDE ([OrderDateKey])
GO

-- my recommendation is to add the order date to the key so that the order date is ordered
-- min is the first record on the first page
CREATE INDEX ShipDateOrderDateInd_SeekableForMin
ON FactInternetSales2 (ShipDateKey, OrderDateKey)
go

select * from sys.dm_db_index_physical_stats
(db_id(), object_id('FactInternetSales2'), null, null, 'detailed')

------------------------------------------
-- Execute everything in this section
-- to compare the costs
------------------------------------------

SET STATISTICS TIME ON
SET STATISTICS IO ON
go

DBCC DROPCLEANBUFFERS
go

DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales2 WITH (INDEX(0))
    WHERE ShipDateKey IS NULL
SELECT [Total Time: Table Scan] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go

DBCC DROPCLEANBUFFERS
go

DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales2 WITH (INDEX (OrderDateInd))
    WHERE ShipDateKey IS NULL
SELECT [Total Time: Lookup for NULL] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go -- 52563 logical reads

DBCC DROPCLEANBUFFERS
go

DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales2 WITH (INDEX(ShipDateInd))
    WHERE ShipDateKey IS NULL
SELECT [Total Time: All NULLs plus temp table] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go -- 2645 logical reads

DBCC DROPCLEANBUFFERS
go

DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales2 WITH (INDEX (ShipDateOrderDateInd))
    WHERE ShipDateKey IS NULL
SELECT [Total Time: Unordered (non-seekable)] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go

DBCC DROPCLEANBUFFERS
go

DECLARE @StartTime  datetime2
SELECT @StartTime = SYSDATETIME()
    SELECT MIN(OrderDateKey)
    FROM FactInternetSales2 --WITH (INDEX (ShipDateOrderDateInd_SeekableForMin)) 
    WHERE ShipDateKey IS NULL
SELECT [Total Time: Ordered (seekable)] = DATEDIFF(MS, @StartTime, SYSDATETIME())
go

DBCC DROPCLEANBUFFERS
go
SELECT GETDATE()
go

------------------------------------------
-- Need these last couple to get rid
-- of UI/grid/showplan overhead
------------------------------------------
