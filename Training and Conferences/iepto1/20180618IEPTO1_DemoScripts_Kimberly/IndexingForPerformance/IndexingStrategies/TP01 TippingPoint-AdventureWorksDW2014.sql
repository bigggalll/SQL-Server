/*============================================================================
  File:     The Tipping Point.sql

  Summary:  Various examples and ways to see the estimated and actual tipping
			point of when a nonclustered index is not used vs. doing a table
			scan.
  
  SQL Server Version: 2005+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- You can get AdventureWorksDW2014 here: http://msftdbprodsamples.codeplex.com/
-- Or, you can use this same script with AdventureWorksDW2008 or 2008R2 (same location)
-- Be sure to do the math based on the output of the version you're working with
-- this script has the numbers/math for [AdventureWorksDW2014]. But, I had to manually
-- add the 7 indexes that prior AdventureWorksDW DBs had... 

USE [AdventureWorksDW2012];
GO

EXEC [sp_helpindex] 'dbo.FactInternetSales';
GO

-- Get my version of sp_helpindex here: http://www.sqlskills.com/blogs/kimberly/use-this-sp_helpindex-rewrites/  
EXEC [sp_SQLskills_helpindex] 'dbo.FactInternetSales';
GO

-- For 2000
-- DBCC SHOWCONTIG .. WITH TABLERESULTS

SELECT [ps].* 
FROM [sys].[dm_db_index_physical_stats]
	(db_id(), object_id('dbo.FactInternetSales'), 
	    1, NULL, 'DETAILED') AS [ps] -- for a big table limited or sampled

-- For DW2008/2008R2 the table has 1024 pages
-- For DW2012 the table has 1238... 
-- For DW2014 the table has 1236... 
-- do the math for the right output!

-- Clustered Index has 1236 PAGES (Level 0 in CL)
-- select 1237/4 = ~309
------------
-- select 1237/3 = ~412

SELECT [s].[CustomerKey]
    , COUNT(*) AS [NumTotalSales]
FROM [dbo].[FactInternetSales] AS [s]
GROUP BY [s].[CustomerKey]
ORDER BY [s].[CustomerKey];
GO

-- Compat mode doesn't affect the tipping point
-- so, it doesn't actually matter...
-- (NOTE: it might be "off by one" though)

-- Are you on SQL 2014?
ALTER DATABASE AdventureWorksDW2012
SET COMPATIBILITY_LEVEL = 120
go

-- Turn on showplan (Ctrl+M)
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

DBCC DROPCLEANBUFFERS;
GO

SELECT [c].[CustomerKey]
    , [c].[LastName]
    , sum([s].[SalesAmount])
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] < 11058
GROUP BY [c].[CustomerKey], [c].[LastName]
OPTION (MAXDOP 1);
GO

DBCC DROPCLEANBUFFERS;
GO

SELECT [c].[CustomerKey], [c].[LastName], sum([s].[SalesAmount])
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] < 11059
GROUP BY [c].[CustomerKey], [c].[LastName]
OPTION (MAXDOP 1);
GO

-- Is this still the same in a bigger database on a beefy machine?
-- the concept is the same but the tipping point might be higher

-- Please note this next part is based on a modified version of 
-- AdventureWorksDW2008_ModifiedSalesKey
-- Updated/backed up June 2012

USE [AdventureWorksDW2008_ModifiedSalesKey];
GO

-- Here's the dropbox link to the backup of this database
https://www.dropbox.com/sh/wbvcjsdnbj7hcw6/AAB6LRvEyghxn9qZv0zDI0gPa?dl=0

ALTER DATABASE AdventureWorksDW2008_ModifiedSalesKey
SET COMPATIBILITY_LEVEL = 120;
GO

SELECT [ps].* 
FROM [sys].[dm_db_index_physical_stats] 
	(db_id(), object_id('dbo.FactInternetSales'), 
	    1, NULL, 'DETAILED') AS [ps] -- for a big table limited or sampled
-- 475754 pages
-- select 475754/4  --118938 (is 1/4 of the pages)
-- select 475754/3  --158584 (is 1/3 of the pages)

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

DBCC DROPCLEANBUFFERS;
GO

SELECT [c].[CustomerKey], [c].[LastName], sum([s].[SalesAmount])
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] < 11043 
GROUP BY [c].[CustomerKey], [c].[LastName]
OPTION (MAXDOP 1);
GO

DBCC DROPCLEANBUFFERS;
GO

SELECT [c].[CustomerKey], [c].[LastName], sum([s].[SalesAmount])
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] < 11044 
GROUP BY [c].[CustomerKey], [c].[LastName]
OPTION (MAXDOP 1);
GO

DBCC DROPCLEANBUFFERS;
GO

SELECT [c].[CustomerKey], [c].[LastName], sum([s].[SalesAmount])
FROM [dbo].[FactInternetSales] AS [s] WITH (FORCESEEK)
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] < 11044
GROUP BY [c].[CustomerKey], [c].[LastName]
OPTION (MAXDOP 1);
GO

DBCC DROPCLEANBUFFERS;
GO

SELECT [c].[CustomerKey], [c].[LastName], sum([s].[SalesAmount])
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] < 15000
GROUP BY [c].[CustomerKey], [c].[LastName]
OPTION (MAXDOP 1);
GO

DBCC DROPCLEANBUFFERS;
GO

SELECT [c].[CustomerKey], [c].[LastName], sum([s].[SalesAmount])
FROM [dbo].[FactInternetSales] AS [s] WITH (FORCESEEK)
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] < 15000
GROUP BY [c].[CustomerKey], [c].[LastName]
OPTION (MAXDOP 1);
GO

-- What if we let SQL Server use multiple processors/cores

DBCC DROPCLEANBUFFERS;
GO

SELECT [c].[CustomerKey], [c].[LastName], sum([s].[SalesAmount])
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] < 11038 -- vs. 11043 without parallelism (note: this might be different on YOUR machine)
GROUP BY [c].[CustomerKey], [c].[LastName];
GO

DBCC DROPCLEANBUFFERS;
GO

SELECT [c].[CustomerKey], [c].[LastName], sum([s].[SalesAmount])
FROM [dbo].[FactInternetSales] AS [s] --WITH (FORCESEEK)
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] < 11039 -- vs. 11044
GROUP BY [c].[CustomerKey], [c].[LastName];
GO

-- If this query were critical... 
-- I'd first look at the missing index suggestion 
--   (the "green" suggestion in showplan)

--CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
--ON [dbo].[FactInternetSales] ([CustomerKey])
--INCLUDE ([SalesAmount])

-- But... before you create it make sure to FIRST check existing indexes:
-- You can grab sp_SQLskills_helpindex here: 

EXEC [sp_SQLskills_helpindex] 'dbo.FactInternetSales';
GO

--1) Create the new index

CREATE NONCLUSTERED INDEX [IX_FactInternetSales_CustomerKey_INCSalesAmount]
ON [dbo].[FactInternetSales] ([CustomerKey])
INCLUDE ([SalesAmount]);
GO

--2) Drop the old???
--   we should always check our indexes first to see if any can be dropped/consolidated 
--   based on the new index being created!

DROP INDEX [FactInternetSales].[IX_FactInternetSales_CustomerKey];
GO

-- May need to drop the old before creating the new 
-- (if space is an issue)
-- but this may negatively affect existing users?!

-- Now, no matter what the range and/or number of rows, this index can always be used:
SELECT [c].[CustomerKey], [c].[LastName], sum([s].[SalesAmount])
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] < 11038
GROUP BY [c].[CustomerKey], [c].[LastName];
GO

SELECT [c].[CustomerKey], [c].[LastName], sum([s].[SalesAmount])
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] < 11039
GROUP BY [c].[CustomerKey], [c].[LastName];
GO

-- What about an even bigger range:
SELECT [c].[CustomerKey], [c].[LastName], sum([s].[SalesAmount])
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] > 11049
GROUP BY [c].[CustomerKey], [c].[LastName];
GO

SELECT [c].[CustomerKey], [c].[LastName], sum([s].[SalesAmount])
FROM [dbo].[FactInternetSales] AS [s] WITH (FORCESEEK)
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] > 11049
GROUP BY [c].[CustomerKey], [c].[LastName];
GO

------------------------------------------------------------------
-- Clean up and prep for next execution:
------------------------------------------------------------------
USE [AdventureWorksDW2008_ModifiedSalesKey];
GO

CREATE NONCLUSTERED INDEX [IX_FactInternetSales_CustomerKey]
ON [dbo].[FactInternetSales] ([CustomerKey]);
GO

DROP INDEX [FactInternetSales].[IX_FactInternetSales_CustomerKey_INCSalesAmount];
GO
