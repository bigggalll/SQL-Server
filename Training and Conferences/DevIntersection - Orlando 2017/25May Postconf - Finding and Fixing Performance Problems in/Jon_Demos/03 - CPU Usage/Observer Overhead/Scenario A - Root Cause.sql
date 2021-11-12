CREATE EVENT SESSION [ApplicationXYZ] ON SERVER 
ADD EVENT sqlserver.query_post_execution_showplan,
ADD EVENT sqlserver.query_pre_execution_showplan,
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(package0.callstack,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(package0.callstack,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlserver.tsql_stack)),
ADD EVENT sqlserver.inaccurate_cardinality_estimate
ADD TARGET package0.ring_buffer(SET max_events_limit=(1000))
WITH (STARTUP_STATE=ON)
GO

ALTER EVENT SESSION [ApplicationXYZ] ON SERVER STATE=START;
GO
