/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

AOS_DEBUG
CONNECTION_CONTEXT
TOO_BIG_FOR_ENTIRE_TABLE_CACHE
TABLES_THAT_COULD_BE_ENTIRE_TABLE_CACHE
ENTIRE_TABLE_CACHE_WITH_UPDATES
OCC_DISABLED
AX_DATABASE_LOGGING
AX_ALERTS_ON_TABLE
AX_BATCH_CONFIGURATION
AOS_CLUSTER_CONFIG
AX_DB_LOGGING_BY_TABLE
NUMBER_SEQUENCE_USAGE


********************************************************************/




USE DynamicsPerf


--AOS Configuration issues
--
--				AOS_DEBUG
		-- --------------------------------------------------------------
		-- Is Enable X++ Debug enabled on any AOS Servers.
		-- 20% decline in transactions processed on the AOS instances with this enabled
		-----------------------------------------------------------------
		
		SELECT SERVER_NAME,
			   AOS_INSTANCE_NAME,
			   SETTING_NAME,
			   SETTING_VALUE
		FROM   AOS_REGISTRY
		WHERE  IS_CONFIGURATION_ACTIVE = 'Y'
			   AND SETTING_NAME = 'xppdebug'
			   AND SETTING_VALUE <> '0' 


		-- --------------------------------------------------------------
		--				CONNECTION_CONTEXT
		-- Is Context_Info enabled on any AOS Servers.
		-- AX2012 and above feature
		-- http://technet.microsoft.com/en-us/library/hh699644.aspx
		-----------------------------------------------------------------
		
		SELECT SERVER_NAME,
			   AOS_INSTANCE_NAME,
			   SETTING_NAME,
			   SETTING_VALUE
		FROM   AOS_REGISTRY
		WHERE  IS_CONFIGURATION_ACTIVE = 'Y'
			   AND SETTING_NAME = 'connectioncontext'
			   AND SETTING_VALUE <> '0' 



--AOT configuration issues
		
			--  TOO_BIG_FOR_ENTIRE_TABLE_CACHE

			-- --------------------------------------------------------------
			-- Find tables that have entire table cache enabled that are larger than 128K
			-- Causes the cache to overflow to disk on the AOS Server
			-----------------------------------------------------------------

			SELECT A.TABLE_NAME,
				   APPLICATION_LAYER,
				   CACHE_LOOKUP,
				   PAGE_COUNT
			FROM   AX_TABLE_DETAIL_CURR_VW A,
				   INDEX_STATS_CURR_VW I
			WHERE  A.DATABASE_NAME = I.DATABASE_NAME
				   AND A.TABLE_NAME = I.TABLE_NAME
				   AND CACHE_LOOKUP = 'EntireTable'
				   AND ( INDEX_DESCRIPTION = 'HEAP'
						  OR INDEX_DESCRIPTION LIKE 'CLUSTERED%' )
				   AND PAGE_COUNT > 16  -- 128kb
				   --AND PAGE_COUNT> 4  --32KB AX2012RTM
				   --AND PAGE_COUNT> 12  --96KB AX2012R2
				   
			ORDER  BY PAGE_COUNT DESC 

			--  TABLES_THAT_COULD_BE_ENTIRE_TABLE_CACHE

			-- --------------------------------------------------------------
			-- Find tables that have no cache enabled that are smaller than 128K
			-- These could cause lots of roundtrips between AOS and SQL
			--
			-- NOTE:
			-- Table should be static and not updated much before changing
			-- cache to Entiretable
			-----------------------------------------------------------------


			SELECT A.TABLE_NAME,
				   APPLICATION_LAYER,
				   CACHE_LOOKUP,
				   PAGE_COUNT
			FROM   AX_TABLE_DETAIL_CURR_VW A,
				   INDEX_STATS_CURR_VW I
			WHERE  A.DATABASE_NAME = I.DATABASE_NAME
				   AND A.TABLE_NAME = I.TABLE_NAME
				   AND CACHE_LOOKUP = 'None'
				   AND ( INDEX_DESCRIPTION = 'HEAP'
						  OR INDEX_DESCRIPTION LIKE 'CLUSTERED%' )
				   AND PAGE_COUNT < 16  -- 128kb
				   --AND PAGE_COUNT> 4  --32KB AX2012RTM
				   --AND PAGE_COUNT> 12  --96KB AX2012R2
				   AND PAGE_COUNT > 0
				   
			ORDER  BY TABLE_NAME DESC 
			--
			--		ENTIRE_TABLE_CACHE_WITH_UPDATES
			--
			-- --------------------------------------------------------------
			-- Find tables that have entire table cache and show update rate
			-- Causes the cache to be refreshed on all AOS instances
			-----------------------------------------------------------------
			
			SELECT A.TABLE_NAME,
				   APPLICATION_LAYER,
				   CACHE_LOOKUP,
				   USER_UPDATES
			FROM   AX_TABLE_DETAIL_CURR_VW A,
				   INDEX_STATS_CURR_VW I
			WHERE  A.DATABASE_NAME = I.DATABASE_NAME
				   AND A.TABLE_NAME = I.TABLE_NAME
				   AND CACHE_LOOKUP = 'EntireTable'
				   AND ( INDEX_DESCRIPTION = 'HEAP'
						  OR INDEX_DESCRIPTION LIKE 'CLUSTERED%' )
			ORDER  BY USER_UPDATES DESC 

			--
			--	OCC_DISABLED
			--
			-- --------------------------------------------------------------
			--  Find tables above SYS layer that do not have OCC enabled:
			-- 
			-----------------------------------------------------------------
			
			SELECT TABLE_NAME
			FROM   AX_TABLE_DETAIL_CURR_VW
			WHERE  APPLICATION_LAYER NOT IN ( 'SYS', 'System Table' )
				   AND OCC_ENABLED = 0
			ORDER  BY TABLE_NAME 

			--
			--	AX_DATABASE_LOGGING
			--
			-- --------------------------------------------------------------
			-- Find tables above SYS layer that have logging enabled
			-- 
			-----------------------------------------------------------------
			
			SELECT *
			FROM   AX_TABLE_DETAIL_CURR_VW
			WHERE  APPLICATION_LAYER NOT IN ( 'SYS', 'System Table' )
				   AND ( DATABASELOG_INSERT = 1
						  OR DATABASELOG_DELETE = 1
						  OR DATABASELOG_UPDATE = 1
						  OR DATABASELOG_RENAME_KEY = 1 )
			ORDER  BY TABLE_NAME 


			--
			--		AX_ALERTS_ON_TABLE
			--
			-- --------------------------------------------------------------
			-- Find tables above SYS layer that have events enabled
			-- 
			-----------------------------------------------------------------
			
			SELECT *
			FROM   AX_TABLE_DETAIL_CURR_VW
			WHERE  APPLICATION_LAYER NOT IN ( 'SYS', 'System Table' )
				   AND ( EVENT_INSERT = 1
						  OR EVENT_DELETE = 1
						  OR EVENT_UPDATE = 1
						  OR EVENT_RENAME_KEY = 1 )
			ORDER  BY TABLE_NAME 


			-- SELECT * FROM EVENTRULE   -- DO THIS IN THE AX DATABASE TO DISCOVER ABOVE DATA

--AX Application configuration issues

			--
			--		AX_BATCH_CONFIGURATION
			--
			-- -----------------------------------------------------------------------------
			-- List BATCHGROUP configuration in Dynamics AX
			--------------------------------------------------------------------------------
			
			SELECT *
			FROM   AX_BATCH_CONFIGURATION_VW 

			--
			--		AOS_CLUSTER_CONFIG
			--
			-- -----------------------------------------------------------------------------
			-- List AOS cluster configuration in Dynamics AX
			--------------------------------------------------------------------------------

			SELECT *
			FROM   AX_SERVER_CONFIGURATION_VW 

			--
			--		AX_DB_LOGGING_BY_TABLE
			--
			-- --------------------------------------------------------------
			-- List top 200 tables be logged in Dynamics AX
			-- NOTE: if this query returns zero rows 
			--         the AOTEXPORT class has not been run
			-----------------------------------------------------------------

			SELECT [TABLE_NAME],
				   [ROWS_LOGGED],
				   [DATABASELOG_UPDATE],
				   [DATABASELOG_DELETE],
				   [DATABASELOG_INSERT]
			FROM   [AX_DATABASELOGGING_VW]
			ORDER  BY [ROWS_LOGGED] DESC
			
			--
			--		NUMBER_SEQUENCE_USAGE
			--
			-- -----------------------------------------------------------------------------
			-- List NUMBERSEQUENCE table configuration in Dynamics AX
			-- Are sequences marked as Coninuous?  If so why?
			-- Is FETCHAHEADQTY > 0,  if not preallocation is not setup for this sequence 
			-- Pre-allocation requires knowledge of the avg. number of numbers consumed 
			-- per user process to determine a good value.        
			--------------------------------------------------------------------------------
			
			SELECT RUN2.[DATABASE_NAME],
				   RUN2.[COMPANYID],
				   RUN2.[NUMBERSEQUENCE],
				   RUN2.[TEXT],
				   RUN2.[FORMAT],
				   Datediff(hh, RUN1.STATS_TIME, RUN2.STATS_TIME)                                       AS ELAPSED_HOURS,
				   RUN2.NEXTREC - RUN1.NEXTREC                                                          AS TOTAL_NUMBERS_CONSUMED,
				   ( RUN2.NEXTREC - RUN1.NEXTREC ) / ( Datediff(hh, RUN1.STATS_TIME, RUN2.STATS_TIME) ) AS HOURLY_CONSUMPTION_RATE,
				   RUN2.HIGHEST - RUN2.NEXTREC                                                          AS [NUMBERSREMAINING],
				   RUN2.[CONTINUOUS],
				   RUN2.[FETCHAHEAD],
				   RUN2.[FETCHAHEADQTY], 
				   RUN2.[TEXT] AS SEQUENCEFORMAT
			FROM   AX_NUM_SEQUENCES_VW RUN1
				   INNER JOIN AX_NUM_SEQUENCES_VW RUN2
						   ON RUN1.NUMBERSEQUENCE = RUN2.NUMBERSEQUENCE
							  AND RUN1.COMPANYID = RUN2.COMPANYID
			WHERE  RUN1.RUN_NAME = 'BASE_to_compare_to'
				   AND RUN2.RUN_NAME = 'Feb_26_2020_804AM'
			ORDER  BY 7 DESC 



			--To find run_name run the following query

			SELECT *
			FROM   STATS_COLLECTION_SUMMARY
			ORDER  BY STATS_TIME DESC 


			-- --------------------------------------------------------------
			-- Review number sequence configuration in Dynamics AX 
			-----------------------------------------------------------------

			SELECT *
			FROM   AX_NUM_SEQUENCES_CURR_VW
			WHERE  CONTINUOUS = 'Yes' 

