/*============================================================================
  File:     FilteredStatistics.sql

  Summary:  Now that we know we have skew - how can automate the
			creation of filtered statistics?
  
  SQL Server Version: SQL Server 2008-2014
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

---------------------------------------------
-- Setup (for filtered stats)
---------------------------------------------

-- Be sure to execute ALL of these scripts:
--  * sp_SQLskills_CreateFilteredStatsString.sql
--  * sp_SQLskills_DropAllColumnStats.sql
--	* sp_SQLskills_CreateFilteredStats.sql


---------------------------------------------
-- Quick check on stats and indexes
---------------------------------------------

-- Here's the dropbox link to the backup of this database
https://www.dropbox.com/sh/wbvcjsdnbj7hcw6/AAB6LRvEyghxn9qZv0zDI0gPa?dl=0

USE [AdventureWorksDW2008_ModifiedSalesKey];
GO

-- You can get my version of sp_helpindex 
-- here: https://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/
EXEC [sp_SQLskills_helpindex] 'dbo.factinternetsales';
EXEC [sp_helpstats] 'dbo.FactInternetSales', 'ALL';
GO

--DROP STATISTICS factinternetsales.[SalesByCustomer_11142-11185]


/************************************************************
-- Procedure:[sp_SQLskills_CreateFilteredStats]

-- PARAMETER NOTES:
--
--  @filteredstats	Number of steps to create.
--					You must have at least this number of steps
--					in your histogram.

--	@fullscan		Generate the filtered stat with a fullscan
--					or sample.
--					
--	@samplepercent	This can be null even when fullscan is 
--					SAMPLE. SQL Server will just use the internal
--					calculation for sample size.

************************************************************/

EXEC [dbo].[sp_SQLskills_CreateFilteredStats]
		  @schemaname		= N'dbo'
		, @objectname		= N'factinternetsales'
		, @columnname		= N'customerkey'
		, @filteredstats	= 10
		, @fullscan			= 'FULLSCAN';
GO

EXEC [sp_SQLskills_helpindex] 'dbo.factinternetsales';
EXEC [sp_helpstats] 'dbo.FactInternetSales', 'ALL';
GO

-- check a few queries
EXEC sp_recompile 'dbo.FactInternetSales';
GO

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11152
--OPTION (QUERYTRACEON 3604, QUERYTRACEON 9204, RECOMPILE)
--OPTION (QUERYTRACEON 9481, QUERYTRACEON 3604, QUERYTRACEON 9204, RECOMPILE);
GO

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11176
--OPTION (QUERYTRACEON 9481, QUERYTRACEON 3604, QUERYTRACEON 9204);
GO

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11693
OPTION (QUERYTRACEON 9481, QUERYTRACEON 3604, QUERYTRACEON 9204);
GO

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11711
OPTION (QUERYTRACEON 9481, QUERYTRACEON 3604, QUERYTRACEON 9204);
GO

---------------------------------------------
-- Maybe that's not enough stats?
---------------------------------------------

EXEC [dbo].[sp_SQLskills_CreateFilteredStats]
		  @schemaname		= N'dbo'
		, @objectname		= N'factinternetsales'
		, @columnname		= N'customerkey'
		, @filteredstats	= 20
		, @fullscan			= 'FULLSCAN';
GO

EXEC [sp_SQLskills_helpindex] 'dbo.factinternetsales';
EXEC [sp_helpstats] 'dbo.FactInternetSales', 'ALL';
GO

-- Retry all of the queries
EXEC sp_recompile 'dbo.FactInternetSales';
GO

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11152
OPTION (QUERYTRACEON 9481, QUERYTRACEON 3604, QUERYTRACEON 9204);
GO

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11176
OPTION (QUERYTRACEON 9481, QUERYTRACEON 3604, QUERYTRACEON 9204);
GO

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11693
OPTION (QUERYTRACEON 9481, QUERYTRACEON 3604, QUERYTRACEON 9204);
GO

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11711
OPTION (QUERYTRACEON 9481, QUERYTRACEON 3604, QUERYTRACEON 9204);
GO

---------------------------------------------
-- 10-20 should be enough for most tables
-- This is giving you 10-20x the steps!
---------------------------------------------

---------------------------------------------
-- Remove the filtered stats
---------------------------------------------

-- What if you want to quickly drop all of 
-- the column-level stats that were created.

EXEC [sp_SQLskills_DropAllColumnStats]
		  @schemaname		= N'dbo'
		, @objectname		= N'factinternetsales'
		, @columnname		= N'customerkey';

-- Just to reconfirm
EXEC [sp_SQLskills_helpindex] 'dbo.factinternetsales';
EXEC [sp_helpstats] 'dbo.FactInternetSales', 'ALL';
GO

-- Or, if you want to remove all of the stats:

EXEC [sp_SQLskills_DropAllColumnStats]
		  @schemaname		= N'dbo'
		, @objectname		= N'factinternetsales'
		, @columnname		= N'customerkey'
		, @dropall			= N'TRUE'

-- Just to reconfirm
EXEC [sp_SQLskills_helpindex] 'dbo.factinternetsales';
EXEC [sp_helpstats] 'dbo.FactInternetSales', 'ALL';
GO

---------------------------------------------
-- Final notes 
---------------------------------------------

-- Play around with this IN DEVELOPMENT/TEST (er, duh) 

-- Using the create filtered index proc will DROP all other 
-- stats that are just single column-level stats on the 
-- column where you're creating filtered stats.
-- *NEW* Only if they have a name LIKE 'SQLskills_FS%'

-- You should drop column-level stats that are redundant.

-- And, remember - these (PROBABLY) CANNOT be used without code
-- changes....

-- Finally, they don't seem to work in SQL Server 2014 and
-- the NEW CE. You must use the old CE to use filtered stats:

-- * Option 1 (low impact for upgrades): keep a lower compat level
--   Then, as desired (for non-filtered statistics use of the new CE)
--   use the 
