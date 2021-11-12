/*============================================================================
  File:     DeletingRowsInAHeap.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  From the Data Modification Internals section, this script
            describes how deletes occur within a heap.
            From Chapter 6 of SQL Server 2008 Internals.
  
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

CREATE TABLE smallrows
(
    a int identity,
    b char(10)
);
go

INSERT INTO smallrows
    VALUES ('row 1');
INSERT INTO smallrows
    VALUES ('row 2');
INSERT INTO smallrows
    VALUES ('row 3');
INSERT INTO smallrows
    VALUES ('row 4');
INSERT INTO smallrows
    VALUES ('row 5');
go

TRUNCATE TABLE sp_tablepages;
INSERT INTO sp_tablepages
EXEC ('DBCC IND (AdventureWorks2008, smallrows, -1)' );

SELECT PageFID, PagePID
FROM sp_tablepages
WHERE PageType = 1;

-- RESULTS: (Yours may vary.)
--  PageFID PagePID
--  ------- -----------
--  1       25187

DBCC TRACEON(3604);
go

-- Be sure to enter YOUR PagePID:
DBCC PAGE(AdventureWorks2008, 1, 25187, 1);
go

-- Next, we delete the middle row (WHERE a = 3) and look at 
-- the page again:
DELETE FROM smallrows
WHERE a = 3;
go

-- Be sure to enter YOUR PagePID:
DBCC PAGE(AdventureWorks2008, 1, 25187, 1);
go

-- The slot array at the bottom of the page shows that the 
-- third row (at slot 2) is now at offset 0 (which means there 
-- really is no row using slot 2), and the row using slot 3 is 
-- at its same offset as before the DELETE. The data on the 
-- page is not compacted.
