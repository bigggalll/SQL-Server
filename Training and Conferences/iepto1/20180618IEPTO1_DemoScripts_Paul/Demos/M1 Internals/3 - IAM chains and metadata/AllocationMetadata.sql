/*============================================================================
  File:     AllocationMetadata.sql

  Summary:  This script examines system catalogs

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

-- Grab the various IDs
EXEC sp_AllocationMetadata N'SimpleTable';
GO

DBCC TRACEON (3604);
DBCC PAGE (N'Company', 1, xx, 3);
GO

** PASTE HERE **

-- Examine system catalogs
USE [Company];
GO
SELECT * FROM sys.sysallocunits;
GO

-- Can also use the documented view
SELECT * FROM sys.system_internals_allocation_units;
GO

SELECT * FROM sys.sysrowsets;
GO

SELECT * FROM sys.sysrscols;
GO