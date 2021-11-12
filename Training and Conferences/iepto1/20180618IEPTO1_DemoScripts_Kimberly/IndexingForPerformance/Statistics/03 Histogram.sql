/*============================================================================
  File:     Histogram.sql

  Summary:  What's in the histogram?
				And, where do we start to see more problems?
				Definitely: when there's skewed data distribution 
				Usually in larger tables/data sets
  
  SQL Server Version: SQL Server 2005+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- Here's the dropbox link to the backup of this database
https://www.dropbox.com/sh/wbvcjsdnbj7hcw6/AAB6LRvEyghxn9qZv0zDI0gPa?dl=0

USE [AdventureWorksDW2008_ModifiedSalesKey];
GO

-- Well look at I/O numbers later
SET STATISTICS IO ON;
GO

--------------------------------
-- Clean up
--------------------------------
EXEC [sp_helpstats] 'dbo.FactInternetSales', 'ALL';
GO

-- If you just restored AdventureWorks then these two indexes are prob in there...
--DROP INDEX factinternetsales.ShipDateOrderDateInd
--DROP INDEX factinternetsales.ShipDateOrderDateInd_SeekableForMin

--DROP INDEX factinternetsales.MissingIndexDMVsRec
--DROP INDEX factinternetsales.[IX_FactInternetSales_CustomerKey_INCSalesAmount]
--DROP INDEX factinternetsales.IX_FactInternetSales_CustomerKey_INCSalesAmount
--DROP STATISTICS factinternetsales.[SalesByCustomer_11142-11185]
--DROP STATISTICS factinternetsales.[SalesByCustomer_R11000-12000]

-- I shouldn't need to use this but if I've left some column-level
-- stats from prior executions/demos.
EXEC [sp_SQLskills_DropAllColumnStats]	
		'dbo', 'factinternetsales', 'customerkey', 'TRUE';
GO

-- Rewrite to give better index details/internals
-- Get here: http://www.sqlskills.com/blogs/kimberly/use-this-new-sql-server-2012-rewrite-for-sp_helpindex/ 


---------------------------------------------
-- Understanding the data (sales per customerkey)
---------------------------------------------

SELECT [s].[CustomerKey]
	, COUNT(*) AS [TotalSales (rows)]
FROM [dbo].[FactInternetSales] AS [s]
GROUP BY [s].[CustomerKey]
ORDER BY [TotalSales (rows)] DESC;
GO

-- What do the statistics say?
-- First, let's pick a few values from the histogram
DBCC SHOW_STATISTICS('dbo.FactInternetSales'
	, 'IX_FactInternetSales_CustomerKey')
WITH HISTOGRAM

-- Estimate: 3954.759
--   Actual: 2560
SELECT [s].[CustomerKey]
	, COUNT(*) AS [TotalSales (rows)]
FROM [dbo].[FactInternetSales] AS [s]
WHERE [s].[CustomerKey] = 11230
GROUP BY [s].[CustomerKey];
GO

-- And, what does the average say:
DBCC SHOW_STATISTICS('dbo.FactInternetSales'
	, 'IX_FactInternetSales_CustomerKey')

-- Take All density * rows = average rows returned

SELECT 5.410084E-05	-- All density: for lastname
	    * 30923776	-- Rows: from the header
--  = 1673.0023		-- On average, you will get back
					-- 1673 rows (sales) per customerkey

DBCC SHOW_STATISTICS('dbo.FactInternetSales'
	, 'IX_FactInternetSales_CustomerKey')
WITH STAT_HEADER JOIN DENSITY_VECTOR
-- Take table_cardinality/tuple_cardinality

SELECT 30923776.00	-- Table_cardinality (table rows)
	/18484			-- Tuple_cardinality (# of customers 
					--		that HAVE sales)
--  = 1673.0024		-- On average, you will get back
					-- 1673 rows (sales) per customerkey
go

---------------------------------------------
-- Highlighting skew (sales per customerkey)
---------------------------------------------

-- Let's drill into a specific step:
-- 11142 to 11185
DBCC SHOW_STATISTICS('dbo.FactInternetSales'
	, 'IX_FactInternetSales_CustomerKey')
WITH HISTOGRAM

-- RANGE_HI_KEY	RANGE_ROWS	EQ_ROWS	DISTINCT_RANGE_ROWS	AVG_RANGE_ROWS
-- 11142		--			18432	--					--
-- 11185		130560		34816	42					3108.572

-- How does this read:
-- CustomerKey 11142 has 18432 rows
-- CustomerKey 11185 has 34816 rows
-- For any CustomerKey between 11142 
--	and 11185 (but not including them)
--  there are 3108.57 rows on average
-- So, EVERY customer value between 11143 
--	and 11184 will get an estimate of 3108.57

-- Let's look at what the data REALLY looks like in this range
SELECT [s].[CustomerKey]
	, COUNT(*) AS [TotalSales (rows)]
FROM [dbo].[FactInternetSales] AS [s]
WHERE [s].[CustomerKey] > 11142 
	AND [s].[CustomerKey] < 11185
GROUP BY [s].[CustomerKey]
ORDER BY [TotalSales (rows)] DESC;
GO

-- And, let's confirm that the optimizer
-- estimates what we expect:
SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11152;
GO

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11176;
GO

---------------------------------------------
-- Filtered stats - for special cases?
---------------------------------------------

-- Let's say that someone thinks that this particular
-- part of the data is "skewed" and thinks that
-- we should create a filtered statistic:
-- DROP STATISTICS [dbo].[FactInternetSales].[SalesByCustomer_11142-11185]
CREATE STATISTICS [SalesByCustomer_11142-11185] 
	ON [dbo].[FactInternetSales] ([CustomerKey])
WHERE [CustomerKey] >= 11142 
	AND [CustomerKey] <= 11185;
	-- Default: will use sampling
GO

-- What are we going to estimate for 
-- 11152: 1 (interesting! and because of sampling)
-- 11176: 31492.98
DBCC SHOW_STATISTICS('dbo.FactInternetSales'
	, 'SalesByCustomer_11142-11185')
WITH HISTOGRAM

-- To guarantee a new plan 
--	(not even textual matching)
EXEC sp_recompile 'dbo.FactInternetSales';
GO

-- And, let's confirm that the optimizer
-- estimates what we expect:
SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11152;
GO

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11176;
GO

-- Do we get a better estimate with FULLSCAN?
DROP STATISTICS [dbo].[FactInternetSales].[SalesByCustomer_11142-11185];
GO

CREATE STATISTICS [SalesByCustomer_11142-11185] 
	ON [dbo].[FactInternetSales] ([CustomerKey])
WHERE [CustomerKey] >= 11142 
	AND [CustomerKey] <= 11185
	WITH FULLSCAN;
GO

-- Try again
EXEC sp_recompile 'dbo.FactInternetSales';
GO

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11152;
GO

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11176;
GO

-- SUCCESS!!!

-- OK/good - with sampling. 
-- The more skewed, the more potential there 
-- will be some issues (even with FS).

-- Best (but have to weigh scan costs)
-- Note: fullscan is only a seek into that 
-- particular data set (not a full table scan
-- for each FS).