SELECT *  
FROM msdb.managed_backup.fn_get_health_status(NULL, NULL)
Go  
EXEC msdb.managed_backup.sp_get_backup_diagnostics
go
SELECT *   
FROM msdb.managed_backup.fn_available_backups ('howboutthemcowboys')
go