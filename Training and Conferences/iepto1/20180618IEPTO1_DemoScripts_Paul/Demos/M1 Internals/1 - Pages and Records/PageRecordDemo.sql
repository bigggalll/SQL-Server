/*============================================================================
  File:     PageRecordDemo.sql

  Summary:  This script uses DBCC IND and DBCC PAGE
			to examine on-disk structures

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  (c) 2018, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE [master];
GO

IF DATABASEPROPERTYEX (N'Company', N'Version') > 0
BEGIN
	ALTER DATABASE [Company] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [Company];
END
GO

CREATE DATABASE [Company];
GO

USE [Company];
GO

-- Create a test table to use
CREATE TABLE [DbccPageTest] (
	[intCol1]		INT IDENTITY,
	[intCol2]		INT,
	[vcharCol]		VARCHAR (8000),
	[vcharCol2]		VARCHAR (8000),
	[lobCol]		VARCHAR (MAX));

INSERT INTO [DbccPageTest] VALUES (
	1, REPLICATE ('Row1', 600), 'a', REPLICATE ('Row1Lobs', 1000));
INSERT INTO [DbccPageTest] VALUES (
	2, REPLICATE ('Row2', 600), 'b', REPLICATE ('Row2Lobs', 1000));
INSERT INTO [DbccPageTest] VALUES (
	3, REPLICATE ('Row3', 600), 'c', REPLICATE ('Row3Lobs', 1000));
INSERT INTO [DbccPageTest] VALUES (
	4, REPLICATE ('Row4', 600), 'd', REPLICATE ('Row4Lobs', 1000));
GO

-- List all the pages:

-- In SQL 2012+ you can use the new sys.dm_db_database_page_allocations
SELECT * FROM sys.dm_db_database_page_allocations (
	DB_ID ('Company'), OBJECT_ID ('DbccPageTest'), 0, NULL, 'LIMITED');
	
SELECT * FROM sys.dm_db_database_page_allocations (
	DB_ID ('Company'), OBJECT_ID ('DbccPageTest'), 0, NULL, 'DETAILED');

-- Introducing DBCC IND, works in all versions back to 2000
DBCC IND (N'Company', N'DbccPageTest', -1);
GO

-- Pick a data page and use DBCC PAGE on
-- it. We just happen to know that the
-- first page is the first listed.
-- Trace flag is required for output except
-- when using WITH TABLERESULTS
-- Takes db, file, page, print option 1-3
DBCC TRACEON (3604);
GO

-- Option 1 is a hex dump of each record
-- plus interpreting the slot array.
DBCC PAGE (N'Company', 1, xx, 1);
GO

DBCC PAGE (N'Company', 1, xx, 1) WITH TABLERESULTS;
GO

-- Data page with data records

-- Option 2 is a hex dump of the page plus
-- interpreting the slot array
DBCC PAGE (N'Company', 1, XX, 2);
GO

-- Option 3 interprets each record fully
DBCC PAGE (N'Company', 1, XX, 3);
GO

-- Note the off-row link. Let's follow it.
DBCC PAGE (N'Company', 1, xx, 3);
GO

-- Text page

-- Now let's force a forwarding record by
-- updating a row in the middle of a page.
UPDATE [DbccPageTest]
	SET [vcharCol] = REPLICATE ('LongRow2', 1000)
	WHERE [intCol2] = 2;
GO

-- Look at the first data page again
DBCC PAGE (N'Company', 1, XX, 3);
GO

-- Now we've got a new record type. Let's
-- follow the link
DBCC PAGE (N'Company', 1, XX, 3);
GO

-- Another new record type. What's the
-- difference? The back-link... (note the
-- back link is only dumped from 2012 onwards)
-- Explain about NC indexes, and protection
-- against phantom reads.

-- New we create a clustered index
CREATE CLUSTERED INDEX [Dbcc_CL]
	ON [DbccPageTest] ([intCol1]);
GO

-- And look at the pages again, with
-- the new index ID
DBCC IND (N'Company', N'DbccPageTest', -1);
GO

-- Pick an index page - with type = 2.
DBCC PAGE (N'Company', 1, XX, 1);
GO

-- Index page with index records
-- Let's take a closer look.
DBCC PAGE (N'Company', 1, XX, 3);
GO

-- Explain the various columns and
-- UNIQUIFIERS

-- Now let's look at the first data page
DBCC IND (N'Company', N'DbccPageTest', -1);
GO

DBCC PAGE (N'Company', 1, XX, 3);
GO

-- And force a row-overflow column
UPDATE [DbccPageTest]
	SET [vcharCol2] = REPLICATE ('LongRow1', 900)
	WHERE [intCol1] = 1;
GO

DBCC PAGE (N'Company', 1, XX, 3);
GO

-- Examine the variable length column offset array
-- starting with col count at 0x0F.
-- Why 4 columns?
-- What does 0x8000 bit in offset mean?

-- Now add a non-clustered index
CREATE NONCLUSTERED INDEX [Dbcc_NCL]
	ON [DbccPageTest] ([intCol2]);
GO

-- And look at the pages again, with
-- the new index ID
DBCC IND (N'Company', N'DbccPageTest', -1);
GO

-- Pick another index page and explain the
-- key columns
DBCC PAGE (N'Company', 1, XX, 3);
GO

-- Now drop the clustered index and look
-- again at the nonclustered index
DROP INDEX [Dbcc_CL] ON [DbccPageTest];
GO

DBCC IND (N'Company', N'DbccPageTest', -1);
GO

DBCC PAGE (N'Company', 1, XX, 3);
GO

-- Prove physical row order does not
-- need to match key order

-- Recreate the database
USE [master];
GO

IF DATABASEPROPERTYEX (N'Company', N'Version') > 0
BEGIN
	ALTER DATABASE [Company] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [Company];
END
GO

CREATE DATABASE [Company];
GO

USE [Company];
GO

-- Create a test table
CREATE TABLE [OrderTest] ([c1] INT, [c2] VARCHAR (10));
CREATE CLUSTERED INDEX [OrderCL] ON [OrderTest] ([c1]);
GO

-- Insert values from 2 to 5, missing c1 = 1
INSERT INTO [OrderTest] VALUES (2, REPLICATE ('b', 10));
INSERT INTO [OrderTest] VALUES (3, REPLICATE ('c', 10));
INSERT INTO [OrderTest] VALUES (4, REPLICATE ('d', 10));
INSERT INTO [OrderTest] VALUES (5, REPLICATE ('e', 10));
GO

-- Look at the page
DBCC IND (N'Company', N'OrderTest', -1);
GO

DBCC PAGE (N'Company', 1, XX, 2);
GO

-- Now insert c1 = 1 and look at the page again
INSERT INTO [OrderTest] VALUES (1, REPLICATE ('a', 10));
GO

DBCC PAGE (N'Company', 1, XX, 2);
GO

-- Check out the record *offset* on the page
-- even though it's slot # 0

-- Find record location
SELECT
	*,
	%%PHYSLOC%%
FROM
	[OrderTest];
GO

-- And now human-readable...
SELECT
	[o].*,
	[p].*
FROM
	[OrderTest] [o]
CROSS APPLY
	fn_PhysLocCracker (%%PHYSLOC%%) [p];
GO



