CREATE EVENT SESSION [KimberlyLocks] ON SERVER 
ADD EVENT sqlserver.lock_acquired(
    ACTION(sqlserver.request_id,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.lock_released(
    ACTION(sqlserver.request_id,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([sqlserver].[is_system]=(0))) 
ADD TARGET package0.event_file(SET filename=N'D:\temp\XE_locks.xel')
WITH (MAX_DISPATCH_LATENCY=1 SECONDS)
GO
