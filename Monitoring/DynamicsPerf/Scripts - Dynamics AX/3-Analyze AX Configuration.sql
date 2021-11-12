/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

AX_GLOBAL_CONFIG
AX_LICENSE
AX_CONFIG_KEYS
AX_COUNTRY_CODES
AOS_DEBUG
CONNECTION_CONTEXT
TOO_BIG_FOR_ENTIRE_TABLE_CACHE
TABLES_THAT_COULD_BE_ENTIRE_TABLE_CACHE
ENTIRE_TABLE_CACHE_WITH_UPDATES
OCC_DISABLED
AX_DATABASE_LOGGING
AX_ALERTS_ON_TABLE
AX_BATCH_CONFIGURATION
AOS_CLUSTER_CONFIGF
AX_DB_LOGGING_BY_TABLE
NUMBER_SEQUENCE_USAGE
AX_AOT_TABLE_DIFFERENCES
AX_AOT_INDEX_DIFFERENCES

********************************************************************/




USE DynamicsPerf


--AX GLOBAL SYSTEM CONFIGURATIONS 
--
--				AX_GLOBAL_CONFIG
		-- --------------------------------------------------------------
		-- Are any configurations impacting performance?
		-----------------------------------------------------------------

SELECT *
FROM   AX_SYSGLOBALCONFIGURATION 
--WHERE SERVER_NAME = 'XXXXXXXXXXX' AND DATABASE_NAME = 'XXXXXXXXXX'

--AX LICENSE INFORMATION
--
--				AX_LICENSE
		-- --------------------------------------------------------------
		-- Are License keys enabled that are not needed ?
		-----------------------------------------------------------------
		

SELECT [STATS_TIME],
       [DATABASE_NAME],
       [LICENSE_KEY_ENABLED] AS ENABLED,
       [LICENSE_KEY_NAME],
       [LICENSE_KEY_LABEL],
       [LICENSE_GROUP],
       [LICENSE_TYPE],
       [PACKAGE],
       [PREREQUISITE1],
       [PREREQUISITE2],
       [PREREQUISITE3],
       [PREREQUISITE4],
       [PREREQUISITE5],
       [SERVER_NAME],
       [LICENSE_KEY_ID]
FROM   [AX_LICENSEKEY_DETAIL]
ORDER  BY [LICENSE_KEY_NAME]



--AX CONFIGURATION KEY INFORMATION
--
--				AX_CONFIG_KEYS
		-- --------------------------------------------------------------
		-- Are configuration keys enabled that are not needed ?
		-----------------------------------------------------------------
		

SELECT 
      [STATS_TIME]
      ,[DATABASE_NAME]
      ,[CONFIG_KEY_ID]
      ,[CONFIG_KEY_NAME]
      ,[CONFIG_KEY_LABEL]
      ,[PARENT_KEY_ID]
      ,[LICENSE_KEY_ID]
      ,[CONFIG_ENABLED]
      ,[SERVER_NAME]
  FROM [AX_CONFIGURATIONKEY_DETAIL]
  
  
--AX Country codes enabled with data
--
--				AX_COUNTRY_CODES
		-- --------------------------------------------------------------------
		-- Are License/Config keys enabled for countries that are not needed ?
		-----------------------------------------------------------------------
		
  
  SELECT ATD.[SERVER_NAME],
       ATD.[STATS_TIME],
       ATD.[DATABASE_NAME],
       ATD.[TABLE_NAME],
       [CONFIGURATION_KEY_ID],
       [LICENSE_CODE_ID],
       [APPLAYER],
       [COUNTRY_REGION_CODES],
       ISV.[ROW_COUNT]
FROM   [AX_TABLE_DETAIL] ATD
       INNER JOIN [AX_LICENSEKEY_DETAIL] ALD
               ON ATD.[LICENSE_CODE_ID] = ALD.[LICENSE_KEY_ID]
                  AND ATD.[SERVER_NAME] = ALD.[SERVER_NAME]
                  AND ATD.[DATABASE_NAME] = ALD.[DATABASE_NAME]
       INNER JOIN [INDEX_STATS_CURR_VW] ISV 
			ON ISV.SERVER_NAME = ATD.SERVER_NAME
			AND ISV.DATABASE_NAME = ATD.DATABASE_NAME
			AND ATD.TABLE_NAME = ISV.TABLE_NAME
			AND ISV.INDEX_ID IN (0,1)
			
WHERE  [COUNTRY_REGION_CODES] > ''
       AND ALD.[LICENSE_KEY_ENABLED] = 1
       AND ISV.ROW_COUNT > 0
ORDER  BY [TABLE_NAME] 

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
		WHERE  ( IS_CONFIGURATION_ACTIVE = 'Y'
				 AND SETTING_NAME = 'xppdebug'
				 AND SETTING_VALUE <> '0' )
				OR ( IS_CONFIGURATION_ACTIVE = 'Y'
					 AND SETTING_NAME = 'globalbreakpoints'
					 AND SETTING_VALUE <> '0' ) 




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
					   A.APPLAYER,
					   CACHE_LOOKUP,
					   PAGE_COUNT
				FROM   AX_TABLE_DETAIL_VW A,
					   INDEX_STATS_CURR_VW I
				WHERE  A.SERVER_NAME = I.SERVER_NAME
					   AND A.DATABASE_NAME = I.DATABASE_NAME
					   AND A.TABLE_NAME = I.TABLE_NAME
					   AND CACHE_LOOKUP = 'EntireTable'
					   AND ( INDEX_DESCRIPTION = 'HEAP'
							  OR INDEX_DESCRIPTION LIKE 'CLUSTERED%' )
					   AND PAGE_COUNT > 16 -- 128kb
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
				   A.APPLAYER,
				   CACHE_LOOKUP,
				   PAGE_COUNT
			FROM   AX_TABLE_DETAIL_VW A,
				   INDEX_STATS_CURR_VW I
			WHERE  A.SERVER_NAME = I.SERVER_NAME
				   AND A.DATABASE_NAME = I.DATABASE_NAME
				   AND A.TABLE_NAME = I.TABLE_NAME
				   AND CACHE_LOOKUP = 'None'
				   AND ( I.INDEX_ID IN (0,1))
				   AND PAGE_COUNT < 16  -- 128kb
				   --AND PAGE_COUNT< 4  --32KB AX2012RTM
				   --AND PAGE_COUNT< 12  --96KB AX2012R2
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
				   A.APPLAYER,
				   CACHE_LOOKUP,
				   USER_UPDATES
			FROM   AX_TABLE_DETAIL_VW A,
				   INDEX_STATS_CURR_VW I
			WHERE  A.SERVER_NAME = I.SERVER_NAME
				   AND A.DATABASE_NAME = I.DATABASE_NAME
				   AND A.TABLE_NAME = I.TABLE_NAME
				   AND CACHE_LOOKUP = 'EntireTable'
				   AND ( I.INDEX_ID IN (0,1))
			ORDER  BY USER_UPDATES DESC 

			--
			--	OCC_DISABLED
			--
			-- --------------------------------------------------------------
			--  Find tables above SYS layer that do not have OCC enabled:
			-- 
			-----------------------------------------------------------------
			
			SELECT TABLE_NAME
			FROM   AX_TABLE_DETAIL_VW
			WHERE  APPLAYER NOT IN ( 'SYS', 'System Table' )
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
			FROM   AX_TABLE_DETAIL_VW
			WHERE  ( DATABASELOG_INSERT = 1
						  OR DATABASELOG_DELETE = 1
						  OR DATABASELOG_UPDATE = 1
						  OR DATABASELOG_RENAMEKEY = 1 )
			ORDER  BY TABLE_NAME 


			--
			--		AX_ALERTS_ON_TABLE
			--
			-- --------------------------------------------------------------
			-- Find tables above SYS layer that have events enabled
			-- 
			-----------------------------------------------------------------
			
			SELECT *
			FROM   AX_TABLE_DETAIL_VW
			WHERE  ( EVENT_INSERT = 1
						  OR EVENT_DELETE = 1
						  OR EVENT_UPDATE = 1
						  OR EVENT_RENAMEKEY = 1 )
			ORDER  BY TABLE_NAME 


			-- SELECT * FROM EVENTRULE   -- DO THIS IN THE AX DATABASE TO DISCOVER ABOVE DATA

--AX Application configuration issues

			--
			--		AX_BATCH_CONFIGURATION
			--
			-- -----------------------------------------------------------------------------
			-- List BATCH JOBS configuration in Dynamics AX
			--------------------------------------------------------------------------------
			
			SELECT *
			FROM   AX_BATCHJOB_CONFIGURATION_VW 

			--
			--		AOS_CLUSTER_CONFIG
			--
			-- -----------------------------------------------------------------------------
			-- List AOS cluster configuration in Dynamics AX
			--------------------------------------------------------------------------------

			SELECT *
			FROM   AX_BATCHSERVER_CONFIGURATION_VW 

			--
			--		AX_DB_LOGGING_BY_TABLE
			--
			-- --------------------------------------------------------------
			-- List top 200 tables be logged in Dynamics AX
			-- NOTE: if this query returns zero rows 
			--         the AOTEXPORT class has not been run
			-----------------------------------------------------------------

			SELECT DISTINCT [TABLE_NAME],
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
			
			SELECT ENDING.[DATABASE_NAME],
				   ENDING.[COMPANYID],
				   ENDING.[NUMBERSEQUENCE],
				   ENDING.[TEXT],
				   ENDING.[FORMAT],
				   datediff(hh, STARTING.STATS_TIME, ENDING.STATS_TIME)                                           AS elapsed_hours,
				   ENDING.NEXTREC - ENDING.NEXTREC                                                              AS total_numbers_consumed,
				   ( ENDING.NEXTREC - ENDING.NEXTREC ) / ( datediff(hh, STARTING.STATS_TIME, ENDING.STATS_TIME) ) AS hourly_consumption_rate,
				   ENDING.HIGHEST - ENDING.NEXTREC                                                              AS [numbersremaining],
				   ENDING.[CONTINUOUS],
				   ENDING.[FETCHAHEAD],
				   ENDING.[FETCHAHEADQTY],
				   ENDING.[TEXT]                                                                                AS sequenceformat
			FROM   AX_NUM_SEQUENCES_VW STARTING
				   INNER JOIN AX_NUM_SEQUENCES_VW ENDING
						   ON ENDING.NUMBERSEQUENCE = STARTING.NUMBERSEQUENCE
							  AND ENDING.COMPANYID = STARTING.COMPANYID
			WHERE  STARTING.STATS_TIME = 'STARTING_STATS_TIME'
				   AND ENDING.STATS_TIME = 'ENDING_STATS_TIME'
			ORDER  BY 7 DESC 



			--To find run_name run the following query

			SELECT DISTINCT STATS_TIME
			FROM   AX_NUM_SEQUENCES_VW
			ORDER  BY STATS_TIME DESC 


			--
			--		AX_AOT_TABLE_DIFFERENCES
			--
			-- -----------------------------------------------------------------------------
			-- List AOTEXPORT configuration differences between Dynamics AX
			-- environments.
			-- 
			-- Must run AOTEXPORT_DIRECT from each environment
			--        
			--------------------------------------------------------------------------------
			


			SELECT ATD1.SERVER_NAME,
				   ATD1.DATABASE_NAME,
				   ATD1.TABLE_NAME,
				   CASE ATD1.TABLE_GROUP WHEN ISNULL(ATD2.TABLE_GROUP,'') THEN 'SAME' ELSE
				   'ATD1.TABLE_GROUP = ' + ATD1.TABLE_GROUP + '  ATD2.TABLE_GROUP = ' + ISNULL(ATD2.TABLE_GROUP,'')
				   END AS TABLE_GROUP,
				   CASE ATD1.OCC_ENABLED WHEN ISNULL(ATD2.OCC_ENABLED,'') THEN 'SAME' ELSE
				   'ATD1.OCC_ENABLED = ' + CAST(ATD1.OCC_ENABLED AS VARCHAR(1)) + '  ATD2.OCC_ENABLED = ' + CAST(ISNULL(ATD2.OCC_ENABLED,0) AS VARCHAR(1))
				   END AS OCC_ENABLED,
				   CASE ATD1.CACHE_LOOKUP WHEN ISNULL(ATD2.CACHE_LOOKUP,'') THEN 'SAME' ELSE
				   'ATD1.CACHE_LOOKUP = ' + ATD1.CACHE_LOOKUP + '  ATD2.CACHE_LOOKUP = ' + ISNULL(ATD2.CACHE_LOOKUP,'')
				   END AS CACHE_LOOKUP,
				   CASE ATD1.INSERT_METHOD_OVERRIDDEN WHEN ISNULL(ATD2.INSERT_METHOD_OVERRIDDEN,0) THEN 'SAME' ELSE
				   'ATD1.INSERT_METHOD_OVERRIDDEN = ' + CAST(ATD1.INSERT_METHOD_OVERRIDDEN AS VARCHAR(1)) + '  ATD2.INSERT_METHOD_OVERRIDDEN = ' + CAST(ISNULL(ATD2.INSERT_METHOD_OVERRIDDEN,0) AS VARCHAR(1))
				   END AS INSERT_METHOD_OVERRIDDEN,
				   CASE ATD1.UPDATE_METHOD_OVERRIDDEN WHEN ISNULL(ATD2.UPDATE_METHOD_OVERRIDDEN,0) THEN 'SAME' ELSE
				   'ATD1.UPDATE_METHOD_OVERRIDDEN = ' + CAST(ATD1.UPDATE_METHOD_OVERRIDDEN AS VARCHAR(1)) + '  ATD2.UPDATE_METHOD_OVERRIDDEN = ' + CAST(ISNULL(ATD2.UPDATE_METHOD_OVERRIDDEN,0) AS VARCHAR(1))
				   END AS UPDATE_METHOD_OVERRIDDEN,
					CASE ATD1.DELETE_METHOD_OVERRIDDEN WHEN ISNULL(ATD2.DELETE_METHOD_OVERRIDDEN,0) THEN 'SAME' ELSE
				   'ATD1.DELETE_METHOD_OVERRIDDEN = ' + CAST(ATD1.DELETE_METHOD_OVERRIDDEN AS VARCHAR(1)) + '  ATD2.DELETE_METHOD_OVERRIDDEN = ' + CAST(ISNULL(ATD2.DELETE_METHOD_OVERRIDDEN,0) AS VARCHAR(1))
				   END AS DELETE_METHOD_OVERRIDDEN,
					CASE ATD1.AOS_VALIDATE_INSERT WHEN ISNULL(ATD2.AOS_VALIDATE_INSERT,0) THEN 'SAME' ELSE
				   'ATD1.AOS_VALIDATE_INSERT = ' + CAST(ATD1.AOS_VALIDATE_INSERT AS VARCHAR(1)) + '  ATD2.AOS_VALIDATE_INSERT = ' + CAST(ISNULL(ATD2.AOS_VALIDATE_INSERT,0) AS VARCHAR(1))
				   END AS AOS_VALIDATE_INSERT,
					CASE ATD1.AOS_VALIDATE_UPDATE WHEN ISNULL(ATD2.AOS_VALIDATE_UPDATE,0) THEN 'SAME' ELSE
				   'ATD1.AOS_VALIDATE_UPDATE = ' + CAST(ATD1.AOS_VALIDATE_UPDATE AS VARCHAR(1)) + '  ATD2.AOS_VALIDATE_UPDATE = ' + CAST(ISNULL(ATD2.AOS_VALIDATE_UPDATE,0) AS VARCHAR(1))
				   END AS AOS_VALIDATE_UPDATE,
					CASE ATD1.AOS_VALIDATE_DELETE WHEN ISNULL(ATD2.AOS_VALIDATE_DELETE,0) THEN 'SAME' ELSE
				   'ATD1.AOS_VALIDATE_DELETE = ' + CAST(ATD1.AOS_VALIDATE_DELETE AS VARCHAR(1)) + '  ATD2.AOS_VALIDATE_DELETE = ' + CAST(ISNULL(ATD2.AOS_VALIDATE_DELETE,0) AS VARCHAR(1))
				   END AS AOS_VALIDATE_DELETE,
					CASE ATD1.AOS_VALIDATE_READ WHEN ISNULL(ATD2.AOS_VALIDATE_READ,0) THEN 'SAME' ELSE
				   'ATD1.AOS_VALIDATE_READ = ' + CAST(ATD1.AOS_VALIDATE_READ AS VARCHAR(1)) + '  ATD2.AOS_VALIDATE_READ = ' + CAST(ISNULL(ATD2.AOS_VALIDATE_READ,0) AS VARCHAR(1))
				   END AS AOS_VALIDATE_READ,
					CASE ATD1.DATABASELOG_INSERT WHEN ISNULL(ATD2.DATABASELOG_INSERT,0) THEN 'SAME' ELSE
				   'ATD1.DATABASELOG_INSERT = ' + CAST(ATD1.DATABASELOG_INSERT AS VARCHAR(1)) + '  ATD2.DATABASELOG_INSERT = ' + CAST(ISNULL(ATD2.DATABASELOG_INSERT,0) AS VARCHAR(1))
				   END AS DATABASELOG_INSERT,
					CASE ATD1.DATABASELOG_DELETE WHEN ISNULL(ATD2.DATABASELOG_DELETE,0) THEN 'SAME' ELSE
				   'ATD1.DATABASELOG_DELETE = ' + CAST(ATD1.DATABASELOG_DELETE AS VARCHAR(1)) + '  ATD2.DATABASELOG_DELETE = ' + CAST(ISNULL(ATD2.DATABASELOG_DELETE,0) AS VARCHAR(1))
				   END AS DATABASELOG_DELETE,
					CASE ATD1.DATABASELOG_UPDATE WHEN ISNULL(ATD2.DATABASELOG_UPDATE,0) THEN 'SAME' ELSE
				   'ATD1.DATABASELOG_UPDATE = ' + CAST(ATD1.DATABASELOG_UPDATE AS VARCHAR(1)) + '  ATD2.DATABASELOG_UPDATE = ' + CAST(ISNULL(ATD2.DATABASELOG_UPDATE,0) AS VARCHAR(1))
				   END AS DATABASELOG_UPDATE,
					 CASE ATD1.EVENT_INSERT WHEN ISNULL(ATD2.EVENT_INSERT,0) THEN 'SAME' ELSE
				   'ATD1.EVENT_INSERT = ' + CAST(ATD1.EVENT_INSERT AS VARCHAR(1)) + '  ATD2.EVENT_INSERT = ' + CAST(ISNULL(ATD2.EVENT_INSERT,0) AS VARCHAR(1))
				   END AS EVENT_INSERT,
					  CASE ATD1.EVENT_DELETE WHEN ISNULL(ATD2.EVENT_DELETE,0) THEN 'SAME' ELSE
				   'ATD1.EVENT_DELETE = ' + CAST(ATD1.EVENT_DELETE AS VARCHAR(1)) + '  ATD2.EVENT_DELETE = ' + CAST(ISNULL(ATD2.EVENT_DELETE,0) AS VARCHAR(1))
				   END AS EVENT_DELETE,
					   CASE ATD1.EVENT_UPDATE WHEN ISNULL(ATD2.EVENT_UPDATE,0) THEN 'SAME' ELSE
				   'ATD1.EVENT_UPDATE = ' + CAST(ATD1.EVENT_UPDATE AS VARCHAR(1)) + '  ATD2.EVENT_UPDATE = ' + CAST(ISNULL(ATD2.EVENT_UPDATE,0) AS VARCHAR(1))
				   END AS EVENT_UPDATE,
						CASE ATD1.CLUSTERED_INDEX WHEN ISNULL(ATD2.CLUSTERED_INDEX,'') THEN 'SAME' ELSE
				   'ATD1.CLUSTERED_INDEX = ' + ATD1.CLUSTERED_INDEX + '  ATD2.CLUSTERED_INDEX = ' + ISNULL(ATD2.CLUSTERED_INDEX,'')
				   END AS CLUSTERED_INDEX,                                          
						CASE ATD1.PRIMARY_KEY WHEN ISNULL(ATD2.PRIMARY_KEY,'') THEN 'SAME' ELSE
				   'ATD1.PRIMARY_KEY = ' + ATD1.PRIMARY_KEY + '  ATD2.PRIMARY_KEY = ' + ISNULL(ATD2.PRIMARY_KEY,'')
				   END AS PRIMARY_KEY,  
				   CASE ATD1.DATA_PER_COMPANY WHEN ISNULL(ATD2.DATA_PER_COMPANY,0) THEN 'SAME' ELSE
				   'ATD1.DATA_PER_COMPANY = ' + CAST(ATD1.DATA_PER_COMPANY AS VARCHAR(1)) + '  ATD2.DATA_PER_COMPANY = ' + CAST(ISNULL(ATD2.DATA_PER_COMPANY,0)AS VARCHAR(1))
				   END AS DATA_PER_COMPANY,  
					CASE ATD1.APPLAYER WHEN ISNULL(ATD2.APPLAYER,'') THEN 'SAME' ELSE
				   'ATD1.APPLAYER = ' + ATD1.APPLAYER + '  ATD2.APPLAYER = ' + ISNULL(ATD2.APPLAYER,'')
				   END AS APPLAYER
			       
			FROM   AX_TABLE_DETAIL ATD1
				   LEFT JOIN AX_TABLE_DETAIL ATD2
						  ON ATD1.SERVER_NAME = 'XXXXXXXXXXX'
							 AND ATD1.DATABASE_NAME = 'XXXXXXXXXXX'
							 AND ATD2.SERVER_NAME = 'XXXXXXXXXXX'
							 AND ATD2.DATABASE_NAME = 'XXXXXXXXXXX'
							 AND ATD1.TABLE_ID = ATD2.TABLE_ID
			           
			 WHERE ATD1.TABLE_GROUP <> ISNULL(ATD2.TABLE_GROUP,'') OR
			  ATD1.OCC_ENABLED  <> ISNULL(ATD2.OCC_ENABLED,0) OR
			   ATD1.CACHE_LOOKUP <> ISNULL(ATD2.CACHE_LOOKUP,'') OR
			   ATD1.INSERT_METHOD_OVERRIDDEN <> ISNULL(ATD2.INSERT_METHOD_OVERRIDDEN,0) OR
			   ATD1.UPDATE_METHOD_OVERRIDDEN <> ISNULL(ATD2.UPDATE_METHOD_OVERRIDDEN,0) OR
			   ATD1.DELETE_METHOD_OVERRIDDEN <> ISNULL(ATD2.DELETE_METHOD_OVERRIDDEN,0) OR
			   ATD1.AOS_VALIDATE_INSERT <> ISNULL(ATD2.AOS_VALIDATE_INSERT,0) OR
			   ATD1.AOS_VALIDATE_UPDATE <> ISNULL(ATD2.AOS_VALIDATE_UPDATE,0) OR
			   ATD1.AOS_VALIDATE_DELETE <> ISNULL(ATD2.AOS_VALIDATE_DELETE,0) OR
			   ATD1.AOS_VALIDATE_READ <> ISNULL(ATD2.AOS_VALIDATE_READ,0) OR
			   ATD1.DATABASELOG_INSERT <> ISNULL(ATD2.DATABASELOG_INSERT,0) OR
			   ATD1.DATABASELOG_DELETE <> ISNULL(ATD2.DATABASELOG_DELETE,0) OR
			   ATD1.DATABASELOG_UPDATE <> ISNULL(ATD2.DATABASELOG_UPDATE,0) OR
			   ATD1.EVENT_INSERT <> ISNULL(ATD2.EVENT_INSERT,0) OR
			   ATD1.EVENT_DELETE <> ISNULL(ATD2.EVENT_DELETE,0) OR
			   ATD1.EVENT_UPDATE <> ISNULL(ATD2.EVENT_UPDATE,0) OR
			   ATD1.CLUSTERED_INDEX <> ISNULL(ATD2.CLUSTERED_INDEX,'') OR
			   ATD1.PRIMARY_KEY <> ISNULL(ATD2.PRIMARY_KEY,'') OR
			   ATD1.DATA_PER_COMPANY <> ISNULL(ATD2.DATA_PER_COMPANY,0) OR
			   ATD1.APPLAYER <> ISNULL(ATD2.APPLAYER,'')
			  
 

GO 


			--
			--		AX_AOT_INDEX_DIFFERENCES
			--
			-- -----------------------------------------------------------------------------
			-- List AOTEXPORT configuration differences between Dynamics AX
			-- environments.
			-- 
			-- Must run AOTEXPORT_DIRECT from each environment
			--        
			--------------------------------------------------------------------------------
			



SELECT ATD1.SERVER_NAME,
       ATD1.DATABASE_NAME,
       ATD1.TABLE_NAME,
       ATD1.INDEX_ID,

       CASE ATD1.INDEX_NAME WHEN ISNULL(ATD2.INDEX_NAME,'') THEN 'SAME' ELSE
       'ATD1.INDEX_NAME = ' + ATD1.INDEX_NAME + '  ATD2.INDEX_NAME = ' + ISNULL(ATD2.INDEX_NAME,'')
       END AS INDEX_NAME,
       CASE ATD1.INDEX_KEYS WHEN ISNULL(ATD2.INDEX_KEYS,'') THEN 'SAME' ELSE
       'ATD1.INDEX_KEYS = ' + ATD1.INDEX_KEYS + '  ATD2.INDEX_KEYS = ' + ISNULL(ATD2.INDEX_KEYS,'')
                  END AS INDEX_KEYS,     
       CASE ATD1.ALLOW_DUPLICATES WHEN ISNULL(ATD2.ALLOW_DUPLICATES,0) THEN 'SAME' ELSE
       'ATD1.ALLOW_DUPLICATES = ' + CAST(ATD1.ALLOW_DUPLICATES AS VARCHAR(1)) + '  ATD2.ALLOW_DUPLICATES = ' + CAST(ISNULL(ATD2.ALLOW_DUPLICATES,0) AS VARCHAR(1))
       END AS ALLOW_DUPLICATES,       
         CASE ATD1.APPLAYER WHEN ISNULL(ATD2.APPLAYER,'') THEN 'SAME' ELSE
       'ATD1.APPLAYER = ' + ATD1.APPLAYER + '  ATD2.APPLAYER = ' + ISNULL(ATD2.APPLAYER,'')
        END AS APPLAYER  
       
        
FROM   AX_INDEX_DETAIL ATD1
       LEFT JOIN AX_INDEX_DETAIL ATD2
              ON ATD1.SERVER_NAME = 'XXXXXXXXXXX'
                 AND ATD1.DATABASE_NAME = 'XXXXXXXXXXX'
                 AND ATD2.SERVER_NAME = 'XXXXXXXXXXX'
                 AND ATD2.DATABASE_NAME = 'XXXXXXXXXXX'
                 AND ATD1.INDEX_ID = ATD2.INDEX_ID
           
 WHERE ATD1.INDEX_NAME <> ISNULL(ATD2.INDEX_NAME,'') OR
  ATD1.INDEX_KEYS  <> ISNULL(ATD2.INDEX_KEYS,'') OR
  ATD1.ALLOW_DUPLICATES  <> ISNULL(ATD2.ALLOW_DUPLICATES,0) OR
  ATD1.APPLAYER  <> ISNULL(ATD2.APPLAYER,'') 