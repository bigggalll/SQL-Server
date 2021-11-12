/*============================================================================
  File:     Understanding Versions

  Summary:  How does versioning work for an insert v. an update?
            Does the pointer stay in the row even when the version
            is removed?  
            
  SQL Server Version: 2005+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

IF DATABASEPROPERTYEX('ViewVersions', 'Collation') IS NOT NULL
	DROP DATABASE [ViewVersions];
GO

CREATE DATABASE [ViewVersions];
GO

ALTER DATABASE [ViewVersions]
SET READ_COMMITTED_SNAPSHOT ON;
GO

ALTER DATABASE [ViewVersions]
SET ALLOW_SNAPSHOT_ISOLATION ON;
go

USE [ViewVersions];
GO

CREATE TABLE [dbo].[tbl_ViewVersions]
(  
    c1  int identity,
    c2  char(12) default 'ViewVersions',
    c3  datetime default getdate()
);
GO

INSERT [dbo].[tbl_ViewVersions] DEFAULT VALUES;
GO 10

-- See the page on which this table resides:
DBCC IND (ViewVersions, [tbl_ViewVersions], -1);
GO

-- Output will look similar to this:
--PageFID	PagePID	IAMFID	IAMPID	ObjectID	IndexID	PartitionNumber	PartitionID	iam_chain_type	PageType	IndexLevel	NextPageFID	NextPagePID	PrevPageFID	PrevPagePID
--1	        293	    NULL	NULL	245575913	0	1	72057594040549376	In-row data	10	NULL	0	0	0	0
--1	        292	    1	    293	    245575913	0	1	72057594040549376	In-row data	1	0	0	0	0	0

-- The page in File 1, Page 302 is the table's IAM page
-- The page in File 1, Page 301 is the table's DATA page

-- Let's view what the data looks like:
DBCC TRACEON  (3604); 
GO

DBCC PAGE (ViewVersions, 1, 301, 3);
GO

-- Notice that every row that was inserted has a 
-- different "insert time[stamp]"

-- Version Information = 
--	Transaction Timestamp: 911
--	Version Pointer: Null

-- but not a version pointer.

-- Inserts go into the table but NOT into the version store

-- Now, let's look at the effect of an update...

-- Run a transaction in another window:
-- This is what's going to require the version
-- to stick around.
-- Open / execute script: 01_OpenTransaction.sql
SELECT * FROM [dbo].[tbl_ViewVersions]
UPDATE [dbo].[tbl_ViewVersions]
SET c2 = 't2'
WHERE c1 = 4;
GO

-- Now - let's see how the version is listed:

DBCC PAGE (ViewVersions, 1, 301, 3);
GO

-- Now, there's a pointer:
-- Version Information = 
--	 Transaction Timestamp: 924
--	 Version Pointer: (file 1 page 320 currentSlotId 0)

-- How about what's in the version store itself?
SELECT * FROM sys.dm_tran_active_snapshot_database_transactions;
SELECT * FROM sys.dm_tran_version_store;
GO

-- Let's make it so that the version is no longer required.
-- Go to 01_OpenTransaction.sql and rollback the tran

SELECT * FROM [dbo].[tbl_ViewVersions];
GO

-- Now, run and review these tables until that transaction / row
-- is gone:
SELECT * FROM sys.dm_tran_active_snapshot_database_transactions;
SELECT * FROM sys.dm_tran_version_store;
GO

-- Once that row is gone then the version has been cleaned up...

-- What's still left on the ROW? 

DBCC PAGE (ViewVersions, 1, 301, 3);
GO

-- The pointer is still there:
-- Version Information = 
--	 Transaction Timestamp: 924
--	 Version Pointer: (file 1 page 320 currentSlotId 0)

-- However, there are no transactions running with a timestamp earlier than 
-- 924 (which is why it was cleaned up). So, if a new query needs that row
-- they'll see (from the timestamp) that it's valid for them (since they
-- are newer any previous version wouldn't be applicable).