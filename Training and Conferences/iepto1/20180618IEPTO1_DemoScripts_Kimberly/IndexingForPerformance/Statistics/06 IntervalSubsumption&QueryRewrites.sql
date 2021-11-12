/*============================================================================
  File:     IntervalSubsumption&QueryRewrites.sql

  Summary:  When might a filtered object NOT get used?
				Are there options for query re-writing the
				query?
  
  SQL Server Version: SQL Server 2008+
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

-- You can get my version of sp_helpindex 
-- here: https://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/
EXEC [sp_SQLskills_helpindex] 'dbo.factinternetsales';
EXEC [sp_helpstats] 'dbo.FactInternetSales', 'ALL';
GO

---------------------------------------------
--They can't be used over intervals
--Problem: Interval subsumption
---------------------------------------------

-- These are all within ONE filtered set
---------------------------------------------

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s] 
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] IN (11053, 11152, 11222)
OPTION (QUERYTRACEON 9481, QUERYTRACEON 3604, QUERYTRACEON 9204, RECOMPILE);
GO


-- These are NOT within ONE filtered set
---------------------------------------------
SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s] --WITH (FORCESEEK)
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] IN (11509, 12238)
OPTION (QUERYTRACEON 9481, QUERYTRACEON 3604, QUERYTRACEON 9204, RECOMPILE);
GO


-- This doesn't always work but sometimes a query re-write 
-- might make a difference
---------------------------------------------
SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s] 
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11509

UNION ALL

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s] 
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 12238

OPTION (QUERYTRACEON 9481, QUERYTRACEON 3604, QUERYTRACEON 9204);
GO

-- Again, still working
---------------------------------------------
SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s] 
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11509

UNION ALL

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s] 
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 12238

UNION ALL

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s] 
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11186

UNION ALL

SELECT [c].[CustomerKey], [c].[LastName], [s].[SalesAmount]
FROM [dbo].[FactInternetSales] AS [s] 
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] = 11435

OPTION (QUERYTRACEON 9481, QUERYTRACEON 3604, QUERYTRACEON 9204);
GO

