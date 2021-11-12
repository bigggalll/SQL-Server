/*============================================================================
  File:     Autopilot

  Summary:  Will SQL Server use that index? (without creating it)

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

USE [AdventureWorksDW2008_ModifiedSalesKey];
GO

-- Cleanup
DROP INDEX [FactInternetSales].[ShipDateOrderDateInd]
DROP INDEX [FactInternetSales].[ShipDateOrderDateInd_SeekableForMin]
DROP INDEX [FactInternetSales].[IX_FactInternetSales_CustomerKey_INCSalesAmount]
GO

EXEC sp_helpindex FactInternetSales;
GO
------------------------------------------
-- Should we create the index?
-- But, how long does it take to create (and test)

-- What about autopilot?

-- Check out this great article on Simple Talk
-- "Hypothetical Indexes on SQL Server"
-- https://www.simple-talk.com/sql/database-administration/hypothetical-indexes-on-sql-server/
------------------------------------------

CREATE NONCLUSTERED INDEX [ShipDateOrderDateInd]
ON [dbo].[FactInternetSales] 
	([ShipDateKey])
INCLUDE 
	([OrderDateKey])
WITH STATISTICS_ONLY = -1;
GO

CREATE NONCLUSTERED INDEX [ShipDateOrderDateInd_SeekableForMin]
ON [dbo].[FactInternetSales]
	 ([ShipDateKey], [OrderDateKey])
WITH STATISTICS_ONLY = -1;
GO

EXEC sp_SQLskills_helpindex 'dbo.factinternetsales';
GO

SELECT db_id(), object_id('factinternetsales');
GO

SELECT * 
FROM sys.indexes 
WHERE [object_id] = object_id('factinternetsales');
GO

-- Params: 0, DBID, ObjectID, IndexID
DBCC AUTOPILOT(0, 8, 2053582354, 2);
DBCC AUTOPILOT(0, 8, 2053582354, 3);
GO

-- Autopilot (hypothetical indexes) are only
-- used with the old CE. This is also true
-- for filtered stats & multi-column statistics.
SELECT  [name], [compatibility_level]
FROM    [sys].[databases];
GO

SET AUTOPILOT ON;
GO

SELECT MIN([fis].[OrderDateKey])
FROM [dbo].[FactInternetSales] AS [fis]
WHERE [fis].[ShipDateKey] IS NULL
OPTION (QUERYTRACEON 9481); -- add this to use the Legacy CE
GO

SET AUTOPILOT OFF;
GO

DROP INDEX [FactInternetSales].[ShipDateOrderDateInd]
DROP INDEX [FactInternetSales].[ShipDateOrderDateInd_SeekableForMin]