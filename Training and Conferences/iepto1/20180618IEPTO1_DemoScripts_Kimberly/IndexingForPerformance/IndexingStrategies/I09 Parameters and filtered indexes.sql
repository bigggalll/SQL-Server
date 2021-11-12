/*============================================================================
  Summary: Filtered Indexes (and filtered stats) are NOT accessible to
	forced parameterization OR parameterized plans (in procs).
	But, there is a work-around to add OPTION (RECOMPILE).
  
  SQL Server Version: SQL Server 2008+
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

SET NOCOUNT ON;
GO

USE JunkDB; -- you can use any "work area" database
GO

IF OBJECTPROPERTY (OBJECT_ID (
	N'[dbo].[TestFilteredIndex]'), N'IsUserTable') IS NOT NULL
    DROP TABLE [dbo].[TestFilteredIndex];
GO

-- Create a test table
CREATE TABLE [dbo].[TestFilteredIndex]
(
       [id] INT IDENTITY(1,1) NOT NULL,
       [date] DATE NULL,
CONSTRAINT [PK_IF] PRIMARY KEY CLUSTERED 
(
       [id] ASC
));
GO

-- Insert some rows
INSERT INTO [dbo].[TestFilteredIndex] ([date]) 
	VALUES ('20140101');
GO 100

INSERT INTO [dbo].[TestFilteredIndex] ([date]) 
	VALUES ('20140115');
GO 1000

INSERT INTO [dbo].[TestFilteredIndex] ([date]) 
	VALUES ('20140130');
GO 10000

-- See the data/distribution
SELECT COUNT (*), [DATE]
FROM [dbo].[TestFilteredIndex]
GROUP BY [date];
GO

-- Create a filtered index
CREATE NONCLUSTERED INDEX [FilteredIndexONTest] 
ON [dbo].[TestFilteredIndex] ([date] ASC)  
WHERE [date] < '20140113';
GO

-- Check the query plan for adhoc queries

SELECT [date]
  FROM [dbo].[TestFilteredIndex]
  WHERE [date] < '20140106'; -- uses the FI
GO

SELECT [date]
  FROM [dbo].[TestFilteredIndex]
  WHERE [date] < '20140110'; -- uses the FI
GO

SELECT[date]
  FROM [dbo].[TestFilteredIndex]
  WHERE [date] < '20140120'; -- does not use the FI
GO

--------------------------------------------
-- What about a stored procedure:
--------------------------------------------
--DROP TABLE Test;
--DROP PROCEDURE Test;
GO

CREATE PROCEDURE [test] (@d DATE) 
AS
BEGIN
  SELECT [date]
  FROM [dbo].[TestFilteredIndex] 
  WHERE [date] < @d;
END
GO

EXECUTE [test] '20140106';
EXECUTE [test] '20140110';
EXECUTE [test] '20140120';
GO

-- NONE of them use the filtered index!

--------------------------------------------
-- What about EXECUTE with RECOMPILE??
--------------------------------------------

EXECUTE [test] '20140106' with recompile;
EXECUTE [test] '20140110' with recompile;
EXECUTE [test] '20140120' with recompile;
GO

-- Nope, NONE of them use the filtered index!

--------------------------------------------
-- What about forcing the index:
--------------------------------------------
ALTER PROCEDURE [test] (@d DATE) 
AS
BEGIN
  SELECT [date]
  FROM [dbo].[TestFilteredIndex] 
	WITH (INDEX ([FilteredIndexONTest]))
  WHERE [date] < @d;
END
GO

EXECUTE [test] '20140106';
EXECUTE [test] '20140110';
EXECUTE [test] '20140120';
GO

--------------------------------------------
-- What about CREATE with RECOMPILE??
--------------------------------------------

ALTER PROCEDURE [test] (@d DATE) 
WITH RECOMPILE
AS
BEGIN
  SELECT [date]
  FROM [dbo].[TestFilteredIndex] 
  WHERE [date] < @d;
END
GO

EXECUTE [test] '20140106';
EXECUTE [test] '20140110';
EXECUTE [test] '20140120';
GO
-- NONE of them use the filtered index!

--------------------------------------------
-- What about OPTION RECOMPILE??
--------------------------------------------

-- NOTE: This WORKS in 2012 and 2008 BUT 
-- NOT 2008 R2 until SP1 AND, it's OPTION 
-- RECOMPILE that works NOT CREATE WITH RECOMPILE

ALTER PROCEDURE [test] (@d DATE)
AS
BEGIN
  SELECT [date]
  FROM [dbo].[TestFilteredIndex] 
  WHERE [date] < @d
  OPTION (RECOMPILE);
END
GO

EXECUTE [test] '20140106';
EXECUTE [test] '20140110';
EXECUTE [test] '20140120';
GO

--------------------------------------------
-- What about OPTION (OPTIMIZE FOR ...)??
--------------------------------------------

ALTER PROCEDURE [test] (@d DATE)
AS
BEGIN
  SELECT [date]
  FROM [dbo].[TestFilteredIndex] 
  WHERE [date] < @d
  OPTION (OPTIMIZE FOR (@d = '20140106'));
END
GO

EXECUTE [test] '20140106';
EXECUTE [test] '20140110';
EXECUTE [test] '20140120';
GO

-- NONE of them use the filtered index!

-------------------------------------------
-- How do you resolve this??
-- DSE
--------------------------------------------

ALTER PROCEDURE [test] (@d DATE) 
AS
BEGIN
DECLARE @ExecStr    NVARCHAR (1000);
SELECT @ExecStr 
	= N' SELECT [date]'
	+ N' FROM [dbo].[TestFilteredIndex]'
	+ N' WHERE [date] < ''' 
	+ CONVERT (NVARCHAR, @d) + '''';
EXEC (@ExecStr);
END
GO

EXECUTE [test] '20140106';
EXECUTE [test] '20140110';
EXECUTE [test] '20140120';
GO

--------------------------------------------
-- What about SQL Injection and DSE?
--------------------------------------------

-- For more info: https://www.sqlskills.com/blogs/kimberly/little-bobby-tables-sql-injection-and-execute-as/
CREATE USER [User_test] 
WITHOUT LOGIN;
GO
 
GRANT SELECT ON [dbo].[TestFilteredIndex] 
TO [User_test];
GO
 
ALTER PROCEDURE [test]
(
      @d DATE
)
WITH EXECUTE AS N'User_test'
AS
DECLARE @ExecStr    NVARCHAR (1000);
SELECT @ExecStr 
	= N' SELECT [date]'
	+ N' FROM [dbo].[TestFilteredIndex]'
	+ N' WHERE [date] < ''' 
	+ CONVERT (NVARCHAR, DATEADD (dd, 0, @d)) 
	+ '''';
EXEC (@ExecStr);
GO

-- Turn OFF showplan first (User_test doesn't have rights)
-- OR, grant rights

GRANT SHOWPLAN TO [User_test];
GO

EXECUTE [test] '20140106';
EXECUTE [test] '20140110';
EXECUTE [test] '20140120';
GO

--------------------------------------------
-- What if the filtered index would be 
-- accessed by a literal (and not a parameter)
--
-- Here SQL Server CAN use the FI
--------------------------------------------
ALTER PROCEDURE [test] (@d DATE)
AS
SET NOCOUNT ON
BEGIN
IF @d < '20140113'
	BEGIN
	  SELECT [date]
	  FROM [dbo].[TestFilteredIndex] 
	  WHERE [date] < @d AND [date] < '20140113'
	END
ELSE
	BEGIN
		SELECT [date]
		FROM [dbo].[TestFilteredIndex] 
		WHERE [date] < @d 
	END
END
GO

EXECUTE [test] '20140106';
EXECUTE [test] '20140110';
EXECUTE [test] '20140120';
GO

--------------------------------------------
-- What if the filtered index would be 
-- accessed by a variable (and not a parameter)
--
-- Here the value is UNKNOWN... SQL Server
-- CANNOT use a filtered index!
--------------------------------------------

-- Variable is UNKNOWN so we can't trust it
ALTER PROCEDURE [test] (@d DATE)
AS
SET NOCOUNT ON
DECLARE @date	date = '20140113'
SELECT [date]
FROM [dbo].[TestFilteredIndex] 
WHERE [date] < @d AND [date] < @date
GO

EXECUTE [test] '20140106';
EXECUTE [test] '20140110';
EXECUTE [test] '20140120';
GO

--------------------------------------------
-- What if you can't give them showplan perms?
--------------------------------------------

SELECT [st].[text]
	, [qs].[query_hash]
	, [qs].[query_plan_hash]
	, [qs].[execution_count]
	, [qs].[plan_handle]
	, [qs].[statement_start_offset]
	, [qs].*
	, [qp].* 
FROM sys.dm_exec_query_stats AS [qs] 
	CROSS APPLY sys.dm_exec_sql_text ([sql_handle]) AS [st]
	CROSS APPLY sys.dm_exec_query_plan ([plan_handle]) AS [qp]
WHERE --[st].[text] LIKE '%WHERE [date] <%'
	([st].[text] NOT LIKE '%syscacheobjects%'
		OR [st].[text] NOT LIKE '%SELECT%cp.objecttype%')
ORDER BY 1, [qs].[execution_count] DESC;
GO

EXECUTE [test] '20140101';
GO

-- Run an adhoc version to get the query hash and query plan hash
-- You can check/compare the query plan hash for the statement
SELECT [date] 
FROM [dbo].[TestFilteredIndex] AS ADHOCVER 
WHERE [date] < '20140106';
GO

SELECT [st].[text]
	, [qs].[query_hash]
	, [qs].[query_plan_hash]
	, [qs].[execution_count]
	, [qs].[plan_handle]
	, [qs].[statement_start_offset]
	, [qs].*
	, [qp].* 
FROM sys.dm_exec_query_stats AS [qs] 
	CROSS APPLY sys.dm_exec_sql_text ([sql_handle]) AS [st]
	CROSS APPLY sys.dm_exec_query_plan ([plan_handle]) AS [qp]
WHERE [st].[text] LIKE '%ADHOCVER%'
	AND ([st].[text] NOT LIKE '%syscacheobjects%'
		OR [st].[text] NOT LIKE '%SELECT%cp.objecttype%')
ORDER BY 1, [qs].[execution_count] DESC;
GO