-- Search through all available logs in one go
DECLARE @SearchString1 NVARCHAR(4000)
DECLARE @SearchString2 NVARCHAR(4000)
DECLARE @LogType INT

-- ------------------------------------------------------------------------------
-- User configurable settings - set up the search conditions here.

-- First search string (or leave blank for everything)
SET @SearchString1 = ''
-- Second search string (or leave blank for everything)
SET @SearchString2 = ''
-- Set log to be searched - 1=SQL Server log, 2=SQL Agent log
SET @LogType = 1
-- ------------------------------------------------------------------------------

-- Generate a list of all logs, and store in a temporary table.
CREATE TABLE #ListOfLogs (LogNumber INT, StartDate DATETIME, SizeInBytes INT)
INSERT INTO #ListOfLogs EXEC xp_enumerrorlogs @LogType

-- Iterate around all the logs gathering results
CREATE TABLE #Results (LogDate DATETIME,ProcessInfo NVARCHAR(4000),Test NVARCHAR(4000))
DECLARE @Count INT
SET @Count = 0
WHILE @Count <= (SELECT MAX(LogNumber) FROM #ListOfLogs)
  BEGIN
  INSERT INTO #Results EXEC xp_readerrorlog
     @Count
    ,@LogType             -- 1=SQL Server log, 2=SQL Agent log
    ,@SearchString1       -- Search string
    ,@SearchString2       -- 2nd search string
  SET @Count = @Count + 1
  END

-- Return the results from the temporary table.
SELECT * FROM #Results ORDER BY LogDate DESC

-- Tidy up.
DROP TABLE #ListOfLogs
DROP TABLE #Results