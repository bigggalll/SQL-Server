/*============================================================================
  File:     Query dm_tran_locks.sql

  Summary:  This is just a simple little query to start querying the
            locks aquired. 
  
  SQL Server Version: 2008
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

select *
--OBJECT_NAME(convert(int, resource_associated_entity_id)), *
from sys.dm_tran_locks as l 
where l.resource_database_id = db_id()
	and l.request_session_id = 61 --<spid of other session>
go
select object_name(1541580530)

-- Quick and easy
exec sp_lock @@spid -- this spid's locks
go

-- Detect blocking? This is from Glenn Berry's "Diagnostic Information Queries"
-- Here's the post: http://sqlserverperformance.wordpress.com/2010/11/14/sql-server-2005-diagnostic-information-queries-november-2010/

-- Detect blocking (run multiple times)
SELECT t1.resource_type AS [lock type]
    , DB_NAME(resource_database_id) AS [database]
    , t1.resource_associated_entity_id AS [blk object]
    , t1.request_mode AS [lock req] --- lock requested
    , t1.request_session_id AS [waiter sid]
    , t2.wait_duration_ms AS [wait time] -- spid of waiter
    , (SELECT [text] 
         FROM sys.dm_exec_requests AS r                                    
              CROSS APPLY sys.dm_exec_sql_text(r.[sql_handle])
         WHERE r.session_id = t1.request_session_id) AS [waiter_batch] -- get sql for waiter
    , (SELECT SUBSTRING(qt.[text],r.statement_start_offset/2,
               (CASE WHEN r.statement_end_offset = -1
        THEN LEN(CONVERT(nvarchar(max), qt.[text])) * 2
            ELSE r.statement_end_offset END - r.statement_start_offset)/2)
        FROM sys.dm_exec_requests AS r
            CROSS APPLY sys.dm_exec_sql_text(r.[sql_handle]) AS qt
        WHERE r.session_id = t1.request_session_id) AS [waiter_stmt] -- statement blocked
    , t2.blocking_session_id AS [blocker sid]  -- spid of blocker
    , (SELECT [text] 
       FROM sys.sysprocesses AS p                        
        CROSS APPLY sys.dm_exec_sql_text(p.[sql_handle])
       WHERE p.spid = t2.blocking_session_id) AS [blocker_stmt] -- get sql for blocker
FROM sys.dm_tran_locks AS t1
    INNER JOIN sys.dm_os_waiting_tasks AS t2
ON t1.lock_owner_address = t2.resource_address;

-- Finally, Kendra Little has a good page with all sorts of resource links for locking and 
-- isolation levels here: http://www.littlekendra.com/resources/isolation/