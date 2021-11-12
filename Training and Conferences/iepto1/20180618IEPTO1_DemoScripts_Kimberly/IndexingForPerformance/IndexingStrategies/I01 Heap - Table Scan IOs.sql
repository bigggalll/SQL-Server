/*============================================================================
  File:     Heap - Table Scan IOs.sql

  Summary:  This script shows the IOs caused by a HEAP that has
			forwarding pointers.

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

-- Use any "Test" Database with at Least 2GB Free Space.

-- USE JunkDB
-- go

SET STATISTICS IO OFF;
go

-- Turn Graphical Showplan ON (Ctrl+K)
SET NOCOUNT ON;
go

IF OBJECTPROPERTY(object_id('dbo.DemoTableHeap'), 'IsUserTable') = 1
	DROP TABLE dbo.DemoTableHeap;
go

CREATE TABLE dbo.DemoTableHeap
(
	col1	int	 		identity(100,10),
	col2	datetime 	CONSTRAINT DemoTableHeapCol2Default 
							DEFAULT current_timestamp, -- niladic
	col3	datetime 	CONSTRAINT DemoTableHeapCol3Default 
							DEFAULT getdate(),
	col4	char(30) 	CONSTRAINT DemoTableHeapCol4Default 
							DEFAULT suser_name(),
	col5	char(30)  	CONSTRAINT DemoTableHeapCol5Default 
							DEFAULT user_name(),
	col6	char(100)  	CONSTRAINT DemoTableHeapCol6Default 
							DEFAULT 'Long text value of "Now is the time for all good men to come to the aid of their country."',
	col7	varchar(200)  	CONSTRAINT DemoTableHeapCol7Default 
							DEFAULT 'small value'
);
go

DECLARE @EndTime	datetime;
SELECT @EndTime = dateadd(ss, 600, getdate());
WHILE getdate() <= @EndTime
BEGIN
	INSERT dbo.DemoTableHeap DEFAULT VALUES
END;
go

EXEC sp_spaceused 'dbo.DemoTableHeap', true;
go
-- Record the RowCount = 10839076                                                                                                                                                                                                                         
-- Figure out the number of pages by dividing "data" by 8
-- SELECT 2281912  / 8 = 285239    -- 285239
-- This SHOULD MATCH the I/Os shown by SELECT COUNT(*)

SET STATISTICS IO ON;
go

SELECT COUNT(*) AS 'RowCount' FROM dbo.DemoTableHeap;
go

-- Modify roughly 15% - keep track of the rows affected
UPDATE dbo.DemotableHeap
	SET col7 = 'This is a test to create some fragmentation. The previously small column is now filled to capacity. This is a test to create some fragmentation. The previously small column is now filled to capacity.'
	WHERE col1 % 7 = 0;
go

SELECT @@rowcount;
go

-- Keep track of Rows Affected Here = 1548439

-- Check the space again and calculate # of Pages
SET STATISTICS IO OFF;
go

EXEC sp_spaceused 'dbo.DemoTableHeap', true;
go

-- Figure out the number of pages by dividing "data" by 8
-- SELECT 2559000  / 8 =  319875 (1,012,598 actual??)
-- This SHOULD MATCH the I/Os shown by SELECT COUNT(*)

-- Does this match the I/Os shown by SELECT COUNT(*)
-- ??
SET STATISTICS IO ON;
go

SELECT COUNT(*) AS 'RowCount' FROM dbo.DemoTableHeap;
go

-- What does is equal?
-- Pages + Rows Modified that caused Forwarding Pointers
-- Do the math Total I/Os - Pages in Table = ???
-- select ACTUAL I/O - ACTUAL PAGES = EXCESS
-- So what does that number represent?

SELECT 1012598 - 319875
-- select 1332795 - 421024 = 911771
-- Forwarding Pointers!
-- A Forwarding Pointer is ALWAYS honored. This is a good thing for most operations
-- however, it is seemingly wrong for a table scan.

-- On SQL Server 2000, use:
-- DBCC SHOWCONTIG('dbo.DemoTableHeap') WITH TABLERESULTS
go

-- To confirm (this command ONLY works in SQL Server 2005+)
SELECT 'LIMITED', * 
	FROM sys.dm_db_index_physical_stats
		(db_id(), object_id('dbo.DemoTableHeap')
		    , DEFAULT, DEFAULT, 'LIMITED')
	-- Limited doesn't return
UNION ALL
SELECT 'SAMPLED' AS Type, * 
	FROM sys.dm_db_index_physical_stats
		(db_id(), object_id('dbo.DemoTableHeap')
		    , DEFAULT, DEFAULT, 'SAMPLED')
UNION ALL
SELECT 'DETAILED', * 
	FROM sys.dm_db_index_physical_stats
	    (db_id(), object_id('dbo.DemoTableHeap')
	        , default, DEFAULT, 'DETAILED')
go

ALTER TABLE dbo.DemoTableHeap REBUILD;
go

-- 5 seconds without nonclustered indexes...

UPDATE dbo.DemotableHeap
	SET col7 = 'BLAH is a test to create some fragmentation. The previously small column is now filled to capacity. This is a test to create some fragmentation. The previously small column is now filled to capacity.'
	WHERE col1 % 6 = 0;
go

SELECT @@rowcount;  --3613025 
go

CREATE NONCLUSTERED INDEX test1 ON dbo.DemotableHeap (col1);
go

CREATE NONCLUSTERED INDEX test2 ON dbo.DemotableHeap (col2)
go

CREATE NONCLUSTERED INDEX test3 ON dbo.DemotableHeap (col3)
go

CREATE NONCLUSTERED INDEX test4 ON dbo.DemotableHeap (col4)
go

ALTER TABLE dbo.DemoTableHeap REBUILD
go

-- REBUILD takes a lot more time with additional nonclustered indexes