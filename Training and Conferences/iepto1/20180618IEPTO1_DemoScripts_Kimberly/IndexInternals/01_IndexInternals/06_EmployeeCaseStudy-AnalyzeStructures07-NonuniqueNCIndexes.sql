/*============================================================================
  File:     EmployeeCaseStudy-AnalyzeStructures07-NonuniqueNCIndexes.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  These scripts use some documented and some undocumented commands
            to dive deeper into the internals of SQL Server table structures.
            
            These samples are included as companion content and directly
            reference the IndexInternals sample database created for Chapter 
            6 of SQL Server 2008 Internals (MSPress).
			
			Script 07 of Analyze Structures is about the index structure of
			nonunique nonclustered indexes.
  
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

CREATE NONCLUSTERED INDEX TestTreeStructure
ON Employee (SSN);
go

CREATE UNIQUE NONCLUSTERED INDEX TestTreeStructureUnique1
ON Employee (SSN);
go

CREATE UNIQUE NONCLUSTERED INDEX TestTreeStructureUnique2
ON Employee (SSN, EmployeeID);
go

SELECT si.[name] AS iname
    , index_depth AS D
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
    , NULL
    , NULL
    , 'DETAILED') AS ps
    INNER JOIN sys.indexes AS si
        ON ps.[object_id] = si.[object_id]
            AND ps.[index_id] = si.[index_id]
WHERE ps.[index_id] > 2;
go

-- The first index has the EmployeeID added because it’s the
-- clustering key (therefore the bookmark). The third index 
-- has EmployeeID already in the index—there’s no need to add 
-- it again. However, in the first index, because it was not
-- defined as unique, SQL Server had to add the clustering key 
-- all the way up the tree. For the second index—which was 
-- unique on SSN alone—SQL Server did not include EmployeeID all
-- the way up the tree. 

-- If you’re interested, you can continue to analyze these 
-- structures using DBCC IND and DBCC PAGE to view the physical 
-- row structures further.