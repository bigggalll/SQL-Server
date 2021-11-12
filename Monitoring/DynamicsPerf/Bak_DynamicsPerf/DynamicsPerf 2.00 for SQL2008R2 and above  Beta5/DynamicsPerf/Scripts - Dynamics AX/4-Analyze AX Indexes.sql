
/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

INDEX_SIZE_BY_CONFIG
INDEX_ACTIVITY_BY_CONFIG_KEY
INDEXES_IN_DB_NOT_IN_AOT
INDEXES_WITH_RECVERSION
TABLES_WITHOUT_UNIQUE_INDEX


********************************************************************/



-- --------------------------------------------------------------
--
--			INDEX_SIZE_BY_CONFIG
--
-- List TABLE sizes by AX Configuration Key
--
----------------------------------------------------------------

USE DynamicsPerf

SELECT ISV.DATABASE_NAME,
       IDV.CONFIG_KEY_NAME,
       SUM(CASE
             WHEN ISV.INDEX_ID IN ( 0, 1 ) THEN PAGE_COUNT * 8 / 1024
           END)   AS SIZEMB_DATA,
       SUM(CASE
             WHEN ISV.INDEX_ID > 1 THEN PAGE_COUNT * 8 / 1024
           END)   AS SIZEMB_INDEXES,
       COUNT(CASE
               WHEN ISV.INDEX_ID > 1 THEN ISV.TABLE_NAME
             END) AS NO_OF_INDEXES,
       MAX(CASE
             WHEN ( DATA_COMPRESSION > 0 )
                  AND ( ISV.INDEX_ID IN ( 0, 1 ) ) THEN 'Y'
             ELSE 'N'
           END)   AS DATA_COMPRESSED,
       MAX(CASE
             WHEN ( DATA_COMPRESSION > 0 )
                  AND ( ISV.INDEX_ID > 1 ) THEN 'Y'
             ELSE 'N'
           END)   AS INDEXES_COMPRESSED
FROM   INDEX_STATS_CURR_VW ISV
       INNER JOIN AX_INDEX_DETAIL_VW IDV
               ON ISV.SERVER_NAME = IDV.SERVER_NAME
                  AND ISV.DATABASE_NAME = IDV.DATABASE_NAME
                  AND ISV.TABLE_NAME = IDV.TABLE_NAME
                  AND ISV.INDEX_NAME = IDV.INDEX_NAME
--WHERE DATABASE_NAME = 'XXXXXXXXXXXX' 
--	AND SERVER_NAME = 'XXXXXXXX'
GROUP  BY ISV.SERVER_NAME,
          ISV.DATABASE_NAME,
          IDV.CONFIG_KEY_NAME
ORDER  BY 4 DESC 







-- --------------------------------------------------------------
--
--			INDEX_ACTIVITY_BY_CONFIG_KEY
--
-- List READ/WRITE ratios by AX Configuration Key
--
----------------------------------------------------------------


SELECT ISV.DATABASE_NAME,
       IDV.CONFIG_KEY_NAME,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                                                                                        + USER_LOOKUPS) AS DECIMAL) )
       END                                         AS ratioofreads,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_UPDATES) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                                                              + USER_LOOKUPS) AS DECIMAL) )
       END                                         AS ratioofwrites,
       SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS totalreadoperations,
       SUM(USER_UPDATES)                           AS totalwriteoperations,
       SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
           + USER_LOOKUPS)                         AS totaloperations
FROM   INDEX_STATS_CURR_VW ISV
       INNER JOIN AX_INDEX_DETAIL_VW IDV
               ON ISV.SERVER_NAME = IDV.SERVER_NAME
                  AND ISV.DATABASE_NAME = IDV.DATABASE_NAME
                  AND ISV.TABLE_NAME = IDV.TABLE_NAME
                  AND ISV.INDEX_NAME = IDV.INDEX_NAME
--WHERE DATABASE_NAME = 'XXXXXXXXXXXX' 
--	AND SERVER_NAME = 'XXXXXXXX'
GROUP  BY ISV.SERVER_NAME,
          ISV.DATABASE_NAME,
          IDV.CONFIG_KEY_NAME
--ORDER BY TotalOperations DESC
--ORDER BY TotalReadOperations DESC
ORDER  BY TotalWriteOperations DESC 








--
--			INDEXES_IN_DB_NOT_IN_AOT
--
-- --------------------------------------------------------------
-- Find INDEXES that are not defined in the AOT 
--
--  NOTE: Ignore System tables in this list. 
-- 
-- INDEXES should ALWAYS be defined in the AOT as synchronization
--   will remove them
--
-- This also violates Dynamics AX Best Practices to not have an 
-- index defined in the AOT !!
--
-- It's ok to add an index for testing purposes on the SQL side
--  as long as you add it to the AOT once you know you are going 
--  to keep the index
-----------------------------------------------------------------

/****************************************************************
NOTE: If no data here, it could be correct OR, it could be 
AOTEXPORT hasn't been run from inside DynamicsAX or
INDEX_STATS data hasn't collected yet
****************************************************************/

		SELECT *
		FROM   INDEX_STATS_CURR_VW I
		WHERE  INDEX_DESCRIPTION <> 'HEAP'
			   AND INDEX_DESCRIPTION NOT LIKE '%FILTERED%'
			   AND NOT EXISTS (SELECT *
							   FROM   AX_INDEX_DETAIL_VW A
							   WHERE  A.SERVER_NAME = I.SERVER_NAME
									  AND A.DATABASE_NAME = I.DATABASE_NAME
									  AND A.TABLE_NAME = I.TABLE_NAME
									  AND A.INDEX_NAME = I.INDEX_NAME)
		ORDER  BY SERVER_NAME,
				  DATABASE_NAME,
				  TABLE_NAME,
				  INDEX_NAME 



--
--			INDEXES_WITH_RECVERSION
--
-- --------------------------------------------------------------
-- Find INDEXES that have RECVERSION in the Key or Included list
--  RECVERSION should NOT be apart of AX Indexes do to the 
--  frequency of updates
-----------------------------------------------------------------



		SELECT *
		FROM   INDEX_STATS_CURR_VW I
		WHERE  INDEX_KEYS LIKE '%RECVERSION%'
				OR INCLUDED_COLUMNS LIKE '%RECVERSION%'
		ORDER  BY SERVER_NAME,
				  DATABASE_NAME,
				  TABLE_NAME,
				  INDEX_NAME 





--
--			TABLES_WITHOUT_UNIQUE_INDEX
--
-- --------------------------------------------------------------
-- Find tables that don't have a unique key for AX record caching
--	Can't record cache w/o a unique index on the table
-- You must define a unique index and use that filter in X++ code
-----------------------------------------------------------------

	SELECT DISTINCT TABLE_NAME
	FROM   INDEX_STATS_CURR_VW V1
	WHERE  NOT EXISTS (SELECT 'X'
					   FROM   INDEX_STATS_CURR_VW V2
					   WHERE  V2.SERVER_NAME = V1.SERVER_NAME
							  AND V2.DATABASE_NAME = V1.DATABASE_NAME
							  AND V1.TABLE_NAME = V2.TABLE_NAME
							  AND V2.INDEX_DESCRIPTION LIKE '%UNIQUE%')
		   AND EXISTS (SELECT 'X'
					   FROM   AX_TABLE_DETAIL AD
					   WHERE  AD.SERVER_NAME = V1.SERVER_NAME
							  AND AD.DATABASE_NAME = V1.DATABASE_NAME
							  AND AD.TABLE_NAME = V1.TABLE_NAME
							  AND AD.CACHE_LOOKUP IN ( 'FOUND', 'FOUNDANDEMPTY', 'NOTINTTS' ))

        
-- TABLES YOU MIGHT CACHE LATER W/O UNIQUE INDEXES


		SELECT DISTINCT TABLE_NAME
		FROM   INDEX_STATS_CURR_VW V1
		WHERE  NOT EXISTS (SELECT 'X'
						   FROM   INDEX_STATS_CURR_VW V2
						   WHERE  V2.SERVER_NAME = V1.SERVER_NAME
								  AND V2.DATABASE_NAME = V1.DATABASE_NAME
								  AND V1.TABLE_NAME = V2.TABLE_NAME
								  AND V2.INDEX_DESCRIPTION LIKE '%UNIQUE%')
			   AND EXISTS (SELECT 'X'
						   FROM   AX_TABLE_DETAIL AD
						   WHERE  AD.SERVER_NAME = V1.SERVER_NAME
								  AND AD.DATABASE_NAME = V1.DATABASE_NAME
								  AND AD.TABLE_NAME = V1.TABLE_NAME
								  AND AD.CACHE_LOOKUP IN ( 'NONE' )) 


