/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

INDEXES_BY_SIZE
INDEX_ACTIVITY
INDEX_STATISTICS
TOO_LARGE_INDEXES
HIGH_COST_INDEXES
COMPRESSED_INDEXES
UNIQUE_INDEXES_NOT_DEFINED_UNIQUE
EXACT_DUPLICATE_INDEXES
SUBSET_DUPLICATE_INDEXES
INCLUDED_COLUMN_INDEXES
SUSPECT_INDEXES
UNUSED_INDEXES
TABLES_WITHOUT_CLUSTERED_INDEX
ADJUST_CLUSTERED_INDEXES
ANALYZE_INDEX_KEY_ORDER
INDEXES_BEING_SCANNED
INDEXES_WITH_MOST_LOCKING
SEARCH_QUERY_PLANS_FOR_INDEX_USAGE


********************************************************************/


-- --------------------------------------------------------------
--
--			INDEXES_BY_SIZE
--
-- List top 100 Largest Tables, Investigate for data retention 
-- purposes or incorrect application configuration such as logging
--
----------------------------------------------------------------

USE DynamicsPerf

SELECT TOP 100 DATABASE_NAME,
               TABLE_NAME,
               SUM(CASE
                     WHEN ISV.INDEX_ID IN (0,1)  THEN PAGE_COUNT * 8 / 1024
                   END)   AS SIZEMB_DATA,
               SUM(CASE
                     WHEN ISV.INDEX_ID > 1 THEN PAGE_COUNT * 8 / 1024
                   END)   AS SIZEMB_INDEXES,
               COUNT(CASE
                       WHEN ISV.INDEX_ID > 1 THEN TABLE_NAME
                     END) AS NO_OF_INDEXES,
               MAX(CASE
                     WHEN ( DATA_COMPRESSION > 0 )
                          AND ( ISV.INDEX_ID IN (0,1)  ) THEN 'Y'
                     ELSE 'N'
                   END)   AS DATA_COMPRESSED,
               MAX(CASE
                     WHEN ( DATA_COMPRESSION > 0 )
                          AND ( ISV.INDEX_ID > 1) THEN 'Y'
                     ELSE 'N'
                   END)   AS INDEXES_COMPRESSED
FROM   INDEX_STATS_CURR_VW ISV
--WHERE DATABASE_NAME = 'XXXXXXXXXXXX' 
--	AND SERVER_NAME = 'XXXXXXXX'
GROUP  BY SERVER_NAME,
          DATABASE_NAME,
          TABLE_NAME
ORDER  BY 3 DESC 




-- --------------------------------------------------------------
--
--			INDEX_ACTIVITY
--
-- List READ/WRITE ratios by table, Investigate for activity 
-- in unusual places such as logging or alerts or unused modules
--
----------------------------------------------------------------

SELECT DATABASE_NAME,
       TABLE_NAME,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) ) END   AS ratioofreads,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_UPDATES) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) ) END       AS ratioofwrites,
       SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS totalreadoperations,
       SUM(USER_UPDATES)                           AS totalwriteoperations,
       SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
           + USER_LOOKUPS)                         AS totaloperations, 
       (SELECT TOP 1 OCC_ENABLED FROM AX_TABLE_DETAIL_VW ATD WHERE ATD.SERVER_NAME = ISV.SERVER_NAME AND ATD.DATABASE_NAME = ISV.DATABASE_NAME
		AND ISV.TABLE_NAME = ATD.TABLE_NAME ) AS AX_OCCENABLED
FROM   INDEX_STATS_CURR_VW ISV/*sys.dm_db_index_usage_stats*/
--WHERE DATABASE_NAME = 'XXXXXXXXXXXX' 
--	AND SERVER_NAME = 'XXXXXXXX'
GROUP  BY SERVER_NAME,
          DATABASE_NAME,
          TABLE_NAME
--ORDER BY TotalOperations DESC
--ORDER BY TotalReadOperations DESC
ORDER  BY TotalWriteOperations DESC 



-- --------------------------------------------------------------
--
--			INDEX_STATISTICS
--
-- When were statistics last updated by table/index/stat
-- 
-- NOTE: Database Statistics are only collected weekly so this 
-- data will NOT be up to date as of a day but as of the Week
----------------------------------------------------------------


SELECT DATABASE_NAME,
       SERVER_NAME,
       TABLENAME,
       INDEXNAME,
       UPDATED
FROM   INDEX_STAT_HEADER ISH
WHERE  UPDATED IS NOT NULL
-- AND SERVER_NAME = 'XXXXXXXXX'
-- AND DATABASE_NAME = 'XXXXXXXX'
ORDER  BY UPDATED DESC



-- --------------------------------------------------------------
--
--			TOO_LARGE_INDEXES
--
-- Investigate indexes that are 25% or more of the table width 
--   for possiblely being defined with too many columns.
--
-- NOTE: Anything over 50% ir probably too wide of an index
----------------------------------------------------------------




;WITH TABLE_SIZE (SERVER_NAME, DATABASE_NAME, TABLE_NAME, SIZE)
     AS (SELECT SERVER_NAME,DATABASE_NAME,
                TABLE_NAME,
                PAGE_COUNT * 8 / 1024 AS size
         FROM   INDEX_STATS_CURR_VW
         WHERE  INDEX_ID IN (0,1) )
         
         
SELECT DISTINCT ISV.DATABASE_NAME,
                ISV.TABLE_NAME,
                TS.SIZE,
                ISV.INDEX_NAME,
                ( ( PAGE_COUNT * 8 / 1024 ) / TS.SIZE ) * 100 AS [%_of_table],
                ISV.INDEX_DESCRIPTION,
                ISV.INDEX_KEYS,
                ISV.INCLUDED_COLUMNS
FROM   INDEX_STATS_CURR_VW ISV
       INNER JOIN TABLE_SIZE TS
               ON ISV.SERVER_NAME = TS.SERVER_NAME
				  AND ISV.DATABASE_NAME = TS.DATABASE_NAME
                  AND ISV.TABLE_NAME = TS.TABLE_NAME
                  AND TS.SIZE > 0
WHERE  ISV.INDEX_ID > 1 
       AND USER_UPDATES > 100 -- index must be getting update
       AND PAGE_COUNT > 100 -- small parameter tables are ok
       AND ( ( PAGE_COUNT * 8 / 1024 ) / TS.SIZE ) * 100 > 25 --25%
ORDER  BY TS.SIZE DESC 





-- --------------------------------------------------------------
--
--			HIGH_COST_INDEXES
--
-- Investigate indexes that have more writes than reads 
--   for possible over indexing
--
-- NOTE: Do adequate testing in Dev/Test before removing the index
-- from production
----------------------------------------------------------------


SELECT SERVER_NAME,	
	   DATABASE_NAME,
       TABLE_NAME,
       INDEX_NAME,
       PAGE_COUNT*8/1024 AS SIZE_MB,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) ) END  AS RATIOOFREADS,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_UPDATES) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) ) END       AS RATIOOFWRITES,
       SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS TOTALREADOPERATIONS,
       SUM(USER_UPDATES)                           AS TOTALWRITEOPERATIONS,
       SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
           + USER_LOOKUPS)                         AS TOTALOPERATIONS
FROM   INDEX_STATS_CURR_VW /*sys.dm_db_index_usage_stats*/
WHERE   USER_UPDATES > (USER_SEEKS + USER_SCANS + USER_LOOKUPS)
AND INDEX_DESCRIPTION NOT LIKE '%UNIQUE%' and INDEX_DESCRIPTION NOT LIKE 'CLUSTERED%'
-- AND SERVER_NAME = 'XXXXXXXXX'
-- AND DATABASE_NAME = 'XXXXXXXX'

GROUP  BY SERVER_NAME,
		  DATABASE_NAME,
          TABLE_NAME,
          INDEX_NAME, 
          PAGE_COUNT
          
--ORDER BY TOTALOPERATIONS DESC
--ORDER BY TOTALREADOPERATIONS DESC
ORDER  BY TOTALWRITEOPERATIONS DESC 



-- --------------------------------------------------------------
--
--		COMPRESSED_INDEXES
--
-- Find indexes that are compressed.  
-- Compressing the database reduces the size of the db on disk
-- and keeps the data compressed in memory as well.  This can 
-- reduce Disk I/O and improve performance. 
-- Compression will increase CPU time ono the SQL Server
----------------------------------------------------------------

SELECT *
FROM   INDEX_STATS_CURR_VW
WHERE  DATA_COMPRESSION > 0
ORDER  BY USER_UPDATES DESC 



-- --------------------------------------------------------------
--
--		UNIQUE_INDEXES_NOT_DEFINED_UNIQUE
--
-- Find indexes that might be unique but not declared unique.  
-- Making it unique IF it actually is improves performance 
-- because SQL doesn't have to look at statistics to determine
-- that it is unique which would improve compile performance.
--
-- For Dynamnics AX, it it's marked unique it could be used for 
-- record level caching.
--
--
--  NOTE: This is based upon statistics so NOT 100 PERCENT accurate
--  DO NOT CHANGE  the index to unique UNLESS YOU KNOW IT ABSOLUTELY IS UNIQUE
-- keep in mind if business processes change it might not be unique
--	in the future
--
--
--	YOU COULD BREAK YOUR APPLICATION, SO BE CAREFUL !!
----------------------------------------------------------------


;WITH RECORDS_CTE (SERVER_NAME, DATABASE_NAME, TABLENAME, INDEX_NAME, INDEX_KEYS, ROW_COUNT, READS)
     AS
     -- Define the CTE query.
     (SELECT DISTINCT SERVER_NAME,
                      DATABASE_NAME,
                      TABLE_NAME,
                      INDEX_NAME,
                      INDEX_KEYS,
                      ROW_COUNT,
                      USER_SEEKS + USER_SCANS + USER_LOOKUPS AS reads
      FROM   INDEX_STATS_CURR_VW)
SELECT DISTINCT dv.SERVER_NAME,
                dv.DATABASE_NAME,
                dv.TABLENAME,
                rows.INDEX_NAME,
                DS.TYPE_DESC AS index_desc,
                rows.INDEX_KEYS,
                rows.ROW_COUNT
FROM   INDEX_DENSITY_VECTOR dv
       INNER JOIN RECORDS_CTE rows
               ON dv.TABLENAME = rows.TABLENAME
                  AND dv.DATABASE_NAME = rows.DATABASE_NAME
                  AND dv.SERVER_NAME = rows.SERVER_NAME
       INNER JOIN DYNSYSINDEXES DS
               ON DS.DATABASE_NAME = dv.DATABASE_NAME
                  AND DS.RUN_NAME LIKE dv.SERVER_NAME + '%'
                  AND DS.NAME = rows.INDEX_NAME
WHERE  DS.IS_UNIQUE = 0
       AND ROW_COUNT / ( 1 / DENSITY ) = 1.000000000000000000
       AND rows.READS > 1000 -- relatively used tables
       AND rows.ROW_COUNT > 10000 -- larger tables only
ORDER  BY ROW_COUNT DESC 

	   
	  

-- --------------------------------------------------------------
--
--				EXACT_DUPLICATE_INDEXES
--
-- Tables that have 2 or more indexes with the exact same key
-- Trust me, this happens.
--
--  NOTE:  The indexes could be duplicate on the keys but have unique set of included columns 
--   in that case they should be combined into a singular index
--   for performance reasons 
--
----------------------------------------------------------------

SELECT SERVER_NAME,
       DATABASE_NAME,
       TABLE_NAME,
       INDEX_KEYS,
       COUNT(*),
       STUFF ((SELECT ', ' + 'INDEX_NAME = ' + ISV.INDEX_NAME
                      + ' KEYS= ' + ISV.INDEX_KEYS
                      + ' INCLUDED_COLUMNS= '
                      + ISV.INCLUDED_COLUMNS
               FROM   INDEX_STATS_CURR_VW ISV
               WHERE  ISV.DATABASE_NAME = A.DATABASE_NAME
                      AND ISV.SERVER_NAME = A.SERVER_NAME
                      AND ISV.TABLE_NAME = A.TABLE_NAME
                      AND ISV.INDEX_KEYS = A.INDEX_KEYS
               FOR xml path('')), 1, 1, '''') AS indexes
FROM   INDEX_STATS_CURR_VW A
WHERE  INDEX_DESCRIPTION NOT LIKE '%primary key%'
GROUP  BY SERVER_NAME,
          DATABASE_NAME,
          TABLE_NAME,
          INDEX_KEYS
HAVING COUNT(INDEX_KEYS) > 1
ORDER  BY SERVER_NAME,
          DATABASE_NAME,
          TABLE_NAME 







-- --------------------------------------------------------------
--
--				SUBSET_DUPLICATE_INDEXES
--
--   Just as bad (and even more common) are indexes that are a left key
--   subset of another index on same table.  Unless the subsset key is
--   unique, its usefulness is subsumed of the superset key.
--   EXAMPLE:
--		1-INDEX A, B, C
--		2-INDEX A, B
--
--   In this case index 2 is a subset of index 1 on the keys
--
--  NOTE:  The indexes could be subset duplicate on the keys but have unique set of included columns 
--   in that case they should be combined into a singular index
--   for performance reasons 
----------------------------------------------------------------



SELECT DISTINCT O.SERVER_NAME,
                O.DATABASE_NAME,
                O.TABLE_NAME,
                O.INDEX_NAME            AS subset_index,
                O.INDEX_KEYS            AS subset_index_keys,
                O.INDEX_DESCRIPTION     AS subset_index_description,
                O.PAGE_COUNT * 8 / 1024 AS subset_size_mb,
                I.INDEX_NAME            AS superset_index,
                I.INDEX_KEYS            AS superset_keys
FROM   INDEX_STATS_CURR_VW O
       LEFT JOIN INDEX_STATS_CURR_VW I
              ON I.SERVER_NAME = O.SERVER_NAME
                 AND I.DATABASE_NAME = O.DATABASE_NAME
                 AND I.TABLE_NAME = O.TABLE_NAME
                 AND I.INDEX_KEYS <> O.INDEX_KEYS
                 AND I.INDEX_KEYS LIKE O.INDEX_KEYS + ',%'
WHERE  O.INDEX_DESCRIPTION NOT LIKE '%UNIQUE%'
       AND O.INDEX_DESCRIPTION NOT LIKE 'CLUSTERED%'
       AND I.INDEX_NAME IS NOT NULL
       AND O.PAGE_COUNT > 0
ORDER  BY O.SERVER_NAME,
          O.DATABASE_NAME,
          O.TABLE_NAME,
          O.INDEX_KEYS 




-- --------------------------------------------------------------
--
--			INCLUDED_COLUMN_INDEXES
--
-- Find indexes with high number of include columns 
-- This will cause table size BLOAT and potential blocking issues 
-- as SQL updates the included columns
-- 
-- It's recommended to have 4 or less columns in the included list
-- The columns should be static columns as updates to those columns
--  WILL cause poor database write performance 
----------------------------------------------------------------

SELECT TOP 100 *
FROM   INDEX_STATS_CURR_VW
WHERE  INCLUDED_COLUMNS <> 'N/A'
       AND PAGE_COUNT > 0
ORDER  BY NUM_INCLUDED_COLS DESC 



-- --------------------------------------------------------------
--
--			SUSPECT_INDEXES
--
-- Find indexes with high number of include columns = or greater 
-- then 50% of the columns in the table
--
-- This will cause table size BLOAT and potential blocking issues 
-- as SQL updates the included columns
-- 
-- There should never be more than a few of thses indexes
--   for very specific instances, generally reports. 
--
-- Blindly scripting the sys.dm_db_missing_index_details dmv is a bad idea
--
-- This  probably isn't the best solution available 
--  and these should be analyzed further.  
--  If you need assistance with this analysis,
--		call Microsoft support for assistance
--		 on your performance issue
----------------------------------------------------------------


--TOO MANY INCLUEDED COLUMNS

SELECT TOP 100 *
FROM   INDEX_STATS_CURR_VW V
WHERE  (NUM_INCLUDED_COLS > (SELECT Count(*)
                            FROM   DYNSYSOBJECTS SO
                                   INNER JOIN DYNSYSCOLUMNS SC
                                           ON SO.DATABASE_NAME = SC.DATABASE_NAME
                                              AND so.OBJECT_ID = sc.OBJECT_ID
                            WHERE  V.TABLE_NAME = SO.NAME
                                   AND V.DATABASE_NAME = SO.DATABASE_NAME
                            GROUP  BY SO.NAME) / 2)
 ORDER  BY NUM_INCLUDED_COLS DESC 
 
 
--TOO MANY KEY COLUMNS

SELECT TOP 100 *
FROM   INDEX_STATS_CURR_VW V
WHERE  (NUM_KEY_COLS > (SELECT Count(*)
                            FROM   DYNSYSOBJECTS SO
                                   INNER JOIN DYNSYSCOLUMNS SC
                                           ON SO.DATABASE_NAME = SC.DATABASE_NAME
                                              AND so.OBJECT_ID = sc.OBJECT_ID
                            WHERE  V.TABLE_NAME = SO.NAME
                                   AND V.DATABASE_NAME = SO.DATABASE_NAME
                            GROUP  BY SO.NAME) / 2)
 ORDER  BY NUM_KEY_COLS DESC 
 
 
 
-- --------------------------------------------------------------
--
--				UNUSED_INDEXES
--
-- Find indexes that are not being used.  If an index enforces
-- a uniqueness constraint, we must retain it.
--
--**************************************************************
-- DO NOT DELETE THESE INDEXES UNLESS YOU ARE SURE YOU HAVE RUN 
-- EVERY PROCESS IN YOUR DYNAMICS DATABASE INCLUDING YEAR END !!
--**************************************************************
----------------------------------------------------------------

SELECT *
FROM   HISTORICAL_INDEX_USAGE_VW
ORDER  BY USER_SEEKS + USER_SCANS + LOOKUPS,
          SIZE_MB DESC 

        


--Indexes not used this month but used last month
SELECT TMH.*
FROM   INDEX_HISTORY TMH
       INNER JOIN INDEX_HISTORY LMH
               ON TMH.SERVER_NAME = LMH.SERVER_NAME
                  AND TMH.DATABASE_NAME = LMH.DATABASE_NAME
                  AND TMH.TABLE_NAME = LMH.TABLE_NAME
                  AND TMH.INDEX_NAME = LMH.INDEX_NAME
                  AND TMH.DATE = Dateadd(MONTH, 1, LMH.DATE)
WHERE  TMH.FLAG = 'M'
       AND LMH.FLAG = 'M'
       AND TMH.INDEX_DESCRIPTION NOT LIKE '%UNIQUE%'
       AND TMH.INDEX_DESCRIPTION NOT LIKE 'CLUSTERED%'
       AND ( TMH.USER_SEEKS_DELTA
             + TMH.USER_LOOKUPS_DELTA
             + TMH.USER_SCANS_DELTA ) = 0 --REH Not used this month
       AND ( LMH.USER_SEEKS_DELTA
             + LMH.USER_LOOKUPS_DELTA
             + LMH.USER_SCANS_DELTA ) > 0 --REH was used last month
             
        

-- --------------------------------------------------------------
--
--		TABLES_WITHOUT_CLUSTERED_INDEX
--
-- Tables missing clustered indexes
-- Heaps with multiple non-clustered indexes.
-- Use the following script to identify a good clustered index
-- based solely on user activity
--
--  ALL TABLES SHOULD HAVE A CLUSTERED INDEX !!
--
----------------------------------------------------------------

SELECT RN = Row_number()
              OVER (
                PARTITION BY CLUS.DATABASE_NAME, CLUS.TABLE_NAME
                ORDER BY CLUS.DATABASE_NAME, CLUS.TABLE_NAME, ( NONCLUS.RANGE_SCAN_COUNT - CLUS.RANGE_SCAN_COUNT ) DESC),
       CLUS.SERVER_NAME,
       CLUS.DATABASE_NAME,
       CLUS.TABLE_NAME,
       CLUS.INDEX_NAME                                      AS HEAP_TABLE,
       CLUS.INDEX_KEYS                                      AS CLUSTERED_KEYS,
       NONCLUS.INDEX_NAME                                   AS NONCLUSTERED_INDEX,
       NONCLUS.INDEX_KEYS,
       ( NONCLUS.RANGE_SCAN_COUNT - CLUS.RANGE_SCAN_COUNT ) AS NONCLUSTERED_VS_CLUSTERED_RANGE_COUNT,
       CLUS.USER_SEEKS                                      AS CLUSTERED_USER_SEEKS,
       CLUS.USER_SCANS                                      AS CLUSTERED_USER_SCANS,
       CLUS.SINGLETON_LOOKUP_COUNT                          AS CLUSTERED_SINGLE_LOOKUPS,
       CLUS.RANGE_SCAN_COUNT                                AS CLUSTERED_RANGE_SCAN,
       NONCLUS.USER_SEEKS                                   AS NONCLUSTERED_USER_SEEKS,
       NONCLUS.USER_SCANS                                   AS NONCLUSTERED_USER_SCANS,
       NONCLUS.SINGLETON_LOOKUP_COUNT                       AS NONCLUSTERED_SINGLE_LOOKUPS,
       NONCLUS.RANGE_SCAN_COUNT                             AS NONCLUSTERED_RANGE_SCANS,
       NONCLUS.USER_UPDATES                                 AS NONCLUSTERED_USER_UPDATES
FROM   INDEX_STATS_CURR_VW CLUS
       INNER JOIN INDEX_STATS_CURR_VW NONCLUS
               ON CLUS.TABLE_NAME = NONCLUS.TABLE_NAME
                  AND CLUS.DATABASE_NAME = NONCLUS.DATABASE_NAME
                  AND CLUS.SERVER_NAME = NONCLUS.SERVER_NAME
                  AND CLUS.INDEX_NAME <> NONCLUS.INDEX_NAME
WHERE  CLUS.INDEX_DESCRIPTION LIKE 'HEAP%'
       AND ( ( NONCLUS.RANGE_SCAN_COUNT > CLUS.RANGE_SCAN_COUNT )
              OR ( NONCLUS.SINGLETON_LOOKUP_COUNT > CLUS.SINGLETON_LOOKUP_COUNT ) )
       AND CLUS.PAGE_COUNT > 0
ORDER  BY CLUS.USER_LOOKUPS DESC,
          CLUS.TABLE_NAME,
          RN 




-- ----------------------------------------------------------------------------------------
--
--				ADJUST_CLUSTERED_INDEXES
--
--
-- Find clustered indexes that could be changed 
-- to 1 of the non-clustered indexes that has more usage than the clustered index
-- Use the following script to identify the non-clustered index
-- that could be the clustered index based solely on user activity
-- This should be the LAST activty done in a performance tuning session
--
-- The index should be narrow with few, narrow columns
--
--NOTE - CHANGING CLUSTERED INDEXES WILL TAKE LONG TIME TO DO
--  AND REQUIRES DOWNTIME TO IMPLEMENT
--------------------------------------------------------------------------------------------

SELECT RN = Row_number()
              OVER (
                PARTITION BY CLUS.DATABASE_NAME, CLUS.TABLE_NAME
                ORDER BY CLUS.DATABASE_NAME, CLUS.TABLE_NAME, ( NONCLUS.RANGE_SCAN_COUNT - CLUS.RANGE_SCAN_COUNT ) DESC),
       CLUS.SERVER_NAME,
       CLUS.DATABASE_NAME,
       CLUS.TABLE_NAME,
       CLUS.INDEX_NAME                                      AS CLUSTERED_INDEX,
       CLUS.INDEX_KEYS                                      AS CLUSTERED_KEYS,
       NONCLUS.INDEX_NAME                                   AS NONCLUSTERED_INDEX,
       NONCLUS.INDEX_KEYS,
       ( NONCLUS.RANGE_SCAN_COUNT - CLUS.RANGE_SCAN_COUNT ) AS NONCLUSTERED_VS_CLUSTERED_RANGE_COUNT,
       CLUS.USER_SEEKS                                      AS CLUSTERED_USER_SEEKS,
       CLUS.USER_SCANS                                      AS CLUSTERED_USER_SCANS,
       CLUS.SINGLETON_LOOKUP_COUNT                          AS CLUSTERED_SINGLE_LOOKUPS,
       CLUS.RANGE_SCAN_COUNT                                AS CLUSTERED_RANGE_SCAN,
       NONCLUS.USER_SEEKS                                   AS NONCLUSTERED_USER_SEEKS,
       NONCLUS.USER_SCANS                                   AS NONCLUSTERED_USER_SCANS,
       NONCLUS.SINGLETON_LOOKUP_COUNT                       AS NONCLUSTERED_SINGLE_LOOKUPS,
       NONCLUS.RANGE_SCAN_COUNT                             AS NONCLUSTERED_RANGE_SCANS,
       NONCLUS.USER_UPDATES                                 AS NONCLUSTERED_USER_UPDATES
FROM   INDEX_STATS_CURR_VW CLUS
       INNER JOIN INDEX_STATS_CURR_VW NONCLUS
               ON CLUS.TABLE_NAME = NONCLUS.TABLE_NAME
                  AND CLUS.DATABASE_NAME = NONCLUS.DATABASE_NAME
                  AND CLUS.SERVER_NAME = NONCLUS.SERVER_NAME
                  AND CLUS.INDEX_NAME <> NONCLUS.INDEX_NAME
WHERE  CLUS.INDEX_DESCRIPTION LIKE 'CLUSTERED%'
       AND ( ( NONCLUS.RANGE_SCAN_COUNT > CLUS.RANGE_SCAN_COUNT )
              OR ( NONCLUS.SINGLETON_LOOKUP_COUNT > CLUS.SINGLETON_LOOKUP_COUNT ) )
              --CLUS.TABLE_NAME
ORDER  BY CLUS.USER_LOOKUPS DESC,
          CLUS.TABLE_NAME,
          RN 

    
      
-- ----------------------------------------------------------------------------------------
--
--				ANALYZE_INDEX_KEY_ORDER
--
--
-- Find indexes that might need the order of the keys changed
-- based upon uniqueness
--
--	MOST UNIQUE >>> LEAST UNIQUE
-- 
--  NOTE: This should be done on an Index by Index basis
--------------------------------------------------------------------------------------------


SELECT ISV.SERVER_NAME, ISV.DATABASE_NAME,
       ISV.TABLE_NAME, ISV.INDEX_NAME,
       ISV.INDEX_KEYS AS CURRENT_INDEX_ORDER,
       Stuff ((SELECT ', ' + KEYCOLUMN
               FROM   INDEX_KEY_ORDER_VW IKO
               WHERE  ISV.SERVER_NAME = IKO.SERVER_NAME
                      AND ISV.DATABASE_NAME = IKO.DATABASE_NAME
                      AND ISV.TABLE_NAME = IKO.TABLENAME
                      AND ISV.INDEX_NAME = IKO.INDEXNAME
               ORDER  BY TABLENAME,
                         INDEXNAME,
                         TOTAL_ROWS DESC
               FOR xml path('')), 1, 1, '') AS POTENTIAL_INDEX_ORDER
FROM   INDEX_STATS_CURR_VW ISV
WHERE  ISV.ROW_COUNT > 1000
AND ISV.USER_SEEKS > 1000
AND ISV.TABLE_NAME = 'XXXXXXXXX' 
-- AND ISV.DATABASE_NAME = 'XXXXXXXXXXXXXXX'
-- AND ISV.SERVER_NAME = 'XXXXXXXX'



-- --------------------------------------------------------------
--
--			INDEXES_BEING_SCANNED
--
-- Find non-clustered indexes that are being scanned.  Generally  
-- this will indicate that key columns are out of order compared
-- to query predicates
--
----------------------------------------------------------------

SELECT TOP 100 *
FROM   INDEX_STATS_CURR_VW
WHERE  USER_SCANS > 0
       AND INDEX_DESCRIPTION LIKE 'NONCLUSTERED%'
ORDER  BY USER_SCANS DESC 


-- --------------------------------------------------------------
--
--			INDEXES_WITH_MOST_LOCKING
--
-- Find indexes with most lock wait time.  
-- This could  indicate that key columns are out of order compared
-- to query predicates
--
----------------------------------------------------------------

SELECT TOP 100 *
FROM   INDEX_STATS_CURR_VW
WHERE  1=1
ORDER  BY (ROW_LOCK_WAIT_IN_MS + PAGE_LOCK_WAIT_IN_MS) DESC 



-- --------------------------------------------------------------
--
--				SEARCH_QUERY_PLANS_FOR_INDEX_USAGE
--
-- Using indexes identifies in the previous query, list queries 
-- whose execution plan references a specific index; order by 
-- most expensive (logical reads)
--
--	MUST HAVE DEPLOYED FULLTEXT INDEXES ON DYNPERF DATABASE
--		FOR THIS QUERY TO WORK
----------------------------------------------------------------

;WITH FT_CTE2 (QUERY_PLAN_HASH, QUERY_PLAN)
AS

(SELECT QUERY_PLAN_HASH, QUERY_PLAN
 FROM   QUERY_PLANS
 WHERE  CONTAINS (C_QUERY_PLAN, '"INVENTDIM" AND "INDEX SCAN"') -- find all statements scanning a specific table
--WHERE  CONTAINS (C_QUERY_PLAN, '"I_6143RECID"') -- find all SQL statements that contain a specific index 
) 

SELECT TOP 100 *
FROM   QUERY_STATS_CURR_VW QS -- Queries from last data collection only
       --FROM   QUERY_STATS_VW QS -- Review queries for all data collections
       INNER JOIN FT_CTE2 FT2
               ON QS.QUERY_PLAN_HASH = FT2.QUERY_PLAN_HASH
WHERE  1 = 1
-- AND LAST_EXECUTION_TIME > 'XXXXXXX'   -- find all queries that have executed after a specific time
ORDER  BY TOTAL_ELAPSED_TIME DESC 


