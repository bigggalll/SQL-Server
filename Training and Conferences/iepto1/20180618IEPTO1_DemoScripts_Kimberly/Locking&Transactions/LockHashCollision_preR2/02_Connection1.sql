/*============================================================================
	File: Connection1.sql 

	Summary: These scripts show a bogus deadlock
	
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

USE LockResDemo;
GO

BEGIN TRAN;
GO

INSERT INTO LockResCheck
VALUES ('20090519', 3, 4245, 2651987);
GO

-- Now do the connection 2 inserts...

INSERT INTO LockResCheck
VALUES ('20090519', 3, 4657, 5744053);
GO

COMMIT TRAN;
GO

-- Get the deadlock information from the error log
exec xp_readerrorlog
go



SELECT db_name(5)
--5:72057594038845440 (0901a5c53568)
--DBID: 5
--HOBT_ID: 72057594038845440
--LOCK HASH ID: 0901a5c53568 

SELECT OBJECT_NAME(object_id) 
FROM sys.partitions 
WHERE hobt_id = 72057594038845440