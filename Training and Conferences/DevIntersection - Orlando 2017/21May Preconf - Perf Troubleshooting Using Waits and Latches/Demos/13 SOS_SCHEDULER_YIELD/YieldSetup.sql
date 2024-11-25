/*============================================================================
  File:     YieldSetup.sql

  Summary:  Create some SOS_SCHEDULER_YIELD waits

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

IF DATABASEPROPERTYEX (N'YieldTest', N'Version') > 0
BEGIN
	ALTER DATABASE [YieldTest] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [YieldTest];
END
GO

CREATE DATABASE [YieldTest];
GO

USE [YieldTest];
GO

CREATE TABLE [SampleTable] (
	[c1] INT IDENTITY);
GO
CREATE NONCLUSTERED INDEX [SampleTable_NC]
ON [SampleTable] ([c1]);
GO

SET NOCOUNT ON;
GO
INSERT INTO [SampleTable] DEFAULT VALUES;
GO 100

-- DEMO
-- Run Add8Clients.cmd, note signal wait time
-- Run Add16Clients.cmd, note signal wait time
-- Run Add24Clients.cmd, note signal wait time
-- Add Perfmon: AccessMethods: Index Searches/sec
-- Investigate spinlocks
-- Change to use WITH NOLOCK
-- Rerun, see change in perfmon
