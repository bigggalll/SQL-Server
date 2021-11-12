/*============================================================================
  File:     EmployeeCaseStudy-AnalyzeStructures01-ClusteredTable.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  These scripts use some documented and some undocumented commands
            to dive deeper into the internals of SQL Server table structures.
            
            These samples are included as companion content and directly
            reference the IndexInternals sample database created for Chapter 
            6 of SQL Server 2008 Internals (MSPress).
			
			Script 01 of Analyze Structures is about analyzing the
			Clustered index on the Employee table.
  
  Date:     April 2009
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE [IndexInternals];
GO

------------------------------------------------------------------------------
-- Analyze the Employee Table's Clustered Index
------------------------------------------------------------------------------

SELECT index_depth AS D
    , index_level AS L
    , record_count AS 'Count'
    , page_count AS PgCnt
    , avg_page_space_used_in_percent AS 'PgPercentFull'
    , min_record_size_in_bytes AS 'MinLen'
    , max_record_size_in_bytes AS 'MaxLen'
    , avg_record_size_in_bytes AS 'AvgLen'
FROM sys.dm_db_index_physical_stats
    (DB_ID ('IndexInternals')
    , OBJECT_ID ('IndexInternals.dbo.Employee')
    , 1
    , NULL
    , 'DETAILED');
go

TRUNCATE TABLE sp_tablepages;
INSERT sp_tablepages
EXEC ('DBCC IND (IndexInternals, Employee, 1)');
go

SELECT IndexLevel
    , PageFID
    , PagePID
    , PrevPageFID
    , PrevPagePID
    , NextPageFID
    , NextPagePID
FROM sp_tablepages
ORDER BY IndexLevel DESC, PrevPagePID;
GO

------------------------------------------------------------------------------
-- Reviewing that output 
-- The root page will have the highest IndexLevel. Because of 
-- the ORDER BY it will be the first row in the output.

-- The root page will reference all of the pages in the next level down.
-- Each of those pages will reference a number of pages in the next level down
-- until you reach the leaf level. Using DBCC PAGE, you should be able
-- to completely reverse-engineer the entire index structure shown in
-- Figure 6-2: Page details for multiple index levels
------------------------------------------------------------------------------

DBCC TRACEON  (3604) 
go

DBCC PAGE (IndexInternals, 1, 234, 3) -- first page of level 2
	-- 7 rows, this shows the 7 pages (in order) of the intermediate level

-- Analyze the intermediate level (which also points to the leaf)
DBCC PAGE (IndexInternals, 1, 232, 3) -- first page of level 1 (622 rows)
DBCC PAGE (IndexInternals, 1, 233, 3) -- second page of level 1 (622 rows)
DBCC PAGE (IndexInternals, 1, 235, 3) -- third page of level 1 (622 rows)
DBCC PAGE (IndexInternals, 1, 236, 3) -- fourth page of level 1 (622 rows)
DBCC PAGE (IndexInternals, 1, 237, 3) -- fifth page of level 1 (622 rows)
DBCC PAGE (IndexInternals, 1, 238, 3) -- sixth page of level 1 (622 rows)
DBCC PAGE (IndexInternals, 1, 239, 3) -- LAST page of level 1 (268 rows)

-- Analyze the leaf level (which IS the data)
DBCC PAGE (IndexInternals, 1, 168, 3) -- first page of level 0
DBCC PAGE (IndexInternals, 1, 169, 3) -- second page of level 0
DBCC PAGE (IndexInternals, 1, 170, 3) -- third page of level 0
-- ...
DBCC PAGE (IndexInternals, 1, 4231, 3) -- LAST page of level 0


------------------------------------------------------------------------------
-- Navigate the Employee Table's Clustered Index to find a row
------------------------------------------------------------------------------

-- How would SQL Server find this data?
SELECT e.*
FROM dbo.Employee AS e
WHERE e.EmployeeID = 27682;

-- SQL Server starts at the root page and navigates down to the leaf level. 
-- Based on the output shown previously, the root page is page 234 in File 
-- ID 1 (you can see this because the root page is the only page at the 
-- highest index level (IndexLevel = 2). 

DBCC PAGE (IndexInternals, 1, 234, 3) -- first page of level 2
go

-- For the third page, you can see a low value of 24,881, and for the fourth 
-- page, a low value of 37,321. So if the value 27,682 exists, it would have 
-- to be in the index area defined by this particular range.

DBCC PAGE (IndexInternals, 1, 235, 3);
go

-- Review the values. For the 141st row, you can see a low value of 27,681, 
-- and for the 142nd row, a low value of 27,701. So if the value 27,682 exists, 
-- it would have to be on ChildFileId = 1 and ChildPageId = 1616.

DBCC PAGE (IndexInternals, 1, 1616, 3);
go

-- By scanning this page, you can see that a record of 27,682 does exist and it
-- represents a record for Burt R Arbariol.