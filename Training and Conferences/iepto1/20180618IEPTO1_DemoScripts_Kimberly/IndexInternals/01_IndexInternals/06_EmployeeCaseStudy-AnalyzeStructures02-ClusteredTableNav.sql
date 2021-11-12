/*============================================================================
  File:     EmployeeCaseStudy-AnalyzeStructures02-ClusteredTableNav.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  These scripts use some documented and some undocumented commands
            to dive deeper into the internals of SQL Server table structures.
            
            These samples are included as companion content and directly
            reference the IndexInternals sample database created for Chapter 
            6 of SQL Server 2008 Internals (MSPress).
			
			Script 02 of Analyze Structures is about navigating the
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

USE IndexInternals
go

-----------------------------------------------------------------------------
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

DBCC TRACEON  (3604) 
go

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