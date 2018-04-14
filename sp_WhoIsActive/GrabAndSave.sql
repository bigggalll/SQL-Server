--exec sp_whoisactive @help=1
DECLARE @destination_table VARCHAR(4000) ;

exec DBA_SQL01q..sp_WhoIsActive 
		 @get_additional_info=1
		,@show_system_spids = 1
		,@delta_interval=10
		,@get_transaction_info=1
		,@get_task_info=2
		,@get_outer_command=1
		,@get_locks=1
		,@get_avg_time = 1
		,@get_plans=2
		,@show_sleeping_spids=2
		,@get_full_inner_text=1
		--,@sort_order='[session_id]'
		,@destination_table = 'WhoIsActive'
		,@return_schema = 1
		,@schema = @destination_table OUTPUT ;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @destination_table)
BEGIN
    SET @destination_table = REPLACE(@destination_table, '<table_name>', 'WhoIsActive') ;
    PRINT @destination_table
    EXEC(@destination_table)
END
go


--,@sort_order='[host_name]'



--@show_sleeping_spids=2

