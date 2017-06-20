USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE'
    ,N'Software\Microsoft\MSSQLServer\MSSQLServer'
    ,N'NumErrorLogs'
    ,REG_DWORD
    ,99
GO
USE [master];
GO
 
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'ErrorLogSizeInKb', REG_DWORD, 5120;
GO

EXEC sp_cycle_errorlog
go