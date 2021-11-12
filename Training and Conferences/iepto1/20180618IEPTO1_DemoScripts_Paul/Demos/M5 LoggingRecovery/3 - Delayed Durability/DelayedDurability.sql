/*============================================================================
  File:     DelayedDurability.sql

  Summary:  Demonstrate delayed durability

  SQL Server Versions: 2014 onwards
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

IF DATABASEPROPERTYEX (N'FastLogFile', N'Version') > 0
BEGIN
	ALTER DATABASE [FastLogFile] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [FastLogFile];
END
GO

CREATE DATABASE [FastLogFile] ON PRIMARY (
    NAME = N'FastLogFile_data',
    FILENAME = N'D:\SQLskills\FastLogFile_data.mdf')
LOG ON (
    NAME = N'FastLogFile_log',
    FILENAME = N'C:\SQLskills\FastLogFile_log.ldf',
    SIZE = 64MB,
    FILEGROWTH = 16MB);
GO

ALTER DATABASE [FastLogFile] SET RECOVERY SIMPLE;
ALTER DATABASE [FastLogFile] SET DELAYED_DURABILITY = DISABLED;
GO

USE [FastLogFile];
GO

CREATE TABLE RandomData (
	[c1] INT,
	[c2] INT,
    [c3] DATETIME,
	[c4] CHAR (100));
CREATE CLUSTERED INDEX [RandomData_CL] ON
	[RandomData] ([c2]);
GO

INSERT INTO [RandomData] VALUES (1, 1, GETDATE (), 'a');
INSERT INTO [RandomData] VALUES (2, 2, GETDATE (), 'b');
INSERT INTO [RandomData] VALUES (3, 3, GETDATE (), 'c');
INSERT INTO [RandomData] VALUES (4, 4, GETDATE (), 'd');
INSERT INTO [RandomData] VALUES (5, 5, GETDATE (), 'e');
INSERT INTO [RandomData] VALUES (6, 6, GETDATE (), 'f');
INSERT INTO [RandomData] VALUES (7, 7, GETDATE (), 'g');
INSERT INTO [RandomData] VALUES (8, 8, GETDATE (), 'h');
INSERT INTO [RandomData] VALUES (9, 9, GETDATE (), 'i');
GO

-- Fire up 50 clients and watch log flushes per sec
-- and transactions per sec

-- Change log flushing

ALTER DATABASE [FastLogFile] SET DELAYED_DURABILITY = FORCED;
GO

-- and watch difference!