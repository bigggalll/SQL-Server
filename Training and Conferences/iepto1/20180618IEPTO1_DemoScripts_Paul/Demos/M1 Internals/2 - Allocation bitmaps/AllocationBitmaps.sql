/*============================================================================
  File:     AllocationBitmaps.sql

  Summary:  This script uses DBCC PAGE to examine
			database-wide allocation bitmaps

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

-- Create a new table that will use disk
-- space quickly and extend the data file
CREATE TABLE [QuickTest] (
	[c1] INT IDENTITY,
	[c2] CHAR (8000) DEFAULT 'RandomValue');
GO

SET NOCOUNT ON;
GO

INSERT INTO [QuickTest] DEFAULT VALUES;
GO 100

-- Remember we need the trace flag
DBCC TRACEON (3604);
GO

-- PFS page
DBCC PAGE (N'Company', 1, 1, 3);
GO

-- GAM page
DBCC PAGE (N'Company', 1, 2, 3);
GO

-- SGAM page
DBCC PAGE (N'Company', 1, 3, 3);
GO

-- Look at the DIFF map
DBCC PAGE (N'Company', 1, 6, 3);
GO

-- Insert rows to use up some extents
INSERT INTO [QuickTest] DEFAULT VALUES;
GO 100

-- Look at the DIFF map again to see
-- some more extents marked as used
DBCC PAGE (N'Company', 1, 6, 3);
GO

-- Clear it with a full backup
BACKUP DATABASE [Company] TO
	DISK = N'D:\SQLskills\Company.bck'
	WITH INIT;
GO

-- And look again. Everything cleared?
DBCC PAGE (N'Company', 1, 6, 3);
GO

-- Look at the ML map
DBCC PAGE (N'Company', 1, 7, 3);
GO

-- Let's do a minimally-logged operation
-- Create an index, go into BULK_LOGGED
-- recovery mode and rebuild it
CREATE CLUSTERED INDEX [QT_CL] ON [QuickTest] ([c1]);
GO
ALTER DATABASE [Company] SET RECOVERY BULK_LOGGED;
GO
ALTER INDEX [QT_CL] ON [QuickTest] REBUILD;
GO

-- Now how does it look?
DBCC PAGE (N'Company', 1, 7, 3);
GO

-- Clear it using a log backup
ALTER DATABASE [Company] SET RECOVERY FULL;
GO
BACKUP LOG [Company]
	TO DISK = N'D:\SQLskills\Company_log.bck'
	WITH INIT;
GO

-- And look again
DBCC PAGE (N'Company', 1, 7, 3);
GO
