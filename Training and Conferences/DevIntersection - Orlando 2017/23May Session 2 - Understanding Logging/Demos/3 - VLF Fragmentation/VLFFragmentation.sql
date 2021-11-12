/*============================================================================
  File:     VLFFragmentation.sql

  Summary:  This script shows how to see VLF
			fragmentation and remove it.

			Note: The run-away log file demo
			should be run first

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  (c) 2013, SQLskills.com. All rights reserved.

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

USE [DBMaint2008];
GO

-- How many VLFs do we have?
DBCC LOGINFO (N'DBMaint2008');
GO

-- Shrink the log
DBCC SHRINKFILE (2);
GO

-- Backup the log again to enable
-- freeing more space
BACKUP LOG [DBMaint2008] TO
	DISK = N'C:\SQLskills\DBMaint2008_log.bck'
	WITH STATS;
GO

-- Shrink the log again.. this time
-- it goes way down
DBCC SHRINKFILE (2);
GO

-- Now grow it manually and set auto growth
ALTER DATABASE [DBMaint2008]
	MODIFY FILE (
		NAME = N'DBMaint2008_Log',
		SIZE = 100MB,
		FILEGROWTH = 20MB);
GO
-- Check perfmon

-- And check VLFs again
DBCC LOGINFO (N'DBMaint2008');
GO