/*============================================================================
  File:     IndexedViews.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  This script shows an example of indexed views
            as described in Chapter 6 of SQL Server 2008 Internals.
  
  Date:     April 2009
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE AdventureWorks2008;
go

-- First, check to see if the object is indexable:
SELECT OBJECTPROPERTY (OBJECT_ID ('Sales.SalesOrderDetail'), 'IsIndexable');
go

-- Create a view - with SCHEMABINDING:
CREATE VIEW Vdiscount1 
    WITH SCHEMABINDING
AS 
SELECT SUM (UnitPrice*OrderQty) AS SumPrice
    , SUM (UnitPrice * OrderQty * (1.00 - UnitPriceDiscount)) AS SumDiscountPrice
    , COUNT_BIG (*) AS Count
    , ProductID
FROM Sales.SalesOrderDetail
GROUP BY ProductID;
go

-- Verify that no data exists for this Indexed View:
SELECT si.name AS index_name
    , ps.used_page_count
    , ps.reserved_page_count
    , ps.row_count
FROM sys.dm_db_partition_stats AS ps
    JOIN sys.indexes AS si
        ON ps.[object_id] = si.[object_id]
WHERE ps.[object_id] = OBJECT_ID ('dbo.Vdiscount1');
go

-- Create a UNIQUE CLUSTERED index on the view to materialize 
-- the data:
CREATE UNIQUE CLUSTERED INDEX VDiscount_Idx 
ON Vdiscount1 (ProductID);
go

-- Check to see if there's data that exists now:
SELECT si.name AS index_name
    , ps.used_page_count
    , ps.reserved_page_count
    , ps.row_count
FROM sys.dm_db_partition_stats AS ps
    JOIN sys.indexes AS si
        ON ps.[object_id] = si.[object_id]
WHERE ps.[object_id] = OBJECT_ID ('dbo.Vdiscount1');
go

-- To verify whether or not a view has an index:
SELECT OBJECTPROPERTY (OBJECT_ID ('Vdiscount1'), 'IsIndexed');
go

-- Compare/contrast the plans of using the base table (with a table-scan)
-- vs. leveraging the pre-computed values of the indexed view
-- Be sure to turn on showplan (Query menu, Include Actual Execution Plan):
SET STATISTICS IO ON;
go

SELECT ProductID
    , total_sales = SUM (UnitPrice * OrderQty)
FROM Sales.SalesOrderDetail WITH (INDEX (0))
GROUP BY ProductID;
--Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--Table 'SalesOrderDetail'. Scan count 1, logical reads 1240, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

SELECT ProductID
    , total_sales = SUM (UnitPrice * OrderQty)
FROM Sales.SalesOrderDetail
GROUP BY ProductID;
--Table 'Vdiscount1'. Scan count 1, logical reads 4, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
