/*============================================================================
  File:     ExaminingtheClusteredIndexUniquifier.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  This script describes how the UNIQUIFIER works when a clustered
            index has been defined - but is not unique - as described in 
            Chapter 6 of SQL Server 2008 Internals.
  
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

IF OBJECTPROPERTY(object_id('Clustered_Dupes'), 'IsUserTable') IS NOT NULL
    DROP TABLE Clustered_Dupes;
go

CREATE TABLE Clustered_Dupes
(
    Col1    CHAR(5)    NOT NULL,
    Col2    INT        NOT NULL,
    Col3    CHAR(3)    NULL,
    Col4    CHAR(6)    NOT NULL
);
go

CREATE CLUSTERED INDEX Cl_dupes_col1 
ON Clustered_Dupes(col1);
go

------------------------------------------------------------------------------
-- If you look at the row in the sysindexes compatibility view for this table, 
-- you notice something [probably] unexpected. keycnt has a value of 2...
------------------------------------------------------------------------------
SELECT indid, keycnt, name 
FROM sysindexes
WHERE id = OBJECT_ID ('Clustered_Dupes');
go


------------------------------------------------------------------------------
-- From sys.indexes you cannot see this key count but you can see that
-- the index is not unique (UNIQUE has a value of 0). 
------------------------------------------------------------------------------
SELECT index_id, *
FROM sys.indexes  
WHERE [object_id] = object_id ('Clustered_Dupes'); 
go


------------------------------------------------------------------------------
-- Next, we'll add some data and begin to analyze the base row structure.
-- NOTE: go n executes the batch n times.
------------------------------------------------------------------------------
INSERT Clustered_Dupes VALUES ('ABCDE', 123, null, 'CCCC'); 
go 2

 
------------------------------------------------------------------------------
-- To find the first (or only) data page of the table, three methods are 
-- available. 
--    1) We can examine the first column from the sysindexes compatibility 
--       view. 
--    2) We can run a query that joins the catalog view sys.indexes to
--       sys.partitions and sys.system_internals_allocation_units. 
--    3) We can use DBCC IND to find the first page by finding a PageType 
--       of 1 with no previous page.

-- For simplicity, we'll use option with our sp_tablepages procedure. 
------------------------------------------------------------------------------

TRUNCATE TABLE sp_tablepages; 
INSERT INTO sp_tablepages 
    EXEC ('dbcc ind (''AdventureWorks2008'', ''Clustered_Dupes'', -1)'  ); 
go

SELECT PageFID, PagePID 
FROM sp_tablepages 
WHERE PageType = 1 
    AND PrevPageFID = 0 
    AND PrevPagePID = 0;
go    


------------------------------------------------------------------------------
-- Although this single-row table has only one data page, I can use the preceding 
-- WHERE clause to find the first data page in any table with a clustered index.

-- After inserting the results of DBCC IND into the table. Here are *my* results:
------------------------------------------------------------------------------

--  PageFID PagePID 
--  ------- ----------- 
--  1       23105

------------------------------------------------------------------------------
-- The output tells me that the first page of the table is on file 1, page 23105, 
-- so we can use DBCC PAGE to examine that page. 
-- 
-- IMPORTANT: Remember to REPLACE the following command with YOUR page number.
------------------------------------------------------------------------------
DBCC TRACEON (3604); 
go
 
DBCC PAGE (AdventureWorks2008, 1, 23105, 3);
go


------------------------------------------------------------------------------
-- Reviewing the output with DUMP STYLE 3, you see two things that are helpful:
------------------------------------------------------------------------------

-- For the first row we see that the UNIQUIFIER = 0 and we confirm that it
-- takes 0 bytes of space by looking at the Length (physical) which is 0:

--  Slot 0 Column 0 Offset 0x0 Length 4 Length (physical) 0

--  UNIQUIFIER = 0                       


-- For the second row we see that the UNIQUIFIER = 1 and we confirm that it
-- takes 4 bytes of space by looking at the Length (physical) which is 4:

--  Slot 1 Column 0 Offset 0x1d Length 4 Length (physical) 4

--  UNIQUIFIER = 1                     



------------------------------------------------------------------------------
-- Adding 3 more rows confirms that ONLY the duplicate values have a 
-- uniquifier.
------------------------------------------------------------------------------

INSERT Clustered_Dupes VALUES ('FGHIJ', 456, null, 'AAAA'); 
go
INSERT Clustered_Dupes VALUES ('KLMNO', 789, null, 'BBBB'); 
go 2

------------------------------------------------------------------------------
-- Review the output again to see these new 3 rows!
-- IMPORTANT: Remember to REPLACE the following command with YOUR page number.
------------------------------------------------------------------------------
DBCC TRACEON (3604); 
go
 
DBCC PAGE (AdventureWorks2008, 1, 23105, 3);
go


------------------------------------------------------------------------------
-- Finally, the uniquifier is determined at the time of insert - all they do is 
-- add one - to the existing key's greatest uniquifier.

-- Here we'll add 8 more rows to the already duplicated key of KLMNO.
------------------------------------------------------------------------------

INSERT Clustered_Dupes VALUES ('KLMNO', 789, null, 'Dupe02'); 
INSERT Clustered_Dupes VALUES ('KLMNO', 789, null, 'Dupe03'); 
INSERT Clustered_Dupes VALUES ('KLMNO', 789, null, 'Dupe04'); 
INSERT Clustered_Dupes VALUES ('KLMNO', 789, null, 'Dupe05'); 
INSERT Clustered_Dupes VALUES ('KLMNO', 789, null, 'Dupe06'); 
INSERT Clustered_Dupes VALUES ('KLMNO', 789, null, 'Dupe07'); 
INSERT Clustered_Dupes VALUES ('KLMNO', 789, null, 'Dupe08'); 
INSERT Clustered_Dupes VALUES ('KLMNO', 789, null, 'Dupe09'); 
go


------------------------------------------------------------------------------
-- Review the output again to see these 8 new rows (and the value of 
-- col4 should be equal to the uniquifier value).
-- IMPORTANT: Remember to REPLACE the following command with YOUR page number.
------------------------------------------------------------------------------
DBCC TRACEON (3604); 
go
 
DBCC PAGE (AdventureWorks2008, 1, 23105, 3);
go


------------------------------------------------------------------------------
-- What's the next uniquifier - well, it depends on the value:
-- For 'ABCDE' it should be 2
-- FOR 'KLMNO' it should be 10
------------------------------------------------------------------------------

INSERT Clustered_Dupes VALUES ('ABCDE', 321, null, 'NewDup'); 
go 
INSERT Clustered_Dupes VALUES ('KLMNO', 321, null, 'NewDup'); 
go 


------------------------------------------------------------------------------
-- Review the output again...
-- This time, use dump style 1 to see the slot array. Our two latest rows
-- are LAST on the page physically even though our new ABCDE row is logically
-- 3rd!
-- IMPORTANT: Remember to REPLACE the following command with YOUR page number.
------------------------------------------------------------------------------
DBCC TRACEON (3604); 
go
 
DBCC PAGE (AdventureWorks2008, 1, 23105, 1);
go

-- See how row 2 (in reverse order from the bottom) shows a location of 
-- 501. This is higher than row 13 and less than row 14.

--  14 (0xe) - 534 (0x216)               
--  13 (0xd) - 468 (0x1d4)               
--  12 (0xc) - 435 (0x1b3)               
--  11 (0xb) - 402 (0x192)               
--  10 (0xa) - 369 (0x171)               
--   9 (0x9) - 336 (0x150)                
--   8 (0x8) - 303 (0x12f)                
--   7 (0x7) - 270 (0x10e)                
--   6 (0x6) - 237 (0xed)                 
--   5 (0x5) - 204 (0xcc)                 
--   4 (0x4) - 179 (0xb3)                 
--   3 (0x3) - 154 (0x9a)                 
--   2 (0x2) - 501 (0x1f5)                
--   1 (0x1) - 121 (0x79)                 
--   0 (0x0) -  96 (0x60)

-- Use dump style 3 to confirm the uniquifier values
DBCC TRACEON (3604); 
go
 
DBCC PAGE (AdventureWorks2008, 1, 23105, 3);
go

--This row: ('ABCDE', 321, null, 'NewDup') has a UNIQUIFIER of 2
--This row: ('KLMNO', 321, null, 'NewDup') has a UNIQUIFIER of 10


------------------------------------------------------------------------------
-- Finally, for a bit more fun - what happens as rows are removed?!
-- Delete Dupe06 and the next one will still be 11
-- Delete 11 and if that's the last one - the next dupe will be 11 again!
------------------------------------------------------------------------------

DELETE Clustered_Dupes 
WHERE Col1 = 'KLMNO' AND Col4 = 'Dupe06'
go

INSERT Clustered_Dupes VALUES ('KLMNO', 901, null, 'DelDup'); 
go 

-- Use dump style 3 to confirm the uniquifier values
DBCC TRACEON (3604); 
go
 
DBCC PAGE (AdventureWorks2008, 1, 23105, 3);
go

-- As expected - UNIQUIFIER = 11

-- Execute the next two statements as a single batch

---------------------------
-- EXECUTE TOGETHER - BEGIN
DELETE Clustered_Dupes 
WHERE Col1 = 'KLMNO' AND Col4 = 'DelDup'
go

INSERT Clustered_Dupes VALUES ('KLMNO', 901, null, 'Last1'); 
go 
-- EXECUTE TOGETHER - END
---------------------------

-- Use dump style 3 to confirm the uniquifier values
DBCC TRACEON (3604); 
go
 
DBCC PAGE (AdventureWorks2008, 1, 23105, 3);
go

-- Wait - what if the ghost process hasn't cleanup? Did you see
-- Record Type = GHOST_DATA_RECORD??

-- Let's try again:

DELETE Clustered_Dupes 
WHERE Col1 = 'KLMNO' AND Col4 = 'Last1'
go

-- Check the page? They'll probably be gone already...

DBCC TRACEON (3604); 
go
 
DBCC PAGE (AdventureWorks2008, 1, 23105, 3);
go

-- OK, is the highest UNIQUIFIER 10?

INSERT Clustered_Dupes VALUES ('KLMNO', 901, null, 'Last1'); 
go 

-- Use dump style 3 to confirm the uniquifier value is 11 - AGAIN!
DBCC TRACEON (3604); 
go
 
DBCC PAGE (AdventureWorks2008, 1, 23105, 3);
go
