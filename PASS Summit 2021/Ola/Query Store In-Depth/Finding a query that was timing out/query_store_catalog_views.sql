
-- Look at the sessions / requests
-- Get the statement_sql_handle and statement_conext_id from sys.dm_exec_requests
SELECT *
FROM DBA.dbo.dm_exec_sessions dm_exec_sessions
INNER JOIN DBA.dbo.dm_exec_requests dm_exec_requests ON dm_exec_sessions.snapshot_timestamp = dm_exec_requests.snapshot_timestamp AND dm_exec_sessions.session_id = dm_exec_requests.session_id
WHERE dm_exec_sessions.login_name = 'OLA\Ola Hallengren'
AND dm_exec_sessions.host_name = 'OLA'
AND dm_exec_sessions.program_name LIKE 'Microsoft SQL Server Management Studio - Query%'
AND dm_exec_sessions.snapshot_timestamp >= DATEADD(MINUTE,-1,SYSDATETIME())

-- Find the query_id in sys.query_store_query
SELECT *
FROM sys.query_store_query
INNER JOIN sys.query_store_query_text ON sys.query_store_query.query_text_id = sys.query_store_query_text.query_text_id
WHERE sys.query_store_query_text.statement_sql_handle = 0x0900C0E8F26BF59CC7E153BC86BF4BC082AE0000000000000000000000000000000000000000000000000000
AND sys.query_store_query.context_settings_id = 8

-- Look at the plans
SELECT sys.query_store_plan.*, CAST(query_plan AS xml) AS query_plan_xml
FROM sys.query_store_plan
WHERE query_id = 1 -- Replace the query_id here
ORDER BY plan_id ASC

-- Look at the runtime statistics
SELECT sys.query_store_runtime_stats.*
FROM sys.query_store_runtime_stats
INNER JOIN sys.query_store_plan ON sys.query_store_runtime_stats.plan_id = sys.query_store_plan.plan_id
WHERE query_id = 1 -- Replace the query_id here
ORDER BY runtime_stats_id ASC

-- Look at the wait statistics
SELECT sys.query_store_wait_stats.*
FROM sys.query_store_wait_stats
INNER JOIN sys.query_store_plan ON sys.query_store_wait_stats.plan_id = sys.query_store_plan.plan_id
WHERE query_id = 1 -- Replace the query_id here
ORDER BY wait_stats_id ASC