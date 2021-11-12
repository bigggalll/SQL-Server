CREATE EVENT SESSION [DYNAMICSPERF_LONG_DURATION] ON SERVER 
ADD EVENT sqlserver.rpc_completed(SET collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.context_info,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.transaction_sequence)
    WHERE ([duration]>=(3000000))),
ADD EVENT sqlserver.sp_statement_completed(SET collect_object_name=(1),collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.context_info,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.transaction_sequence)
    WHERE ([duration]>=(3000000))),
ADD EVENT sqlserver.sql_statement_completed(SET collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.context_info,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.transaction_sequence)
    WHERE ([package0].[greater_than_equal_int64]([duration],(3000000)))) 
ADD TARGET package0.event_file(SET filename=N'C:\SQLTrace\DYNAMICS_LONG_DURATION.xel',max_file_size=(10),max_rollover_files=(100))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO

ALTER EVENT SESSION  [DYNAMICSPERF_LONG_DURATION] ON SERVER 
 STATE=START

GO


