/*============================================================================
  File:     ShrinkFragmentationDemo.sql

  Summary:  This script shows how data file shrink can cause massive index
		fragmentation

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

SET NOCOUNT ON;
GO

-- Create the 10MB filler table at the
-- 'front' of the data file
CREATE TABLE [FillerTable] (
	[c1] INT IDENTITY,
	[c2] CHAR (8000) DEFAULT 'filler');
GO

-- Fill up the filler table
INSERT INTO [FillerTable] DEFAULT VALUES;
GO 1280

-- Create the production table, which will be 'after'
-- the filler table in the data file
CREATE TABLE [ProdTable] (
	[c1] INT IDENTITY,
	[c2] CHAR (8000) DEFAULT 'production');
CREATE CLUSTERED INDEX [prod_cl]
	ON [ProdTable] ([c1]);
GO

INSERT INTO [ProdTable] DEFAULT VALUES;
GO 1280

-- Check the fragmentation of the production table
SELECT
	[avg_fragmentation_in_percent]
FROM sys.dm_db_index_physical_stats (
	DB_ID (N'Company'),
	OBJECT_ID (N'ProdTable'),
	1,
	NULL,
	N'LIMITED');
GO

-- Drop the filler table, creating 10MB of free space
-- at the 'front' of the data file
DROP TABLE [FillerTable];
GO

-- Shrink the database
DBCC SHRINKDATABASE (N'Company');
GO

-- Check the index fragmentation again
SELECT
	[avg_fragmentation_in_percent]
FROM sys.dm_db_index_physical_stats (
	DB_ID ('Company'),
	OBJECT_ID ('ProdTable'),
	1,
	NULL,
	N'LIMITED');
GO
