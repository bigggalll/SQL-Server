/*============================================================================
  File:     HotSpotSetup.sql

  Summary:  Create some nasty lock waits

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  (c) 2016, SQLskills.com. All rights reserved.

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

-- Let's create a hotspot to watch

USE [master];
GO

IF DATABASEPROPERTYEX (N'HotSpot', N'Version') > 0
BEGIN
	ALTER DATABASE [HotSpot] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [HotSpot];
END
GO

CREATE DATABASE [HotSpot] ON PRIMARY (
    NAME = N'HotSpot_data',
    FILENAME = N'D:\SQLskills\HotSpot_data.mdf')
LOG ON (
    NAME = N'HotSpot_log',
    FILENAME = N'C:\SQLskills\HotSpot_log.ldf',
    SIZE = 256MB,
    FILEGROWTH = 64MB);
GO

ALTER DATABASE [HotSpot] SET RECOVERY SIMPLE;
GO

USE [HotSpot];
GO

CREATE TABLE [HotSpotTable] (
	[c1] INT IDENTITY);
CREATE CLUSTERED INDEX [HotSpotTable_CL] ON
	[HotSpotTable] ([c1]);
GO

-- Now start 200 threads....

-- And look at the waiting tasks and waits


-- Now do this...
ALTER INDEX [HotSpotTable_CL] ON [HotSpotTable] SET (ALLOW_ROW_LOCKS=OFF);
GO

-- And reset wait stats in a new window and look again
