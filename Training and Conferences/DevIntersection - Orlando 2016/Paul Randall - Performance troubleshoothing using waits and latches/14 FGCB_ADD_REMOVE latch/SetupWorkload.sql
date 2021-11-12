/*============================================================================
  File:     SetupWorkload.sql

  Summary:  Create some auto-growth events

  SQL Server Versions: 2008 onwards
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

IF DATABASEPROPERTYEX (N'PageSplit', N'Version') > 0
BEGIN
	ALTER DATABASE [PageSplit] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [PageSplit];
END
GO

CREATE DATABASE [PageSplit] ON PRIMARY (
    NAME = N'PageSplit_data',
    FILENAME = N'D:\SQLskills\PageSplit_data.mdf',
    FILEGROWTH = 256KB)
LOG ON (
    NAME = N'PageSplit_log',
    FILENAME = N'C:\SQLskills\PageSplit_log.ldf',
    SIZE = 2MB,
    FILEGROWTH = 256KB);
GO

ALTER DATABASE [PageSplit] SET RECOVERY SIMPLE;
GO

USE [PageSplit];
GO

CREATE TABLE [PageSplitTable] (
	[c1] UNIQUEIDENTIFIER DEFAULT NEWID () ROWGUIDCOL,
	[c2] DATETIME DEFAULT GETDATE (),
	[c3] CHAR (400) DEFAULT 'a');
CREATE CLUSTERED INDEX [PageSplitTable_CL] ON
	[PageSplitTable] ([c1]);
GO