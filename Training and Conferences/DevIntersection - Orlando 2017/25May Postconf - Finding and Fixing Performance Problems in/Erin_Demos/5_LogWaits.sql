/*============================================================================
  File:     5_LogWaits.sql

  Summary:  Create some nasty log waits

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

-- Let's create a slow drive.. using a USB stick

USE [master];
GO

IF DATABASEPROPERTYEX (N'SlowLogFile', N'Version') > 0
BEGIN
	ALTER DATABASE [SlowLogFile] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [SlowLogFile];
END
GO

CREATE DATABASE [SlowLogFile] ON PRIMARY (
    NAME = N'SlowLogFile_data',
    FILENAME = N'C:\Databases\SlowLogFile\SlowLogFile_data.mdf')
LOG ON (
    NAME = N'SlowLogFile_log',
    FILENAME = N'E:\SlowLogFile\SlowLogFile_log.ldf',
    --FILENAME = N'C:\Databases\SlowLogFile\SlowLogFile_log.ldf',
    SIZE = 5MB,
    FILEGROWTH = 1MB);
GO

ALTER DATABASE [SlowLogFile] SET RECOVERY SIMPLE;
GO

USE [SlowLogFile];
GO

CREATE TABLE BadKeyTable (
	[c1] UNIQUEIDENTIFIER DEFAULT NEWID () ROWGUIDCOL,
--	[c1] UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID () ROWGUIDCOL,
    [c2] DATETIME DEFAULT GETDATE (),
	[c3] CHAR (400) DEFAULT 'a');
CREATE CLUSTERED INDEX [BadKeyTable_CL] ON
	[BadKeyTable] ([c1]);
CREATE NONCLUSTERED INDEX [BadKeyTable_NCL] ON
	[BadKeyTable] ([c2]);
GO


-- Fire up 200 clients and watch waits...

-- Stop test
-- Then replace G: with C:
-- Fire up 200 clients and look at wait stats

-- Stop test
-- Then replace NEWID with NEWSEQUENTIALID
-- Fire up 200 clients and look at wait stats
