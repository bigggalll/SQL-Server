/**********************************************************************************************

RUN this script on EACH SERVER that you want to monitor blocking and performance against.  

If DynmaicsPerf is installed remotely, it is NOT necessary to run this script on the DynamicsPerf 
server.  

**********************************************************************************************/





--  NOTE: YOU MUST CREATE A C:\SQLTRACE FOLDER ON THE SERVER TO BE MONITORED or modify this script






USE [master]
GO





sp_configure 'Show Advanced Options', 1
RECONFIGURE WITH OVERRIDE

GO

sp_configure 'blocked process threshold', 2
RECONFIGURE WITH OVERRIDE


GO

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='DYNPERF_BLOCKING_DATA')
DROP EVENT SESSION DYNPERF_BLOCKING_DATA ON SERVER
 GO

CREATE EVENT SESSION [DYNPERF_BLOCKING_DATA] ON SERVER 
ADD EVENT sqlserver.blocked_process_report(
    ACTION(package0.collect_system_time,sqlserver.client_hostname,sqlserver.context_info)),
ADD EVENT sqlserver.xml_deadlock_report(
    ACTION(package0.collect_system_time,sqlserver.client_hostname,sqlserver.context_info)),
ADD EVENT sqlserver.lock_escalation(
    ACTION(package0.collect_system_time,sqlserver.client_hostname,sqlserver.context_info)) 
ADD TARGET package0.event_file(SET filename=N'C:\SQLTrace\DYNAMICS_BLOCKING.xel',max_file_size=(10),max_rollover_files=(100))
--,ADD TARGET package0.ring_buffer(SET max_memory=(131072))
WITH (MAX_MEMORY=4096 KB,MAX_DISPATCH_LATENCY=5 SECONDS,MEMORY_PARTITION_MODE=PER_NODE,TRACK_CAUSALITY=ON,STARTUP_STATE=ON)
GO

ALTER EVENT SESSION [DYNPERF_BLOCKING_DATA] ON SERVER 
 STATE=START

GO

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='DYNPERF_LONG_DURATION')
DROP EVENT SESSION DYNPERF_LONG_DURATION ON SERVER
 GO
 
 CREATE EVENT SESSION DYNPERF_LONG_DURATION ON SERVER 
ADD EVENT sqlserver.rpc_completed(SET collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.context_info,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.transaction_sequence)
    WHERE ([duration]>=(2000000))),
ADD EVENT sqlserver.sp_statement_completed(SET collect_object_name=(1),collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.context_info,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.transaction_sequence)
    WHERE ([duration]>=(2000000))),
ADD EVENT sqlserver.sql_statement_completed(SET collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.context_info,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.transaction_sequence)
    WHERE ([package0].[greater_than_equal_int64]([duration],(2000000)))) 
ADD TARGET package0.event_file(SET filename=N'C:\SQLTrace\DYNAMICS_LONG_DURATION.xel',max_file_size=(10),max_rollover_files=(100))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=5 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=PER_NODE,TRACK_CAUSALITY=ON,STARTUP_STATE=ON)
GO




ALTER EVENT SESSION [DYNPERF_LONG_DURATION] ON SERVER 
 STATE=START

GO

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='DYNPERF_PERF_MONITOR')
DROP EVENT SESSION DYNPERF_PERF_MONITOR ON SERVER
 GO


CREATE EVENT SESSION [DYNPERF_PERF_MONITOR] ON SERVER 
ADD EVENT sqlserver.databases_data_file_size_changed(
    ACTION(package0.collect_system_time,sqlserver.database_name)),
ADD EVENT sqlserver.databases_log_growth(
    ACTION(package0.collect_system_time,sqlserver.database_name)),
ADD EVENT sqlserver.databases_log_shrink(
    ACTION(package0.collect_system_time,sqlserver.database_name)),
ADD EVENT sqlserver.full_text_crawl_started(SET collect_database_name=(1)
    ACTION(package0.collect_system_time,sqlserver.database_name)),
ADD EVENT sqlserver.full_text_crawl_stopped(SET collect_database_name=(1)
    ACTION(package0.collect_system_time,sqlserver.database_name)) 
ADD TARGET package0.event_file(SET filename=N'C:\SQLTrace\DYNPERF_MISC.xel',max_file_size=(10),max_rollover_files=(100))
--,ADD TARGET package0.ring_buffer(SET max_memory=(131072))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_MULTIPLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=5 SECONDS,MEMORY_PARTITION_MODE=PER_NODE,TRACK_CAUSALITY=ON,STARTUP_STATE=ON)
GO

ALTER EVENT SESSION [DYNPERF_PERF_MONITOR] ON SERVER 
 STATE=START

GO


/*

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='DYNPERF_AX_CONTEXTINFO')
DROP EVENT SESSION DYNPERF_AX_CONTEXTINFO ON SERVER
 GO

CREATE EVENT SESSION [DYNPERF_AX_CONTEXTINFO] ON SERVER 
ADD EVENT sqlserver.sql_statement_completed(SET collect_statement=(1)
    ACTION(sqlserver.session_id)
    WHERE ([sqlserver].[like_i_sql_unicode_string]([sqlserver].[sql_text],N'%select @CONTEXT_INFO =%'))) 
ADD TARGET package0.event_file(SET filename=N'C:\SQLTrace\DYNPERF_AX_CONTEXTINFO.xel',max_file_size=(10),max_rollover_files=(100))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_MULTIPLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=5 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO

ALTER EVENT SESSION [DYNPERF_AX_CONTEXTINFO] ON SERVER 
 STATE=START
 



 */
 
 