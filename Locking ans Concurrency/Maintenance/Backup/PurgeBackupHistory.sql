use msdb
go
exec sp_delete_database_backuphistory 'bb_test' 
go