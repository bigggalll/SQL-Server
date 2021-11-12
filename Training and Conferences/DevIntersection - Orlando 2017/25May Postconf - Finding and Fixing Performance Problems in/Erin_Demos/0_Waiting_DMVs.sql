/*============================================================================
  File:    0_Waiting_DMVs.sql

  Summary:  Snapshot of wait stats

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com

  (c) 2017, SQLskills.com. All rights reserved.

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

/*
	what is running or waiting RIGHT NOW?
*/
SELECT *
FROM sys.dm_os_waiting_tasks


/*
	what have we been waiting on?
*/
SELECT *
FROM sys.dm_os_wait_stats