SELECT 
r.session_id,
CONVERT(NVARCHAR(22),DB_NAME(r.database_id)) AS [database], 
r.command AS [backup_process],
s.last_request_start_time AS [started],
DATEADD(mi,r.estimated_completion_time/60000,getdate()) AS [finishing], 
DATEDIFF(mi, s.last_request_start_time, (dateadd(mi,r.estimated_completion_time/60000,getdate()))) - r.wait_time/60000 AS [mins left], 
DATEDIFF(mi, s.last_request_start_time, (dateadd(mi,r.estimated_completion_time/60000,getdate()))) AS [total wait mins (est)],
CONVERT(VARCHAR(5),CAST((r.percent_complete) AS DECIMAL (4,1))) AS [% complete],
GETDATE() AS [current time]
FROM sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions s
ON r.[session_id]=s.[session_id]
WHERE r.command IN ('BACKUP DATABASE','BACKUP LOG','RESTORE DATABASE','RESTORE VERIFYON','RESTORE HEADERON', 'RESTORE HEADERONLY')