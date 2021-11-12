/*============================================================================
  File:     FilteredIndexes.sql

  Summary:  Setup and investigate Filtered Indexes

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

USE AdventureWorks2012;
GO

IF INDEXPROPERTY(OBJECT_ID(N'Production.BillOfMaterials')
				, N'BillOfMaterialsWithFilter' 
				, 'IndexID') > 1
DROP INDEX BillOfMaterialsWithFilter
    ON Production.BillOfMaterials;
GO

IF INDEXPROPERTY(OBJECT_ID(N'Production.BillOfMaterials')
				, N'BillOfMaterialsNoFilter' 
				, 'IndexID') > 1
DROP INDEX BillOfMaterialsNoFilter
    ON Production.BillOfMaterials;
GO

IF INDEXPROPERTY(OBJECT_ID(N'Production.BillOfMaterials')
				, N'BillOfMaterialsF2Inc' 
				, 'IndexID') > 1
DROP INDEX BillOfMaterialsF2Inc
    ON Production.BillOfMaterials;
GO

CREATE NONCLUSTERED INDEX [BillOfMaterialsWithFilter]
    ON Production.BillOfMaterials 
        (ComponentID, StartDate)
    WHERE EndDate IS NOT NULL;
GO

CREATE NONCLUSTERED INDEX [BillOfMaterialsNoFilter]
    ON Production.BillOfMaterials 
        (ComponentID, StartDate)
GO

-- First, what's the difference in size:
SELECT * 
FROM sys.dm_db_index_physical_stats
(db_id(), OBJECT_ID(N'Production.BillOfMaterials'), NULL, NULL, 'detailed')
WHERE index_id IN ((INDEXPROPERTY(OBJECT_ID(N'Production.BillOfMaterials')
				, N'BillOfMaterialsWithFilter' 
				, 'IndexID')), (INDEXPROPERTY(OBJECT_ID(N'Production.BillOfMaterials')
				, N'BillOfMaterialsNoFilter' 
				, 'IndexID'))) 
				
-- Reviewing the LEVEL 0
-- Index_id 5 (WithFilter) has 199 rows
-- Index_id 6 (NoFilter) has 2679 rows
-- this translates into pages, levels, maintenance...

-- What about queries?

-- Turn showplan on (Query, Include Actual Execution Plan)
SET STATISTICS IO ON
GO

-- The following query works perfectly as the predicate matches
-- and the index covers the query.
SELECT ComponentID, StartDate 
FROM Production.BillOfMaterials
WHERE EndDate IS NOT NULL;
GO

-- In the following case, SQL Server can't use the index at all 
-- because EndDate is NOT in the non-clustered index.
SELECT ComponentID, StartDate 
FROM Production.BillOfMaterials
WHERE EndDate > '20000101';
GO

-- A better filtered index might be to filter over the predicate
-- (especially if you plan to query on that specific attribute
-- and/or for ranges/values within that column) and make the
-- predicate the key. Then, INCLUDE the other columns for better
-- query performance.

CREATE NONCLUSTERED INDEX [BillOfMaterialsF2Inc]
    ON Production.BillOfMaterials (EndDate)
    INCLUDE (ComponentID, StartDate)
    WHERE EndDate IS NOT NULL;
GO

SELECT * 
FROM sys.dm_db_index_physical_stats
(db_id(), OBJECT_ID(N'Production.BillOfMaterials'), NULL, NULL, 'detailed');
GO

EXEC SP_HELPINDEX 'Production.BillOfMaterials';
EXEC [sp_sqlskills_helpindex] 'Production.BillOfMaterials';
GO

-- Both queries benefit!
SELECT ComponentID, StartDate 
FROM Production.BillOfMaterials
WHERE EndDate IS NOT NULL;
GO

SELECT ComponentID, StartDate, EndDate  
FROM Production.BillOfMaterials
WHERE EndDate IS NOT NULL;
GO

SELECT ComponentID, StartDate 
FROM Production.BillOfMaterials
WHERE EndDate > '20000101';
GO
