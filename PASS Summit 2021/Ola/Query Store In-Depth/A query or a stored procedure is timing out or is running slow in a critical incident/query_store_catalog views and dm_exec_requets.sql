-- You have the login name, host name and application name for a running query
-- Here is a script to find the query_id in Query Store

SELECT *
FROM sys.query_store_query
INNER JOIN sys.query_store_query_text ON sys.query_store_query.query_text_id = sys.query_store_query_text.query_text_id
WHERE EXISTS (SELECT *
              FROM sys.dm_exec_sessions
              INNER JOIN sys.dm_exec_requests ON sys.dm_exec_sessions.session_id = sys.dm_exec_requests.session_id
              WHERE sys.dm_exec_sessions.login_name = 'OLA\Ola Hallengren'
              AND sys.dm_exec_sessions.host_name = 'OLA'
              AND sys.dm_exec_sessions.program_name = 'OStress'
              AND sys.dm_exec_requests.statement_sql_handle = sys.query_store_query_text.statement_sql_handle
              AND sys.dm_exec_requests.statement_context_id = sys.query_store_query.context_settings_id)

