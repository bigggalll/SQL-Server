/*============================================================================
  File:     Generalizing the Tipping Point.sql

  Summary:  Various examples and ways to see the estimated and actual tipping
			point of when a nonclustered index is not used vs. doing a table
			scan.
  
  SQL Server Version: SQL Server 2005+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- Finding the *estimated* tipping point for every table:
USE <dbname>
go

SELECT OBJECT_NAME([ps].[object_id]) AS [TableName]
	, [ps].[record_count] AS [RowCount]
	, [ps].[page_count]
    , [ps].[page_count] * .25 AS [LowRangePages]
    , [ps].[page_count] * .33 AS [HighRangePages]
    , (([ps].[page_count] * .25)/[ps].[record_count] * 100) AS [LowRangeRows (Percent)]
    , (([ps].[page_count] * .33)/[ps].[record_count] * 100) AS [HighRangeRows (Percent)]
    , * 
FROM [sys].[dm_db_index_physical_stats] 
		(db_id(), null, null, null, 'SAMPLED') AS [ps]
WHERE [ps].[index_id] IN (0,1) 
	AND [ps].[page_count] > 100
ORDER BY [RowCount] DESC;
GO

-- What is your database's average?
SELECT DB_NAME(), AVG([tp].[LOW]) AS [Avg Low Percent]
	, AVG([tp].[High]) AS [Avg High Percent]
FROM (SELECT (([ps].[page_count] * .25)/[ps].[record_count] *100) AS [Low]
		, (([ps].[page_count] * .33)/[ps].[record_count] * 100) AS [High]
		FROM [sys].[dm_db_index_physical_stats] 
			(db_id(), null, null, null, 'SAMPLED') AS [ps]
		WHERE [ps].[index_id] IN (0,1) AND [ps].[page_count] > 100) AS [tp];
GO
	
-- What about the average across all databases on your server:
EXEC sp_msforeachdb ...

-- NNNNNNNOOOOOOOOOO!
-- No, just kidding Aaron ;-)
-- Check out Aaron's post: http://sqlblog.com/blogs/aaron_bertrand/archive/2010/12/29/a-more-reliable-and-more-flexible-sp-msforeachdb.aspx
-- And, of course, his better/more reliable sp_foreachdb (link to his code/download in the article above)
-- 


EXEC [sp_foreachdb] 'USE ?; SELECT DB_NAME(), AVG([tp].[LOW]) AS [Avg Low Percent]
	, AVG([tp].[High]) AS [Avg High Percent]
FROM (SELECT (([ps].[page_count] * .25)/[ps].[record_count] *100) AS [Low]
		, (([ps].[page_count] * .33)/[ps].[record_count] * 100) AS [High]
		FROM [sys].[dm_db_index_physical_stats] 
			(db_id(), null, null, null, ''SAMPLED'') AS [ps]
		WHERE [ps].[index_id] IN (0,1) AND [ps].[page_count] > 100) AS [tp]';
GO