-- You have identified the query_id that is consuming most of the resources in a database
-- How do you find the user and application that is executing it?

SELECT sys.dm_exec_sessions.*
FROM sys.dm_exec_sessions
INNER JOIN sys.dm_exec_requests ON sys.dm_exec_sessions.session_id = sys.dm_exec_requests.session_id
WHERE EXISTS (SELECT *
              FROM sys.query_store_query
              INNER JOIN sys.query_store_query_text ON sys.query_store_query.query_text_id = sys.query_store_query_text.query_text_id
              WHERE sys.query_store_query.query_id = 5
              AND sys.query_store_query_text.statement_sql_handle = sys.dm_exec_requests.statement_sql_handle
              AND sys.query_store_query.context_settings_id = sys.dm_exec_requests.statement_context_id)

