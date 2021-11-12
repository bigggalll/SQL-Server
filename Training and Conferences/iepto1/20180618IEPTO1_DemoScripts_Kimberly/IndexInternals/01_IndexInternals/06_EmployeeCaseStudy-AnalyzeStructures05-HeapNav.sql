/*============================================================================
  File:     EmployeeCaseStudy-AnalyzeStructures05-HeapNav.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  These scripts use some documented and some undocumented commands
            to dive deeper into the internals of SQL Server table structures.
            
            These samples are included as companion content and directly
            reference the IndexInternals sample database created for Chapter 
            6 of SQL Server 2008 Internals (MSPress).
			
			Script 05 of Analyze Structures is about navigating the
			EmployeeHeap table using RIDs.
  
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

-- In Script 06_EmployeeCaseStudy-AnalyzeStructures03-Heap.sql
-- we found that the first page of the leaf level is page 8,544 of File ID 1. 
-- To review the data on this page, we can use DBCC PAGE with output style 3.

DBCC TRACEON (3604)
go

DBCC PAGE (IndexInternals, 1, 8544, 3);
go

-----------------------------------------------------------------------------
-- Navigate the EmployeeHeap from the nonclustered PK Index to find a row
------------------------------------------------------------------------------

SELECT e.*
FROM dbo.EmployeeHeap AS e
WHERE e.EmployeeID = 27682;
go

-- The first step is to go to the root page of the nonclustered index:
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
go

-- The Root Page is PageFID = 1, PagePID = 8608
DBCC PAGE (IndexInternals, 1, 8608, 3);
go

-- Review the values. For the 52nd row, you can see a low value of 27,490, 
-- and for the 53rd row, a low value of 28,029. So if the value 27,682 exists, 
-- it would have to be on ChildFileId = 1 and ChildPageId = 8595.

DBCC PAGE (IndexInternals, 1, 8595, 3);
go

-- From this point, the navigation continues based on the RID. SQL Server 
-- translates the data row’s RID into the format of FileID:PageID:SlotNumber 
-- and proceeds to look up the corresponding data row in the heap.

-- The RID returned is: 0x2017000001000100

SELECT dbo.convert_RIDs (0x2017000001000100);
go

-- RESULT:
-- 1:5920:1

-- Using the function, this converts to:
--      File ID 1
--      Page ID 5920
--      Slot Number 1

-- To view this specific page, we can use DBCC PAGE and then review the data
-- in slot 1 (to see if this is in fact the row with EmployeeID of 27,682):

DBCC TRACEON (3604)
go

DBCC PAGE (IndexInternals, 1, 5920, 3);
go


--Slot 1 Column 1 Offset 0x4 Length 4 Length (physical) 4

--EmployeeID = 27682                   

--Slot 1 Column 2 Offset 0x8 Length 60 Length (physical) 60

--LastName = Arbariol                                                          

-- ........

