/***********************************************************************************

This script is completly optional and only supported in SQL 2016.  There are no 
features in DynamicsPerf that use this data yet. 

************************************************************************************/



/**************************************************************************************************************************
	RUN the following in your application database
***************************************************************************************************************************/

ALTER DATABASE  SET QUERY_STORE = ON;
GO

--SELECT * FROM sys.database_query_store_options;  --Options already setup

ALTER DATABASE <database_name> 
SET QUERY_STORE (INTERVAL_LENGTH_MINUTES = 15);

GO

--Current storage settings
SELECT current_storage_size_mb, max_storage_size_mb 
FROM sys.database_query_store_options;

GO


ALTER DATABASE <database_name> 
SET QUERY_STORE (MAX_STORAGE_SIZE_MB = 8000);  --8GB


GO

/*  All options 

ALTER DATABASE <database name> 
SET QUERY_STORE (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = 
    (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 3000,
    MAX_STORAGE_SIZE_MB = 500,
    INTERVAL_LENGTH_MINUTES = 15,
    SIZE_BASED_CLEANUP_MODE = AUTO,
    QUERY_CAPTURE_MODE = AUTO
    MAX_PLANS_PER_QUERY = 1000
);

*/



--Cleanup Query Store
--ALTER DATABASE <db_name> SET QUERY_STORE CLEAR;


--Delete ad-hoc queries This deletes the queries that were only executed only once and that are more than 24 hours old.
/*

DECLARE @id int
DECLARE adhoc_queries_cursor CURSOR 
FOR 
SELECT q.query_id
FROM sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q 
    ON q.query_text_id = qt.query_text_id
JOIN sys.query_store_plan AS p 
    ON p.query_id = q.query_id
JOIN sys.query_store_runtime_stats AS rs 
    ON rs.plan_id = p.plan_id
GROUP BY q.query_id
HAVING SUM(rs.count_executions) < 2 
AND MAX(rs.last_execution_time) < DATEADD (hour, -24, GETUTCDATE())
ORDER BY q.query_id ;

OPEN adhoc_queries_cursor ;
FETCH NEXT FROM adhoc_queries_cursor INTO @id;
WHILE @@fetch_status = 0
    BEGIN 
        PRINT @id
        EXEC sp_query_store_remove_query @id
        FETCH NEXT FROM adhoc_queries_cursor INTO @id
    END 
CLOSE adhoc_queries_cursor ;
DEALLOCATE adhoc_queries_cursor;

*/

