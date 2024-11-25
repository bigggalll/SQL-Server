-- Expanded AdventureWorks2014 using Jon's scripts:
-- http://www.sqlskills.com/blogs/jonathan/enlarging-the-adventureworks-sample-databases/

USE [AdventureWorks2014];
GO

SET STATISTICS TIME ON;
GO

-- Clear waits and latches
-- Looks at waiting tasks while it's running

DBCC CHECKDB ('AdventureWorks2014') WITH NO_INFOMSGS;
GO

   CPU time = 37879 ms,  elapsed time = 10438 ms.

-- Any computed column indexes?
USE [AdventureWorks2014];
GO

SELECT
    [s].[name] AS [Schema],
    [o].[name] AS [Object],
    [i].[name] AS [Index],
    [c].[name] AS [Column],
    [ic].*
FROM sys.columns [c]
JOIN sys.index_columns [ic]
    ON [ic].[object_id] = [c].[object_id]
    AND [ic].[column_id] = [c].[column_id]
JOIN sys.indexes [i]
    ON [i].[object_id] = [ic].[object_id]
    AND [i].[index_id] = [ic].[index_id]
JOIN sys.objects [o]
    ON [i].[object_id] = [o].[object_id]
JOIN sys.schemas [s]
    ON [o].[schema_id] = [s].[schema_id]
WHERE [c].[is_computed] = 1;
GO

-- Disable them
ALTER INDEX [AK_SalesOrderHeaderEnlarged_SalesOrderNumber]
	ON [Sales].[SalesOrderHeaderEnlarged] DISABLE;
ALTER INDEX [AK_Customer_AccountNumber]
	ON [Sales].[Customer] DISABLE;
ALTER INDEX [AK_Document_DocumentLevel_DocumentNode]
	ON [Production].[Document] DISABLE;
ALTER INDEX [IX_Employee_OrganizationLevel_OrganizationNode]
	ON [HumanResources].[Employee] DISABLE;
ALTER INDEX [AK_SalesOrderHeader_SalesOrderNumber]
	ON [Sales].[SalesOrderHeader] DISABLE;
GO

-- Clear waits and latches

DBCC CHECKDB ('AdventureWorks2014') WITH NO_INFOMSGS;
GO

-- Run-time comparison? WOW!

-- Rebuild indexes and clear up
SET STATISTICS TIME OFF;

ALTER INDEX [AK_SalesOrderHeaderEnlarged_SalesOrderNumber]
	ON [Sales].[SalesOrderHeaderEnlarged] REBUILD;
ALTER INDEX [AK_Customer_AccountNumber]
	ON [Sales].[Customer] REBUILD;
ALTER INDEX [AK_Document_DocumentLevel_DocumentNode]
	ON [Production].[Document] REBUILD;
ALTER INDEX [IX_Employee_OrganizationLevel_OrganizationNode]
	ON [HumanResources].[Employee] REBUILD;
ALTER INDEX [AK_SalesOrderHeader_SalesOrderNumber]
	ON [Sales].[SalesOrderHeader] REBUILD;
GO