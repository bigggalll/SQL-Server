/*============================================================================
  File:     EmployeeCaseStudy-AnalyzeStructures06-NCIndexOnClusteredTable.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  These scripts use some documented and some undocumented commands
            to dive deeper into the internals of SQL Server table structures.
            
            These samples are included as companion content and directly
            reference the IndexInternals sample database created for Chapter 
            6 of SQL Server 2008 Internals (MSPress).
			
			Script 06 of Analyze Structures is about the key in a nonclustered
			index when created on a clustered table.
  
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

USE IndexInternals
go

-- To review the physical structures of a nonclustered index created 
-- on a table that is clustered, we review the UNIQUE constraint on 
-- the SSN column of the Employee table.

sp_helpindex Employee
go

sp_SQLskills_helpindex Employee;
EXEC sp_SQLskills_SQL2008_finddupes Employee;
go
-- To see the index ID assigned to this nonclustered index, we can 
-- use a query against sys.indexes:

SELECT name AS IndexName, index_id
FROM sys.indexes
WHERE [object_id] = OBJECT_ID ('Employee');
go

--RESULT:

-- IndexName        index_id
-- ---------------- --------
-- EmployeePK       1
-- EmployeeSSNUK    2


-- Another, more detailed query to see all of the index IDs for a 
-- table, query sys.indexes:
SELECT object_name(object_id) AS 'Object Name'
    , index_id AS 'Index ID'
    , name AS 'Index Name'
    , type_desc AS 'Type Description'
FROM sys.indexes
WHERE object_id = object_id('Employee')

-- Once we know the index ID then we can use that for parameter 3.

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
    , 2
    , NULL
    , 'DETAILED');
GO

-- Notice that the default behavior does NOT match our numbers...
-- Why? Because the table has not been upgraded to R2+ structures...

ALTER INDEX ALL ON [dbo].[employee] REBUILD;
GO

-- What if??
CREATE INDEX test1 ON Employee (SSN)
go

CREATE INDEX Test2 ON Employee (SSN, Employeeid)
go

CREATE UNIQUE INDEX Test3 ON Employee (SSN, Employeeid)
go

EXEC sp_helpindex Employee;
EXEC sp_SQLskills_helpindex Employee;
go

EXEC sp_SQLskills_SQL2008_finddupes Employee
go

-- The first step is to go to the root page of the nonclustered index:

TRUNCATE TABLE sp_tablepages;
INSERT sp_tablepages
EXEC ('DBCC IND (IndexInternals, Employee, 2)');
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
go

-- The Root Page is PageFID = 1, PagePID = 4328
DBCC TRACEON (3604)
go

DBCC PAGE (IndexInternals, 1, 13712, 3);
go

-- Leaf-level pages are labeled with an IndexLevel of 0
-- The first page of the leaf level is on page 4,264 of File ID 1. 
DBCC PAGE (IndexInternals, 1, 13706, 3);
go

-----------------------------------------------------------------------------
-- Navigate the Employee table from the nonclustered SSN Index to find a row
------------------------------------------------------------------------------

SELECT e.*
FROM dbo.Employee AS e
WHERE e.SSN = '123-45-6789'; -- '123-07-9786';
go

-- We already know the root page from above, PageFID = 1, PagePID = 4328
DBCC PAGE (IndexInternals, 1, 4328, 3);
go

-- Review the values. For the 24th row, you can see a low value of 123-07-8319, 
-- and for the 25th row, a low value of 140-02-4721. So if the value 123-45-6789 exists, 
-- it would have to be on ChildFileId = 1 and ChildPageId = 4287.

DBCC PAGE (IndexInternals, 1, 4287, 3);
go

-- Reviewing the output, does 123-45-6789 exist? 
--
-- NO. The values go from 
--  SSN: 123-07-9980 for EmployeeID 37281 TO
--  SSN: 140-00-0079 for EmployeeID	26561

-- NOTE: The data looks a bit strange but that because of 
--       how it was generated.  