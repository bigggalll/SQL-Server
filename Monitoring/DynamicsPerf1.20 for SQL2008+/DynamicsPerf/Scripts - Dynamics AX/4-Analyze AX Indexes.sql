
/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

INDEXES_IN_DB_NOT_IN_AOT
INDEXES_WITH_RECVERSION

********************************************************************/


--
--			INDEXES_IN_DB_NOT_IN_AOT
--
-- --------------------------------------------------------------
-- Find INDEXES that are not defined in the AOT
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

SELECT *
FROM   INDEX_STATS_CURR_VW I
WHERE  INDEX_DESCRIPTION <> 'HEAP' AND INDEX_DESCRIPTION NOT LIKE '%FILTERED%'
       AND NOT EXISTS (SELECT *
                       FROM   AX_INDEX_DETAIL_CURR_VW A
                       WHERE  A.DATABASE_NAME = I.DATABASE_NAME
                              AND A.TABLE_NAME = I.TABLE_NAME
                              AND A.INDEX_NAME = I.INDEX_NAME)
ORDER  BY TABLE_NAME,
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
ORDER  BY TABLE_NAME,
          INDEX_NAME 




