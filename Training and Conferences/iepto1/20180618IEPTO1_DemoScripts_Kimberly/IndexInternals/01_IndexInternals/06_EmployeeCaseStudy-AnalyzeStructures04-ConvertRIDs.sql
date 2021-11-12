/*============================================================================
  File:     EmployeeCaseStudy-AnalyzeStructures04-ConvertRIDs.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  These scripts use some documented and some undocumented commands
            to dive deeper into the internals of SQL Server table structures.
            
            These samples are included as companion content and directly
            reference the IndexInternals sample database created for Chapter 
            6 of SQL Server 2008 Internals (MSPress).
			
			Script 04 of Analyze Structures is to create the convert_RIDs
			function to help in analyzing heap RIDs.
  
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

CREATE FUNCTION convert_RIDs (@rid BINARY(8))
RETURNS VARCHAR(30)
AS
BEGIN
    RETURN (
        CONVERT (VARCHAR(5),
            CONVERT(INT, SUBSTRING(@rid, 6, 1)
            + SUBSTRING(@rid, 5, 1)) )
        + ':' +
        CONVERT(VARCHAR(10),
            CONVERT(INT, SUBSTRING(@rid, 4, 1)
            + SUBSTRING(@rid, 3, 1)
            + SUBSTRING(@rid, 2, 1)
            + SUBSTRING(@rid, 1, 1)) )
        + ':' +
        CONVERT(VARCHAR(5),
            CONVERT(INT, SUBSTRING(@rid, 8, 1)
            + SUBSTRING(@rid, 7, 1)) ) )
END;
go

-- Using this function you can find EmployeeID of 6 because its
-- hexadecimal RID is 0xF500000001000500:

SELECT dbo.convert_RIDs (0xF500000001000500);
go

-- RESULT:
-- 1:245:5

-- Using the function, this converts to:
--      File ID 1
--      Page ID 245
--      Slot Number 5

-- To view this specific page, we can use DBCC PAGE and then review the data
-- in slot 5 (to see if this is in fact the row with EmployeeID of 6):

DBCC TRACEON (3604)
go

DBCC PAGE (IndexInternals, 1, 245, 3);
go


--Slot 5 Column 1 Offset 0x4 Length 4 Length (physical) 4

--EmployeeID = 6                       

--Slot 5 Column 2 Offset 0x8 Length 60 Length (physical) 60

--LastName = Anderson                                                       

-- ........