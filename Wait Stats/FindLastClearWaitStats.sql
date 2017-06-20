/* when were wait stats last cleared? */
SELECT
[wait_type],
[wait_time_ms],
DATEADD(ms,-[wait_time_ms],getdate()) AS [Date/TimeCleared],
CASE
WHEN [wait_time_ms] < 1000 THEN CAST([wait_time_ms] AS VARCHAR(15)) + ' ms'
WHEN [wait_time_ms] between 1000 and 60000 THEN CAST(([wait_time_ms]/1000) AS VARCHAR(15)) + ' seconds'
WHEN [wait_time_ms] BETWEEN 60001 and 3600000 THEN CAST(([wait_time_ms]/60000) AS VARCHAR(15)) + ' minutes'
WHEN [wait_time_ms] between 3600001 and 86400000 THEN CAST(([wait_time_ms]/3600000) AS VARCHAR(15)) + ' hours'
WHEN [wait_time_ms] > 86400000 THEN CAST(([wait_time_ms]/86400000) AS VARCHAR(15)) + ' days'
END [TimeSinceCleared]
FROM [sys].[dm_os_wait_stats]
WHERE [wait_type] = 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP';
 
/* check SQL Server start time - 2008 and higher */
SELECT
[sqlserver_start_time]
FROM [sys].[dm_os_sys_info];