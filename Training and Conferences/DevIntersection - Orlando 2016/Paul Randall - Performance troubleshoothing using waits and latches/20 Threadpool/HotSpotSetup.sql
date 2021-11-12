/*============================================================================
  File:     HotSpotSetup.sql

  Summary:  Create some nasty threadpool waits

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

EXEC sys.sp_configure N'show advanced options', N'1';
RECONFIGURE WITH OVERRIDE;
GO
EXEC sys.sp_configure N'max worker threads', N'128';
RECONFIGURE
GO

-- Start up 200 connections

-- Connect using DAC

SELECT * FROM sys.dm_exec_requests
WHERE [sql_handle] IS NOT NULL;
GO

SELECT * FROM sys.dm_os_waiting_tasks
WHERE [wait_type] = 'THREADPOOL';
GO

-- Make sure to cleanup
EXEC sys.sp_configure N'max worker threads', N'0';
EXEC sys.sp_configure N'show advanced options', N'0';
RECONFIGURE WITH OVERRIDE;
GO
