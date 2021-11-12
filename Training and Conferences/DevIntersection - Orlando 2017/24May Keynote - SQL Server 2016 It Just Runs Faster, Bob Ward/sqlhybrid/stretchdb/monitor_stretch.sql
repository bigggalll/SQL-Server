use letsgorangers
go
SELECT table_id, migrated_rows, DATEADD(minute, DATEDIFF(minute,getutcdate(),getdate()), start_time_utc),
DATEADD(minute, DATEDIFF(minute,getutcdate(),getdate()), end_time_utc),
error_number
FROM sys.dm_db_rda_migration_status
order by end_time_utc desc
GO
select * from sys.dm_db_rda_schema_update_status
go
EXEC sp_spaceused 'rangerstotheworldseries', 'true', 'LOCAL_ONLY';
EXEC sp_spaceused 'rangerstotheworldseries', 'true', 'REMOTE_ONLY';
EXEC sp_spaceused 'rangerstotheworldseries', 'true', 'ALL';
GO
select * from sys.remote_data_archive_tables
go
select * from sys.remote_data_archive_databases
go
select name, is_remote_data_archive_enabled from sys.databases where name = 'letsgorangers'
go
select * from sys.tables where name = 'rangerstotheworldseries'
go