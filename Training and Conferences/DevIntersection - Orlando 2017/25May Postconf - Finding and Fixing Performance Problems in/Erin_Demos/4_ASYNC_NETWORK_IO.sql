/*============================================================================
  File:     4_ASYNC_NETWORK_IO.sql

  Summary:  Show ASYNC_NETWORK_IO waits

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

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

-- Very simple...
-- Clear waits...

DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR);

SELECT * FROM AdventureWorks2016E.Sales.SalesOrderDetailEnlarged;
GO

-- Check waits