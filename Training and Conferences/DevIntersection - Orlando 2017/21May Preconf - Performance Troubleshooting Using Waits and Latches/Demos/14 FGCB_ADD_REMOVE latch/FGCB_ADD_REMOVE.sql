/*============================================================================
  File:     FGCB_ADD_REMOVE.sql

  Summary:  Investigate auto-growth

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

-- Now set up the demo by running the code in the
-- SetupWorkload.sql file

-- Clear waits in WaitStats1.sql
-- Clear latches in LatchStats.sql

-- Now start the workload by double-clicking the
-- file Add50Clients.cmd

-- Examine waiting tasks
-- Examine wait stats in WaitStats1.sql
-- What proportion are the LATCH_EX waits?
-- Examine latches in LatchStats.sql

-- Now stop the workload by double-clicking the
-- file StopWorkload.cmd

-- Now set up the demo again by running the code in the
-- SetupWorkload.sql file

-- Drop the session if it exists. 
IF EXISTS (
	SELECT * FROM sys.server_event_sessions
		WHERE [name] = N'FGCB_ADDREMOVE')
    DROP EVENT SESSION [FGCB_ADDREMOVE] ON SERVER
GO

CREATE EVENT SESSION [FGCB_ADDREMOVE] ON SERVER
ADD EVENT [sqlserver].[database_file_size_change]
	(WHERE [file_type] = 0), -- data files only
ADD EVENT [sqlserver].[latch_suspend_begin]
	(WHERE [class] = 48 AND [mode] = 4),  -- EX mode
ADD EVENT [sqlserver].[latch_suspend_end]
	(WHERE [class] = 48 AND [mode] = 4) -- EX mode
ADD TARGET [package0].[ring_buffer]
WITH (TRACK_CAUSALITY = ON);
GO

-- Start the event session
ALTER EVENT SESSION [FGCB_ADDREMOVE]
ON SERVER STATE = START;
GO

-- ** START WATCHING SESSION BEFORE WORKLOAD **

-- Now start the workload by double-clicking the
-- file C:\Pluralsight\Add50Clients.cmd

-- I could write code to view the Events, but
-- using SQL Server 2012/2014 SSMS is much better
-- in this case

-- Drill to the XEvent session, view live data
-- Add name, timestamp, attach_activity_id.guid,
-- database_id, file_name, duration, mode,
-- size_change_kb

-- Run for a bit then stop the session
-- Look at the pattern of latch acquires and growths
-- Explain why most growths don't incur a wait

-- Now stop the workload by double-clicking the
-- file StopWorkload.cmd

-- Clean up
ALTER EVENT SESSION [FGCB_ADDREMOVE]
ON SERVER STATE = STOP;
GO

IF EXISTS (
	SELECT * FROM sys.server_event_sessions
		WHERE [name] = N'FGCB_ADDREMOVE')
    DROP EVENT SESSION [FGCB_ADDREMOVE] ON SERVER
GO

USE [master];
GO

IF DATABASEPROPERTYEX (N'PageSplit', N'Version') > 0
BEGIN
	ALTER DATABASE [PageSplit] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [PageSplit];
END
GO