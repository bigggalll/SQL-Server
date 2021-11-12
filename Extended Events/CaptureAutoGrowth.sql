USE [master]
GO 
SET NOCOUNT ON 
/* Create Extended Events Session */
IF EXISTS (SELECT 1 FROM master.sys.server_event_sessions WHERE name = 'DemoFileSize')
 DROP EVENT SESSION [DemoFileSize] ON SERVER
GO
CREATE EVENT SESSION [DemoFileSize] ON SERVER
ADD EVENT sqlserver.database_file_size_change(SET collect_database_name=(1)
    ACTION(package0.collect_system_time,sqlos.task_time,
 sqlserver.client_app_name,sqlserver.client_hostname,
 sqlserver.client_pid,sqlserver.database_id,sqlserver.database_name,
 sqlserver.server_instance_name,sqlserver.session_id,
 sqlserver.sql_text,sqlserver.username)),
 /* Note - no predicate/filter - will collect *all* DATA file size changes */
ADD EVENT sqlserver.databases_log_file_size_changed(
    ACTION(package0.collect_system_time,sqlos.task_time,
 sqlserver.client_app_name,sqlserver.client_hostname,
 sqlserver.client_pid,sqlserver.database_id,sqlserver.database_name,
 sqlserver.server_instance_name,sqlserver.session_id,
 sqlserver.sql_text,sqlserver.username))
 /* Note - no predicate/filter - will collect *all* LOG file size changes */
ADD TARGET package0.event_file(SET filename=N'c:\XE\DemoFileSize.xel',
 max_file_size=(500),max_rollover_files=(10))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
 MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,
 MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO

ALTER EVENT SESSION [DemoFileSize] ON SERVER
STATE = START;
GO
