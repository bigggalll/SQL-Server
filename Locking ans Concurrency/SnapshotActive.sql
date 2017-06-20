SELECT CONVERT( VARCHAR(30), GETDATE(), 121) AS runtime,
       a.*,
       b.kpid,
       b.blocked,
       b.lastwaittype,
       b.waitresource,
       b.dbid,
       b.cpu,
       b.physical_io,
       b.memusage,
       b.login_time,
       b.last_batch,
       b.open_tran,
       b.status,
       b.hostname,
       b.program_name,
       b.cmd,
       b.loginame,
       request_id
FROM sys.dm_tran_active_snapshot_database_transactions a
     INNER JOIN sys.sysprocesses b ON a.session_id = b.spid;