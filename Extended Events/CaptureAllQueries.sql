IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='test_trace')
DROP EVENT SESSION [test_trace] ON SERVER;
CREATE EVENT SESSION [test_trace]
ON SERVER
ADD EVENT sqlserver.sql_statement_completed(
     ACTION (package0.callstack, sqlserver.session_id, sqlserver.sql_text)
     )
,
ADD EVENT sqlserver.sp_statement_completed(
     ACTION (package0.callstack, sqlserver.session_id, sqlserver.sql_text)
     )
ADD TARGET package0.asynchronous_file_target
(set filename = 'c:\temp\test_trace.xel' , metadatafile = 'c:\temp\test_trace.xem')
ALTER EVENT SESSION [test_trace] ON SERVER STATE = START

SELECT CONVERT (XML, event_data) AS data
        FROM sys.fn_xe_file_target_read_file ('C:\Temp\test_trace*.xel',
         'C:\Temp\test_trace*.xem', NULL, NULL)