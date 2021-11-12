/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

FIND_INDEXES_ON_TABLE
RESEARCH_INDEX_DENSITY
RESEARCH_INDEX_HISTOGRAM
INSERT_COMMENTS
FIND_QUERIES_WITH_COMMENTS
ALL_CAPTURESTATS_RUNS
FIND_QUERIES_USING_SPECIFIC_TABLE




********************************************************************/


USE DynamicsPerf


--
--		FIND_INDEXES_ON_TABLE
--
----------------------------------------------------------------
-- Find all the indexes on a specific table
----------------------------------------------------------------

SELECT * FROM INDEX_STATS_CURR_VW
WHERE TABLE_NAME = 'TABLE_NAME'
--and DATABASE_NAME = '<dbname>'
ORDER BY INDEX_KEYS 


--
--		RESEARCH_INDEX_DENSITY
--
-- --------------------------------------------------------------
--
-- Queries to investigae SQL Stats on all Indexes and Stats
-- 
-- Only stats for the last collection are kept in the database
-- 
----------------------------------------------------------------

USE DynamicsPerf

SELECT *
FROM   INDEX_DENSITY_VECTOR
WHERE  TABLENAME = 'TABLE_NAME'
	--AND DATABASE_NAME = 'DATABASENAME_HERE'


--
--		RESEARCH_INDEX_HISTOGRAM
--


SELECT *
FROM   INDEX_HISTOGRAM
WHERE  TABLE_NAME = 'TABLE_NAME'
	   AND COLUMN_NAME = 'COLUMN_NAME'
	  -- AND DATABASE_NAME = 'DATABASENAME_HERE'
	   
-- --------------------------------------------------------------
--
-- Query to investigae SQL Density on all Indexes 
-- 
-- Use this query with Trace Flag 4136 to determine how many
-- rows SQL thinks it will return for any 1 column
----------------------------------------------------------------
	   
;WITH Records_CTE (Database_Name,Tablename,Row_count)
AS
-- Define the CTE query.
(
    SELECT DISTINCT DATABASE_NAME, TABLE_NAME,ROW_COUNT
    FROM INDEX_STATS_CURR_VW
)

SELECT dv.DATABASE_NAME,dv.TABLENAME,INDEXNAME,dv.COLUMNS, Row_count, (1/DENSITY) as Number_of_Unique_Values,
Row_count / (1/DENSITY) as Avg_Rows_Per_Value
FROM   INDEX_DENSITY_VECTOR dv Inner join Records_CTE rows on dv.TABLENAME = rows.Tablename and dv.DATABASE_NAME = rows.Database_Name
WHERE  dv.TABLENAME = 'TABLE_NAME' and COLUMNS = 'COLUIMN_NAME'





----------------------------------------------------------------
-- Update the comments for the resolution to a query
-- Use this feature to document fixes and create the documentation
----------------------------------------------------------------

--
--  INSERT_COMMENTS
--


INSERT INTO [COMMENTS]
 ([QUERY_HASH],[AX_ROW_NUM],[CREATED_ON],[MODIFIED_ON],[CREATEDBY],[MODIFIEDBY],[TICKET_NUM],[COMPLETED],[COMPLETED_ON],[STATUS],[COMMENT])
 
     VALUES
           (0x000000000						--<QUERY_HASH> 0x000000000 Required if the comment is about a QUERY_STATS entry
           ,0								--AX_SQLTRACE Required if the comment is about an AX_SQLTRACE entry
           ,GETDATE()						--CREATED_ON
           ,GETDATE()						--MODIFIED_ON
           ,NULL							--Created by person
           ,NULL							--Modified by person
           ,''								--<TICKET_NUM, nvarchar(30)  Helpdesk ticket number
           ,'N'								--<COMPLETED, nvarchar(1),> Is this task completed
           ,'1/1/1900'						--<COMPLETED_ON, smalldatetime,> Date the task was completed
           ,'OPEN'							--<STATUS, nvarchar(max),>  Open format Text
           ,'ADD YOUR COMMENT HERE'			--<COMMENT, nvarchar(max),>) Open format text
           )
GO

UPDATE [DynamicsPerf].[dbo].[COMMENTS]
SET    [MODIFIED_ON] = Getdate(),
       [MODIFIEDBY] = NULL,
       [TICKET_NUM] = '',
       [COMPLETED] = 'N',
       [COMPLETED_ON] = '1/1/1900',
       [STATUS] = 'OPEN',
       [COMMENT] = Isnull(COMMENT, '') + 'ADD_COMMENT_HERE'
WHERE  [QUERY_HASH] = 0X000000
--WHERE [AX_ROW_NUM] = 000  -- Use this when adding comments for AX_SQLTRACE table

GO 


--
--		FIND_QUERIES_WITH_COMMENTS
--
--Display all records with comments, these records are never deleted


SELECT * FROM COMMENTS


--
--		ALL_CAPTURESTATS_RUNS
--
----------------------------------------------------------------
-- Display all data captures
----------------------------------------------------------------

SELECT *
FROM   STATS_COLLECTION_SUMMARY
ORDER  BY STATS_TIME DESC 




--
--		FIND_QUERIES_USING_SPECIFIC_TABLE
--

----------------------------------------------------------------
-- Find Queries referencing an object or field
----------------------------------------------------------------


SELECT TOP 100 *
FROM   QUERY_STATS_CURR_VW
WHERE  SQL_TEXT LIKE '%cust_%'
ORDER  BY TOTAL_ELAPSED_TIME DESC

