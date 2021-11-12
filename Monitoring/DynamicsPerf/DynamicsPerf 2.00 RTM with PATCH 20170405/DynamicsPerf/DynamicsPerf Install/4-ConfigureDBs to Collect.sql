USE [DynamicsPerf]
GO





/************************************************************************
MUST ENABLE DTC DISTRIBUTED TRANSACTION COORDINATOR  on the server
hosting DynamicsPerf database to do remote collections if using that 
feature of DynamicsPerf. 
*************************************************************************/



/************************************************************************
MUST setup Linked Servers for remote collection of data before inserting 
databases to be collected
*************************************************************************/

INSERT DynamicsPerf..DATABASES_2_COLLECT
SELECT 'SQL_NAME_HERE',  --Server Name or Linked Server Name, 
       'DB_NAME_HERE', --Database name to be monitored
       'AX',	--Dynamics Product 'ALL', 'AX', 'CRM', 'GP', 'NAV', 'SL'
       0,		--AZURE DB 0 = NO, 1 = YES
       1,	    --ENABLED 0 = NO, 1 = YES
       13,		--MONTHS TO RETAIN MONTHLY HISTORY DATA
       60,		--DAYS TO RETAIN DAILY HISTORY TOTALS
       2,		--DAYS TO KEEP DETAILS (QUERY_STATS AND INDEX_STATS)
       61,		--PURGE QUERIES NOT SEEN IN XX DAYS
       7,		--REFRESH QUERY PLAN DAYS
       20,		--NO. OF QUERY PLANS TO KEEP PER QUERY_HASH  -1 = ALL
       0,		--Ignore queries below this time in (ms)  -- 0 ms in this example
       100,		--COLLECT TOP X PERECENT QUERIES BY TOTAL_ELAPSED_TIME
       50,		--COLLECT TOP X PERCENT QUERY PLANS BY TOTAL_ELAPSED_TIME
       100,		--KEEP_TOP_X_QUERIES_BY_MONTH
		50,		--KEEP_TOP_X_PLANS_BY_MONTH
		60		--PURGE_PLANS_AFTER_X_DAYS
       

	SELECT * FROM dbo.DATABASES_2_COLLECT

GO


/************************************************************************
Configure QUERY_ALERTS_CONFIG options that populate the QUERY_ALERTS table

NOTE: no data in this table until collections start
*************************************************************************/	
	

--REH setup NEW database settings
	INSERT INTO [DynamicsPerf].[dbo].[QUERY_ALERTS_CONFIG]
           ([SERVER_NAME]
           ,[DATABASE_NAME]
           ,[PCT_AVG_TIME_CHANGE_DAY]
           ,[PCT_AVG_TIME_CHANGE_MONTH]
           ,[MIN_EXECUTION_COUNTS]
           ,[MIN_AVG_TIME_MS])
     VALUES
           ('SQL_NAME_HERE'
           ,'DB_NAME_HERE'
           ,150 --PCT_AVG_TIME_CHANGE_DAY
           ,150 --PCT_AVG_TIME_CHANGE_MONTH
           ,1 --MIN_EXECUTION_COUNTS
           ,250 --MIN_AVG_TIME_MS
           )
  
  
  	SELECT * FROM dbo.QUERY_ALERTS_CONFIG         
           
/********  Cleanup ****************

DELETE FROM DATABASES_2_COLLECT 
WHERE SERVER_NAME = 'SQL_NAME_HERE'


DELETE FROM QUERY_ALERTS_CONFIG] 
WHERE SERVER_NAME = 'SQL_NAME_HERE'



**********************************/



