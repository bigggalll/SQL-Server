/*============================================================================
	File:     QueryPartition3.sql

	Summary:  Show how fast a query against the 3rd partition usually is

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

-- Simple select against partition 3
USE LockEscalationTest;
GO

-- This will fail if table-level lock escalation has
-- taken place
SELECT COUNT (*) FROM MyPartitionedTable
	WHERE c1 >= 16000;
GO

--SELECT *
--FROM MyPartitionedTable
--	WHERE c1 = 2000;


-- Check the locks being held...