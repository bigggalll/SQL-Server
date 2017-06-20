-- setup the database and objects to store the monitoring information
-- 
create database [db_monitor]
go

declare @create_indexes bit = 1;		-- do we need to create indexes on these tables
declare @runtime datetime = getdate()
-- create the table structure according to the metadata of the respective Dynamic Management Views and Catalog views
select @runtime as runtime, @@SERVERNAME as server_name, cast(FILEPROPERTY(name,'spaceused') as float) * 8192 as _space_used_bytes , cast(size as float) * 8192 as _space_allocated_bytes, * into [db_monitor].dbo.tbl_database_files from sys.database_files
select @runtime as runtime, @@SERVERNAME as server_name, * into [db_monitor].dbo.tbl_dm_db_task_space_usage from sys.dm_db_task_space_usage where (internal_objects_alloc_page_count+user_objects_alloc_page_count) > 0
select @runtime as runtime, @@SERVERNAME as server_name, * into [db_monitor].dbo.tbl_dm_db_session_space_usage from sys.dm_db_session_space_usage where (internal_objects_alloc_page_count+user_objects_alloc_page_count) > 0
select @runtime as runtime, @@SERVERNAME as server_name, * into [db_monitor].dbo.tbl_dm_tran_active_snapshot_database_transactions from sys.dm_tran_active_snapshot_database_transactions
select @runtime as runtime, @@SERVERNAME as server_name, * into [db_monitor].dbo.tbl_dm_tran_active_transactions from sys.dm_tran_active_transactions
select @runtime as runtime, @@SERVERNAME as server_name, * into [db_monitor].dbo.tbl_dm_tran_database_transactions from sys.dm_tran_database_transactions
select @runtime as runtime, @@SERVERNAME as server_name, * into [db_monitor].dbo.tbl_dm_tran_session_transactions from sys.dm_tran_session_transactions
select @runtime as runtime, @@SERVERNAME as server_name, * into [db_monitor].dbo.tbl_dm_exec_sessions from sys.dm_exec_sessions where is_user_process = 1
select @runtime as runtime, @@SERVERNAME as server_name, r.* , st.objectid as module_id, cast(
SUBSTRING(st.text, (r.statement_start_offset/2)+1, ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(st.text) ELSE r.statement_end_offset END - r.statement_start_offset)/2) + 1) as varchar(1024)) AS statement_text 
into [db_monitor].dbo.tbl_dm_exec_requests
from sys.dm_exec_requests r outer apply sys.dm_exec_sql_text(r.sql_handle) as st
create table [db_monitor].dbo.tbl_inputbuffers (runtime datetime,server_name nvarchar(128),session_id smallint,[EventType] nvarchar(30),[Parameters] smallint,[EventInfo] nvarchar(4000)) 
create table [db_monitor].dbo.tbl_queryplans (runtime datetime,server_name nvarchar(128),session_id smallint,[query_plan] xml) 

if (@create_indexes = 1)			-- create all indexes if requested
begin
	create clustered index cidx on [db_monitor].dbo.tbl_database_files(runtime) with ( data_compression = PAGE )
	create clustered index cidx on [db_monitor].dbo.tbl_dm_db_task_space_usage(runtime) with (data_compression = page)
	create clustered index cidx on [db_monitor].dbo.tbl_dm_db_session_space_usage(runtime) with (data_compression = page)
	create clustered index cidx on [db_monitor].dbo.tbl_dm_tran_active_snapshot_database_transactions(runtime) with (data_compression = page)
	create clustered index cidx on [db_monitor].dbo.tbl_dm_tran_active_transactions(runtime) with (data_compression = page)
	create clustered index cidx on [db_monitor].dbo.tbl_dm_tran_database_transactions(runtime) with (data_compression = page)
	create clustered index cidx on [db_monitor].dbo.tbl_dm_tran_session_transactions(runtime) with (data_compression = page)
	create clustered index cidx on [db_monitor].dbo.tbl_dm_exec_sessions(runtime) with (data_compression = page)
	create clustered index cidx on [db_monitor].dbo.tbl_dm_exec_requests(runtime) with (data_compression = page)
	create clustered index cidx on [db_monitor].dbo.tbl_inputbuffers(runtime) with (data_compression = page)
	create clustered index cidx on [db_monitor].dbo.tbl_queryplans(runtime) with (data_compression = page)
end
go


-- use this script to collect information about transactions that are consuming space in tempdb (change the database information according to your db encountering the issue)
-- setup this in a job to execute every minute
use tempdb
go
set nocount on
go
declare @capture_plans_full_inputbuffer bit = 1;		-- do you want to capture query plans and full input buffers 
declare @usage_threshold bigint = 1073741824		-- amount of tempdb space in bytes consumed for which plans and input buffer need to be collected
declare @runtime datetime = getdate()
-- load the data from all the Dynamic Management Views and Catalog Views
insert into [db_monitor].dbo.tbl_database_files select @runtime as runtime, @@SERVERNAME as server_name, cast(FILEPROPERTY(name,'spaceused') as float)* 8192 as _space_used_bytes , cast(size as float)* 8192 as _space_allocated_bytes, * from sys.database_files
insert into [db_monitor].dbo.tbl_dm_db_task_space_usage select @runtime as runtime, @@SERVERNAME as server_name, * from sys.dm_db_task_space_usage where (internal_objects_alloc_page_count+user_objects_alloc_page_count) > 0
insert into [db_monitor].dbo.tbl_dm_db_session_space_usage select @runtime as runtime, @@SERVERNAME as server_name, * from sys.dm_db_session_space_usage where (internal_objects_alloc_page_count+user_objects_alloc_page_count) > 0
insert into [db_monitor].dbo.tbl_dm_tran_active_snapshot_database_transactions select @runtime as runtime, @@SERVERNAME as server_name, * from sys.dm_tran_active_snapshot_database_transactions
insert into [db_monitor].dbo.tbl_dm_tran_active_transactions select @runtime as runtime, @@SERVERNAME as server_name, * from sys.dm_tran_active_transactions
insert into [db_monitor].dbo.tbl_dm_tran_database_transactions select @runtime as runtime, @@SERVERNAME as server_name, * from sys.dm_tran_database_transactions
insert into [db_monitor].dbo.tbl_dm_tran_session_transactions select @runtime as runtime, @@SERVERNAME as server_name, * from sys.dm_tran_session_transactions
insert into [db_monitor].dbo.tbl_dm_exec_sessions select @runtime as runtime, @@SERVERNAME as server_name, * from sys.dm_exec_sessions where is_user_process = 1
insert into [db_monitor].dbo.tbl_dm_exec_requests select @runtime as runtime, @@SERVERNAME as server_name, r.* , st.objectid as module_id, cast(
SUBSTRING(st.text, (r.statement_start_offset/2)+1, ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(st.text) ELSE r.statement_end_offset END - r.statement_start_offset)/2) + 1) as varchar(255)) AS statement_text 
from sys.dm_exec_requests r outer apply sys.dm_exec_sql_text(r.sql_handle) as st

if (@capture_plans_full_inputbuffer = 1)
begin
	declare @session_id smallint, @server_name nvarchar(128) = @@servername, @cmd nvarchar(512)
	declare @inputbuffer TABLE ([EventType] nvarchar(30),[Parameters] smallint,[EventInfo] nvarchar(4000))
	set @usage_threshold = @usage_threshold / 8192	-- conversion to pages
	declare session_cursor cursor for 
		select distinct [session_id] from [db_monitor].[dbo].[tbl_dm_db_task_space_usage] where [runtime] = @runtime and (internal_objects_alloc_page_count+user_objects_alloc_page_count) > @usage_threshold
		union 
		select distinct [session_id] from [db_monitor].[dbo].[tbl_dm_db_session_space_usage] where [runtime] = @runtime and (internal_objects_alloc_page_count+user_objects_alloc_page_count) > @usage_threshold
		union
		select distinct [session_id] from [db_monitor].[dbo].[tbl_dm_tran_session_transactions] where [runtime] = @runtime and [transaction_id] in 
			(select transaction_id from [db_monitor].[dbo].[tbl_dm_tran_database_transactions] where [runtime] = @runtime and [database_transaction_log_bytes_reserved] > @usage_threshold * 8192)
	open session_cursor
	fetch next from session_cursor into @session_id
	while @@fetch_status <> -1
	begin
		set @cmd = 'dbcc inputbuffer (' + cast(@session_id as varchar(10)) + ') with no_infomsgs'
		insert into @inputbuffer ([EventType],[Parameters],[EventInfo]) exec (@cmd)
		insert into [db_monitor].dbo.tbl_inputbuffers select @runtime, @server_name, @session_id , [EventType],[Parameters],[EventInfo] from @inputbuffer
		delete from @inputbuffer
		insert into [db_monitor].dbo.tbl_queryplans select top 1 r.runtime, r.server_name, r.session_id, q.query_plan 
			from [db_monitor].dbo.tbl_dm_exec_requests r cross apply sys.dm_exec_query_plan(r.plan_handle) q where r.runtime = @runtime and r.session_id = @session_id  
		fetch next from session_cursor into @session_id
	end
	close session_cursor
	deallocate session_cursor
end
go

