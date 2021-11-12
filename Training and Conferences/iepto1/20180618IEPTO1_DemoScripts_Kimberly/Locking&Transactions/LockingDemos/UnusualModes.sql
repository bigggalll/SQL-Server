/*============================================================================
	File:     UnusualModes.sql

	Summary:  Show an SIX lock mode - unusual

  SQL Server Versions: 2008 onwards
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

USE JunkDB;
GO

-- SIX mode
CREATE TABLE t1 (c1 int);
INSERT INTO t1 VALUES (1);
GO

BEGIN TRAN
SELECT * FROM t1 WITH (PAGLOCK, HOLDLOCK);
GO

SELECT * FROM sys.dm_tran_locks
WHERE [resource_type] <> 'DATABASE'
AND request_session_id = @@spid;
GO

-- IS table lock. Now make it SIX

UPDATE t1 set c1 = 2;
GO

SELECT * FROM sys.dm_tran_locks
WHERE [resource_type] <> 'DATABASE';
GO

ROLLBACK TRAN;
GO