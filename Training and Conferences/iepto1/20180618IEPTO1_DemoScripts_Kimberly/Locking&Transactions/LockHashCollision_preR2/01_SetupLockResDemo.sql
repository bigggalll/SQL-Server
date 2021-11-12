/*============================================================================
	File: SetupLockResDemo.sql 

	Summary: These scripts show a bogus deadlock
	
	Read instructions.txt
	
	Based on an example from James Rowland-Jones
	http://blogs.conchango.com/jamesrowlandjones/archive/2009/05/28/the-curious-case-of-the-dubious-deadlock-and-the-not-so-logical-lock.aspx 

  SQL Server Versions: 2008 only
------------------------------------------------------------------------------
  (c) 2011, SQLskills.com. All rights reserved.

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

USE master;
GO

IF DATABASEPROPERTYEX ('LockResDemo', 'Version') > 0
	DROP DATABASE LockResDemo;
GO

CREATE DATABASE LockResDemo;
GO

USE LockResDemo;
GO

CREATE TABLE LockResCheck (
	[Date]		DATETIME,
	CountryID	TINYINT,
	GroupID		SMALLINT,
	CodeID		INT);
GO

CREATE UNIQUE CLUSTERED INDEX LockResCheck_PK 
ON LockResCheck ([date], 
    CountryID, GroupID, CodeID);
GO

DBCC TRACEON (1222, -1);
GO

SP_CYCLE_ERRORLOG;
GO

-- fyi - there's also an SP_CYCLE_AGENT_ERRORLOG;
GO
