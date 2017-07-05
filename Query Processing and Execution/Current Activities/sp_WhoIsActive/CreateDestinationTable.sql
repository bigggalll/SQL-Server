DECLARE @destination_table VARCHAR(4000) ;
SET @destination_table = 'WhoIsActive_' + CONVERT(VARCHAR, GETDATE(), 112) ;

DECLARE @schema VARCHAR(4000) ;
        EXEC dbo.sp_WhoIsActive 
			 @get_transaction_info = 1, 
			 @get_plans = 2,
			 @find_block_leaders = 1, 
			 @get_full_inner_text = 1,
			 @get_task_info=2,
			 @get_locks=1,
			 @get_avg_time=1,
			@RETURN_SCHEMA = 1,
			@SCHEMA = @schema OUTPUT ;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @destination_table)
BEGIN
    SET @schema = REPLACE(@schema, '<table_name>', @destination_table) ;
    PRINT @schema
    EXEC(@schema) ;
END;
GO
