IF OBJECT_ID('tempdb..#des1') IS NOT NULL
    DROP TABLE #des1;

SELECT *
INTO #des1
FROM sys.dm_exec_requests;

WAITFOR DELAY '00:00:05';

IF OBJECT_ID('tempdb..#des2') IS NOT NULL
    DROP TABLE #des2;

SELECT *
INTO #des2
FROM sys.dm_exec_requests;

SELECT #des2.cpu_time - #des1.cpu_time cpu_time_ms,
       #des1.session_id
FROM #des1
     LEFT OUTER JOIN #des2 ON #des1.session_id = #des2.session_id
     CROSS APPLY sys.dm_exec_sql_text(#des1.sql_handle)
ORDER BY 1 DESC;

SELECT *
FROM sys.dm_exec_requests;

SELECT SUM(cpu_time),
       host_process_id
FROM sys.dm_exec_sessions
GROUP BY host_process_id;

SELECT kernel_time,
       usermode_time,
       *
FROM sys.dm_os_threads;