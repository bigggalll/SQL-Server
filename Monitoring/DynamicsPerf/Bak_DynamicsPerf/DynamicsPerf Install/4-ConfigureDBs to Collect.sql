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
SELECT 'LstnAX01Q',  --Server Name or Linked Server Name, 
       'AX2012R3', --Database name to be monitored
       'AX',	--Dynamics Product 'ALL', 'AX', 'CRM', 'GP', 'NAV', 'SL'
       0,		--AZURE DB 0 = NO, 1 = YES
       1,	    --ENABLED 0 = NO, 1 = YES
       24,		--MONTHS TO RETAIN MONTHLY HISTORY DATA
       60,		--DAYS TO RETAIN DAILY HISTORY TOTALS
       2,		--DAYS TO KEEP DETAILS (QUERY_STATS AND INDEX_STATS)
       90,		--PURGE QUERIES NOT SEEN IN XX DAYS
       7		--REFRESH QUERY PLAN DAYS



GO


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
           ('LstnAX01Q'
           ,'AX2012R3'
           ,150 --PCT_AVG_TIME_CHANGE_DAY
           ,150 --PCT_AVG_TIME_CHANGE_MONTH
           ,1 --MIN_EXECUTION_COUNTS
           ,250 --MIN_AVG_TIME_MS
           )
           
           
/********  Cleanup ****************

DELETE FROM DATABASES_2_COLLECT 
WHERE SERVER_NAME = 'LstnAX01Q'


**********************************/



