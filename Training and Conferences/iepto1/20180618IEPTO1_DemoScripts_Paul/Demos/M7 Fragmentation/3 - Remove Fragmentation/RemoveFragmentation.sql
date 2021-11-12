/*============================================================================
  File:     RemoveFragmentation.sql

  Summary:  This script shows how to remove fragmentation

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  (c) 2018, SQLskills.com. All rights reserved.

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

USE [GUIDTest];
GO

-- Look at the fragmentation again
SELECT
	OBJECT_NAME ([ips].[object_id]) AS [Object Name],
	[si].[name] AS [Index Name],
	ROUND ([ips].[avg_fragmentation_in_percent], 2) AS [Fragmentation],
	[ips].[page_count] AS [Pages],
	ROUND ([ips].[avg_page_space_used_in_percent], 2) AS [Page Density]
FROM sys.dm_db_index_physical_stats (
	DB_ID (N'GUIDTest'),
	NULL,
	NULL,
	NULL,
	N'DETAILED') [ips]
CROSS APPLY [sys].[indexes] [si]
WHERE
	[si].[object_id] = [ips].[object_id]
	AND [si].[index_id] = [ips].[index_id]
	AND [ips].[index_level] = 0
GO

-- Online rebuild the clustered index
-- Works on 2012
ALTER INDEX [BadKeyTable_CL]
ON [BadKeyTable] REBUILD
WITH (ONLINE = ON, FILLFACTOR = 70);
GO

-- On 2008/2008 R2: Ok - offline then
ALTER INDEX [BadKeyTable_CL]
ON [BadKeyTable] REBUILD
WITH (FILLFACTOR = 70);
GO

-- Reorganize the non-clustered index
ALTER INDEX [BadKeyTable_NCL]
ON [BadKeyTable] REORGANIZE;
GO

-- And check again...

-- Now rebuild the non-clustered index
ALTER INDEX [BadKeyTable_NCL]
ON [BadKeyTable] REBUILD
WITH (ONLINE = ON, FILLFACTOR = 70);
GO

-- And check again...

-- Run the OtherQuery.sql script

-- Now try this
ALTER INDEX [BadKeyTable_CL] ON [BadKeyTable] REBUILD
WITH (FILLFACTOR = 70, ONLINE = ON);
GO

-- It will wait forever. Kill that ALTER INDEX.

-- Try this...
-- Options are NONE, SELF, BLOCKERS
ALTER INDEX [BadKeyTable_CL] ON [BadKeyTable] REBUILD
WITH (FILLFACTOR = 70, ONLINE = ON (
	WAIT_AT_LOW_PRIORITY (
		MAX_DURATION = 1 MINUTES, ABORT_AFTER_WAIT = SELF)
	)
) ;
GO

-- Now try this, with the other transaction still running
-- Options are NONE, SELF, BLOCKERS
ALTER INDEX [BadKeyTable_CL] ON [BadKeyTable] REBUILD
WITH (FILLFACTOR = 70, ONLINE = ON (
	WAIT_AT_LOW_PRIORITY (
		MAX_DURATION = 1 MINUTES, ABORT_AFTER_WAIT = BLOCKERS)
	)
) ;
GO