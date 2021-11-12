/*============================================================================
  File:     IAMPages.sql

  Summary:  This script examines IAM pages

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

-- Create a table
CREATE TABLE [SimpleTable] (
	[intCol1]		INT IDENTITY,
	[intCol2]		INT,
	[vcCol3]		VARCHAR (8000),
	[vcCol4]		VARCHAR (8000),
	[vcmaxCol5]		VARCHAR (MAX));
GO

CREATE CLUSTERED INDEX [SimpleCL] ON [SimpleTable] ([intCol1]);
GO

INSERT INTO [SimpleTable] VALUES (1, 'tiny', 'small', 'inrowLOB');
GO

-- Use DBCC IND to get the metadata
DBCC IND (N'Company', N'SimpleTable', -1);
GO

-- Force the varchar (max) data off-row by
-- updating one of the varchar(8000) cols
-- and *then* the vc(max) column. The vc(max)
-- column will be pushed off-row first.
UPDATE [SimpleTable] SET [vcCol3] = REPLICATE ('a', 5000);
GO
UPDATE [SimpleTable] SET [vcmaxCol5] = REPLICATE ('a', 5000);
GO

-- Check again what metadata there is
DBCC IND (N'Company', N'SimpleTable', -1);
GO

-- Now force a varchar(8000) value off-row
-- using the row-overflow feature
UPDATE [SimpleTable] SET [vcCol4] = REPLICATE ('a', 5000);
GO

-- Check again what metadata there is
DBCC IND (N'Company', N'SimpleTable', -1);
GO

-- Now insert a bunch of records
INSERT INTO [SimpleTable] VALUES (
	1,
	replicate ('a', 5000),
	replicate ('b', 5000),
	replicate ('c', 8000));
GO 100

-- And check again
DBCC IND (N'Company', N'SimpleTable', -1);
GO

-- Can be kind of hard to tell which page is which.
-- Which one is the root page of the index?

-- Use a different method
EXEC sp_AllocationMetadata N'SimpleTable';
GO

-- Look at the code...

-- Look at an IAM page
DBCC TRACEON (3604)
GO
DBCC PAGE (N'Company', 1, XX, 3);
GO


-- Now add a file to the database and allocate
-- more pages
ALTER DATABASE [Company] ADD FILE (
	NAME = N'SecondFile',
	FILENAME = N'D:\SQLskills\SecondFile.ndf');
GO

INSERT INTO [SimpleTable] VALUES (
	1,
	replicate ('a', 5000),
	replicate ('b', 5000),
	replicate ('c', 8000));
GO 100

-- Look at the IAM page again...
DBCC PAGE (N'Company', 1, XX, 3);
GO

-- Follow the next page link...
DBCC PAGE (N'Company', 1, XX, 3);
GO

-- Look at sequence number, start_pg, prev_page
-- Now we have an IAM chain!

-- Add a non-clustered index on just an
-- INT column
CREATE NONCLUSTERED INDEX [NC1]	ON [SimpleTable] ([intCol2]);
GO

EXEC sp_AllocationMetadata N'SimpleTable';
GO

-- Add another one which includes both
-- varchar(8000) columns and will have
-- row-overflow immediately
CREATE NONCLUSTERED INDEX [NC2]
	ON [SimpleTable] ([intCol2])
	INCLUDE ([vcCol3], [vcCol4]);
GO

EXEC sp_AllocationMetadata N'SimpleTable';
GO

-- And a final that has all three kinds of
-- allocation units
CREATE NONCLUSTERED INDEX [NC3]
	ON [SimpleTable] ([intCol2])
	INCLUDE ([vcCol3], [vcCol4], [vcmaxCol5]);
GO

EXEC sp_AllocationMetadata N'SimpleTable';
GO
