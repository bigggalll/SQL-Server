/*============================================================================
  File:     SplittingALeafPage.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  From the Data Modification Internals section, this script
            describes how a split in a leaf level page occurs.
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

DROP TABLE bigrows;
go

CREATE TABLE bigrows
(
    a int PRIMARY KEY,
    b varchar(1600)
);
go

/* Insert five rows into the table */
INSERT INTO bigrows
    VALUES (5, REPLICATE('a', 1600));
INSERT INTO bigrows
    VALUES (10, replicate('b', 1600));
INSERT INTO bigrows
    VALUES (15, replicate('c', 1600));
INSERT INTO bigrows
    VALUES (20, replicate('d', 1600));
INSERT INTO bigrows
    VALUES (25, replicate('e', 1600));
go

TRUNCATE TABLE sp_tablepages;
INSERT INTO sp_tablepages
EXEC ('DBCC IND ( AdventureWorks2008, bigrows, -1)' );
go

SELECT PageFID, PagePID
FROM sp_tablepages
WHERE PageType = 1;
go

-- RESULTS: (Yours may vary.)
--  PageFID PagePID
--  ------- -----------
--  1       23109

DBCC TRACEON(3604);
go

-- Be sure to enter YOUR PagePID:
DBCC PAGE(AdventureWorks2008, 1, 23109, 1);
go

-- Review the slot array from the DBCC PAGE output:
--  Row - Offset                         
--  4 (0x4) - 6556 (0x199c)              
--  3 (0x3) - 4941 (0x134d)              
--  2 (0x2) - 3326 (0xcfe)               
--  1 (0x1) - 1711 (0x6af)               
--  0 (0x0) - 96 (0x60)   

-- Insert an additional row and look at the slot array again:
INSERT INTO bigrows
    VALUES (22, REPLICATE('x', 1600));
go

-- Be sure to enter YOUR PagePID:
DBCC PAGE(AdventureWorks2008, 1, 23109, 1);
go

-- Rows with characters A, B and C stayed (PK of 5, 10 and 15)
--  Row - Offset                         
--  2 (0x2) - 3326 (0xcfe)               
--  1 (0x1) - 1711 (0x6af)               
--  0 (0x0) - 96 (0x60)   

-- Where did the other row go to??

TRUNCATE TABLE sp_tablepages;
INSERT sp_tablepages
EXEC ('DBCC IND (AdventureWorks2008, bigrows, 1)');
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
go

-- The Root Page is PageFID = 1, PagePID = 23111 (Yours may vary.)
DBCC TRACEON (3604)
go

DBCC PAGE (AdventureWorks2008, 1, 23111, 3);
go

-- The table ONLY has two pages. The original page: 23109
-- And the new page that's been added after the split: 25168
DBCC PAGE (AdventureWorks2008, 1, 25168, 1);
go

-- Notice the slot array:
--  Row - Offset                         
--  2 (0x2) - 1711 (0x6af)               
--  1 (0x1) - 3326 (0xcfe)               
--  0 (0x0) - 96 (0x60)  

-- Rows 20 and 25 moved and THEN 22 was inserted. It's offset is
-- 3326 even though it's slot is slot 1.