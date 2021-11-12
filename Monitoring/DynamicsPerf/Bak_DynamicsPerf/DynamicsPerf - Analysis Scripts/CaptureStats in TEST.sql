



-------------------------------------------------------------------
-- For testing in a non-production system do the following:
--
-- NOTE: Disable the DYNPERF_XXXXXXXX JOBS IN SQL AGENT in Dev/Test
-- HIGHLY suggested to not collect DEV/TEST into the same DynamicsPerf 
--  as production.
-------------------------------------------------------------------
 
 
 
 
 
 
--STEP 1 
		USE DynamicsPerf

		GO

		EXEC SP_PURGESTATS
		  @PURGE_DAYS = -1,
		  @DATABASE_NAME = '_database_name' --Use this option to delete all data for 1 database
		  ,@SERVER_NAME = 'XXXXXXXXXXXXXX'
		  ,@TRUNCATE_ALL = 'Y'  --This parm ignores all and just truncates the tables
		GO 

     
--		--	Be sure all users are out of the test database
--		--	Get yourself to the point in the application where you are ready 
--		--	to push the button for the code	you want to review.
--
--STEP 2

		DBCC FREEPROCCACHE

-- OR 
--		purge procedure cache for a SPECIFIC database 
--
		DECLARE @intDBID INTEGER
        
        SET @intDBID = (SELECT dbid
                        FROM   master.dbo.sysdatabases
                        WHERE  name = '_database_name')
        
        DBCC FLUSHPROCINDB (@intDBID) 
        
--
--

-- STEP 3
--		NOW RUN YOUR TESTS




-- STEP 4 capture data 

EXEC SP_CAPTURESTATS
		  @SERVER_NAME = 'MY_SERVER',
		  @DATABASE_NAME = 'MY_DATABASE',
		  @DYNAMICS_PRODUCT = 'AX',
		  @AZURE_DB = 0,
		  @TASK_TYPE = 'COLLECT',
		  @DEBUG = 'Y' 


-- STEP 5  Review your data
