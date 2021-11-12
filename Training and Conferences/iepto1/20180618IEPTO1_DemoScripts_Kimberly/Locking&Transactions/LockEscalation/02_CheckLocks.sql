/*============================================================================
	File:     CheckLocks.sql

	Summary:  Examine which locks are being held

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

USE [LockEscalationTest];
GO

-- Check the lock escalation setting
SELECT * FROM sys.tables 
WHERE object_id =
	OBJECT_ID ('MyPartitionedTable');
GO

-- Check the partition_id (this is what can be locked 
-- [shows as a HoBT] with partion-level locking)
SELECT * FROM sys.partitions 
WHERE object_id =
	OBJECT_ID ('MyPartitionedTable');
GO

-- Check the locks being held
--sp_lock @@spid
EXEC sp_lock 51;
GO

SELECT o.type_desc, l.* 
FROM sys.dm_tran_locks AS l
	LEFT JOIN sys.objects AS o
		ON l.resource_associated_entity_id = o.object_id
WHERE 1=1
    AND request_session_id = 51
	--AND [request_status] = 'WAIT'
	--AND [resource_type] = 'KEY'
    AND [resource_type] NOT IN ('DATABASE','KEY')
    AND [resource_type] NOT IN ('DATABASE')
    --AND [resource_type] = ('database')
    --AND resource_database_id = DB_ID('LockEscalationTest')
--AND request_mode = 'X';
GO

SELECT resource_associated_entity_id, COUNT(*) 
FROM sys.dm_tran_locks
WHERE [resource_type] <> 'DATABASE'
GROUP BY resource_associated_entity_id
go

EXEC sp_whoisactive;	-- Adam Machanic's free resource at http://whoisactive.com
EXEC sp_blocker_pss08;  -- Old KB 271509 at https://support.microsoft.com/en-us/help/271509/how-to-monitor-blocking-in-sql-server-2005-and-in-sql-server-2000

-----------------------------------------------
-- A bit more lock info + object types
-----------------------------------------------

-- From Jonathan Kehayias

select dm_tran_locks.request_session_id, 
            dm_tran_locks.resource_database_id,
            db_name(dm_tran_locks.resource_database_id) as dbname,
            CASE 
                  WHEN resource_type = 'object'
                        THEN object_name(dm_tran_locks.resource_associated_entity_id)
                  ELSE object_name(partitions.object_id)
            END as ObjectName,
            partitions.index_id,
            indexes.name as index_name,
            dm_tran_locks.resource_type, 
            dm_tran_locks.resource_description, 
            dm_tran_locks.resource_associated_entity_id, 
            dm_tran_locks.request_mode, 
            dm_tran_locks.request_status
from sys.dm_tran_locks
left join sys.partitions 
	on partitions.hobt_id = dm_tran_locks.resource_associated_entity_id
left join sys.indexes 
	on indexes.object_id = partitions.object_id 
		and indexes.index_id = partitions.index_id
where resource_associated_entity_id > 0
  and resource_database_id = db_id()
order by request_session_id, resource_associated_entity_id