SELECT session_id, blocking_session_id, wait_type, wait_time, wait_resource
FROM sys.dm_exec_requests
WHERE session_id > 50;
