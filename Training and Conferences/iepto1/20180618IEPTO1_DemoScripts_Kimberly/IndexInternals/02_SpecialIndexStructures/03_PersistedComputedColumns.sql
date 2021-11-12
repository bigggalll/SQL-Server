/*============================================================================
  File:     PersistedComputedColumns.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  This script shows an example of a persisted computed
            column as described in Chapter 6 of SQL Server 2008 
            Internals.
  
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

USE Northwind;
go

-----------------------------------------------------------------------------
-- Attempt to index an imprecise column
------------------------------------------------------------------------------

ALTER TABLE [Order Details]
ADD 
    Final AS (Quantity * UnitPrice) 
                - Discount * (Quantity * UnitPrice);
go

CREATE INDEX OD_Final_Index 
ON [Order Details] (Final);
go

-- To check to see if a computed column must be persisted:
SELECT COLUMNPROPERTY (OBJECT_ID ('Order Details'), 'Final', 'IsPrecise');

-- Instead, if you drop the column and recreate it as a PERSISTED
-- computed column, you can then index it.

ALTER TABLE [Order Details]
DROP COLUMN Final;
go

ALTER TABLE [Order Details]
ADD 
    Final AS (Quantity * UnitPrice) 
                - Discount * (Quantity * UnitPrice) PERSISTED;
go

CREATE INDEX OD_Final_Index 
ON [Order Details](Final);
go

-- To see the row structure, with the PERSISTED computed column, 
-- use DBCC IND and DBCC PAGE from prior examples:

TRUNCATE TABLE sp_tablepages;
INSERT sp_tablepages
EXEC ('DBCC IND (Northwind, [Order Details], 1)');
go

SELECT IndexLevel
    , PageFID
    , PagePID
    , PrevPageFID
    , PrevPagePID
    , NextPageFID
    , NextPagePID
FROM sp_tablepages
ORDER BY IndexLevel DESC, PrevPagePID;
GO

-- The Root Page is PageFID = 1, PagePID = 262
DBCC TRACEON (3604)
go

DBCC PAGE (Northwind, 1, 262, 3);
go

-- The first data page is PageFID = 1, PagePID = 228

DBCC PAGE (Northwind, 1, 228, 3);
go