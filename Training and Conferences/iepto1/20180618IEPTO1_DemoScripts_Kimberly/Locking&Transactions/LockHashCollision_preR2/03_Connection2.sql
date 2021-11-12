/*============================================================================
	File: Connection2.sql 

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
VALUES ('20090519', 2, 4271, 5835066);
GO

INSERT INTO LockResCheck
VALUES ('20090519', 2, 4619, 2546652);
GO

-- Execute to here

COMMIT TRAN;
GO
