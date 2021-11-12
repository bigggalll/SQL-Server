
USE [DynamicsPerf]
GO


/************************************************************************
Configure database level options
*************************************************************************/

SELECT *
FROM   DATABASES_2_COLLECT
UPDATE DATABASES_2_COLLECT
SET    ENABLED = 0,-- 0 = DISABLED 1 = ENABLED
       RETAIN_DETAILS_DAYS = 2,-- Keep detailed totals for QUERY_STATS and INDEX_STATS for how many days
       RETAIN_HISTORY_DAYS = 60,-- Keep the daily totals in QUERY_HISTORY and INDEX_HISTORY for how many days
       RETAIN_HISTORY_MONTHS = 12,-- Keep monthly totals in QUERY_HISTORY and INDEX_HISTORY for how many months
       [PURGE_STALE_QUERIES_DAYS] = 61,
       [REFRESH_PLAN_DAYS] = 7,
       [NUM_PLANS_TO_KEEP] = 20,
       [IGNORE_QUERIES_UNDER_MS] = 0,
       [COLLECT_TOP_X_QUERIES] = 100,
       [COLLECT_TOP_X_PLANS] = 50,
       [KEEP_TOP_X_QUERIES_BY_MONTH] = 100,
       [KEEP_TOP_X_PLANS_BY_MONTH] = 50,
       [PURGE_PLANS_AFTER_X_DAYS] = 60 


		
		
		
		WHERE  LINKED_SERVER = 'XXXXXXXXXX'
			   AND DATABASE_NAME = 'XXXXXXXXXXX' 

	
/************************************************************************
Configure task level options
*************************************************************************/	

SELECT * FROM DYNPERF_TASK_SCHEDULER

		UPDATE DYNPERF_TASK_SCHEDULER
		SET    ENABLED = 0,-- 0 = DISABLED 1 = ENABLED
			   SCHEDULE_UNITS = 'HH',-- MI = MINUTES, HH = HOURS, DD = DAYS, WK = WEEKS, MM = MONTHS, QQ = QUARTERS, YY = YEARS
			   SCHEDULE_QTY_PER_UNIT = 1,-- HOW MANY OF THE SCHEDULED UNITS
			   SCHEDULE_TIME = '17:00' -- START AT WHAT TIME OF THE DAY
		WHERE  TASK_ID = 5 



/************************************************************************
Override task level options at the database level

NOTE: no data in this table until collections start
*************************************************************************/	
	
	SELECT * FROM dbo.DYNPERF_TASK_HISTORY
	
	
		UPDATE DYNPERF_TASK_HISTORY
		SET    SCHEDULE_UNITS = 'HH',-- MI = MINUTES, HH = HOURS, DD = DAYS, WK = WEEKS, MM = MONTHS, QQ = QUARTERS, YY = YEARS
			   SCHEDULE_QTY_PER_UNIT = 1,-- HOW MANY OF THE SCHEDULED UNITS
			   SCHEDULE_TIME = '17:00' -- START AT WHAT TIME OF THE DAY
		WHERE  LINKEDSERVER_NAME = 'XXXXXXX'
			   AND DATABASE_NAME = 'XXXXXXXX'
			   AND TASK_ID = 5 

	

/************************************************************************
CONFIGURE purging of data by table
*************************************************************************/	

SELECT * FROM DYNPERF_PURGETABLES


UPDATE DYNPERF_PURGETABLES SET
	RETENTION_DAYS = 14 -- NUMBER OF DAYS TO RETAIN DATA ACROSS ALL DATABASES
	
	
	
	
/************************************************************************
CONFIGURE AX SQL TRACE FUNCTIONALITY

NOTE: THIS CONFIGURATION IS ALSO CONTROLLED BY RUNNING:
 SP_SET_AX_SQLTRACE stored procedure
*************************************************************************/	

SELECT * FROM AX_SQLTRACE_CONFIG

	UPDATE AX_SQLTRACE_CONFIG
	SET    SQL_DURATION = 5000,-- HOW LONG DOES A QUERY HAVE TO TAKE TO BE RECORDED
		   TRACE_ON = 0,-- 0 = OFF, 1 = ON
		   AXDB_DELETION_DAYS = 7 --HOW MANY DAYS TO KEEP AX_SQLTRACE data



/************************************************************************
Configure QUERY_ALERTS_CONFIG options that populate the QUERY_ALERTS table

NOTE: no data in this table until collections start
*************************************************************************/	
	
	SELECT * FROM dbo.QUERY_ALERTS_CONFIG
	
--REH setup NEW database settings
	INSERT INTO [DynamicsPerf].[dbo].[QUERY_ALERTS_CONFIG]
           ([SERVER_NAME]
           ,[DATABASE_NAME]
           ,[PCT_AVG_TIME_CHANGE_DAY]
           ,[PCT_AVG_TIME_CHANGE_MONTH]
           ,[MIN_EXECUTION_COUNTS]
           ,[MIN_AVG_TIME_MS])
     VALUES
           ('SERVER_NAME_HERE'
           ,'DB_NAME'
           ,150 --PCT_AVG_TIME_CHANGE_DAY
           ,150 --PCT_AVG_TIME_CHANGE_MONTH
           ,1 --MIN_EXECUTION_COUNTS
           ,100 --MIN_AVG_TIME_MS
           )
           
  --REH Update existing record          
	
		UPDATE [DynamicsPerf].[dbo].[QUERY_ALERTS_CONFIG]
		SET    [PCT_AVG_TIME_CHANGE_DAY] = 150,
			   [PCT_AVG_TIME_CHANGE_MONTH] = 150,
			   [MIN_EXECUTION_COUNTS] = 1,
			   [MIN_AVG_TIME_MS] = 100
		WHERE  SERVER_NAME = 'XXXXXXXXXX'
			   AND DATABASE_NAME = 'XXXXXXXXXXX' 

GO


	