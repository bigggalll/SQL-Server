/*============================================================================
  File:     EmployeeCaseStudy-AnalyzeStructures03-Heap.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  These scripts use some documented and some undocumented commands
            to dive deeper into the internals of SQL Server table structures.
            
            These samples are included as companion content and directly
            reference the IndexInternals sample database created for Chapter 
            6 of SQL Server 2008 Internals (MSPress).
			
			Script 03 of Analyze Structures is about analyzing the
			EmployeeHeap table.
  
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

------------------------------------------------------------------------------
-- Analyze the EmployeeHeap Structure 
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
    , OBJECT_ID ('IndexInternals.dbo.EmployeeHeap')
    , 0
    , NULL
    , 'DETAILED');
go

-- To see all of the index IDs for a table, query sys.indexes:
SELECT object_name(object_id) AS 'Object Name'
    , index_id AS 'Index ID'
    , name AS 'Index Name'
    , type_desc AS 'Type Description'
FROM sys.indexes
WHERE object_id = object_id('EmployeeHeap')

-- For nonclustered indexes, use the index ID for parameter 3.
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
    , OBJECT_ID ('IndexInternals.dbo.EmployeeHeap')
    , 2
    , NULL
    , 'DETAILED');
go

-- To see the data stored more specifically, we can use DBCC IND to
-- review the leaf-level pages of index ID 2:

TRUNCATE TABLE sp_tablepages;
INSERT sp_tablepages
EXEC ('DBCC IND (IndexInternals, EmployeeHeap, 2)');
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

-- The first page of the leaf level is on page 8,544 of File ID 1. 
-- To review the data on this page, we can use DBCC PAGE with output style 3.
DBCC PAGE (IndexInternals, 1, 8544, 3);
GO