/*============================================================================
  File:     RecordRelocationInAHeap.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  From the Data Modification Internals section, this script
            describes how modifications can create forwarding pointers
            in a heap.
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
    a int IDENTITY ,
    b varchar(1600),
    c varchar(1600)
);
go

INSERT INTO bigrows
    VALUES (REPLICATE('a', 1600), '');
INSERT INTO bigrows
    VALUES (REPLICATE('b', 1600), '');
INSERT INTO bigrows
    VALUES (REPLICATE('c', 1600), '');
INSERT INTO bigrows
    VALUES (REPLICATE('d', 1600), '');
INSERT INTO bigrows
    VALUES (REPLICATE('e', 1600), '');
go

TRUNCATE TABLE sp_tablepages;
INSERT INTO sp_tablepages
EXEC ('DBCC IND (AdventureWorks2008, bigrows, -1)' );

SELECT PageFID, PagePID
FROM sp_tablepages
WHERE PageType = 1;
go

-- RESULTS: (Yours may vary.)
--  PageFID PagePID
--  ------- -----------
--  1       21829

DBCC TRACEON(3604);
go

-- Be sure to enter YOUR PagePID:
DBCC PAGE(AdventureWorks2008, 1, 21829, 1);
go

UPDATE bigrows
    SET c = REPLICATE('x', 1600)
WHERE a = 3;
go

TRUNCATE TABLE sp_tablepages;
INSERT INTO sp_tablepages
EXEC ('DBCC IND (AdventureWorks2008, bigrows, -1)' );

SELECT PageFID, PagePID
FROM sp_tablepages
WHERE PageType = 1;
go

-- RESULTS: (Yours may vary.)
--  PageFID PagePID
--  ------- -----------
--  1       21829
--  1	    21912

DBCC TRACEON(3604);
go

-- Be sure to enter YOUR PagePID:
DBCC PAGE(AdventureWorks2008, 1, 21829, 1);
go

-- Review the "forwarding stub" where record 3 used to be...
--  Slot 2, Offset 0x1feb, Length 9, DumpStyle BYTE

--  Record Type = FORWARDING_STUB        Record Attributes =                  Record Size = 9

--  Memory Dump @0x635ADFEB

--  00000000:   04985500 00010000 00†††††††††††††††††..U......                

-- In the last line you can see 04985500 and the first byte (04) solely
-- means that it's a forwarded record. 985500 is the (reverse) page number 
-- in hex 0x005598 -> page 21912

SELECT convert(int, 0x005598) --> 21912
go

DBCC PAGE(AdventureWorks2008, 1, 21912, 1);
go

-- Reviewing the forwarded record we can see the following in the row
-- structure:

--  Record Type = FORWARDED_RECORD       Record Attributes =  NULL_BITMAP VARIABLE_COLUMNS
--  Record Size = 3229                   
--  Memory Dump @0x6401C6BB


-- To see forwarding pointers in a table, use sys.dm_db_index_physical_stats
-- with either the SAMPLED or DETAILED views:
SELECT forwarded_record_count
    , object_name(object_id) AS ObjectName
    , * 
FROM sys.dm_db_index_physical_stats
    (db_id(), object_id('bigrows'), null, null, 'DETAILED');
go