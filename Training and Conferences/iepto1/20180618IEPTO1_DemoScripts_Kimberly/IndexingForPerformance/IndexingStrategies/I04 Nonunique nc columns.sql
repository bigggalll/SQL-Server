/*============================================================================
  File:     Nonunique nc colums.sql

  Summary:  Understanding how a non-unique nonclustered index works
            vs. a unique nonclustered index.
  
  SQL Server Version: SQL Server 2008+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp & Paul S. Randal, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  written/presented by SQLskills.com  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- You can get my IndexInternals database from my Inside SQL Server 2008, Chapter 6 
-- sample database here: http://www.sqlskills.com/blogs/kimberly/companion-content-for-chapter-6-index-internals-of-sql-server-2008-internals/

USE IndexInternals
go

-- Remembering the point that SQL Server adds the clustering
-- key to the non-leaf (b-tree) levels of a nonclustered index
-- we're going to compare a non-unique NC index on SSN
-- against the constraint-based unique key.

-- Here's the non-unique test
CREATE INDEX test 
ON Employee (SSN)

-- Here's another index just to see what it does...
CREATE UNIQUE INDEX test2 
ON Employee (EmployeeID, SSN)

-- Using the DM, we can see the difference in the levels:
SELECT index_id, index_depth AS D
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
    , 'DETAILED');
go

-- Comments:
-- For a UNIQUE NC index
-- Non-leaf levels: Just the NC key
-- Leaf:            the NC key + the lookup value (CL key or Heap's RID)

-- For a NON-UNIQUE NC index
-- Non-leaf levels: the NC key + the lookup value (CL key or Heap's RID)
-- Leaf:            the NC key + the lookup value (CL key or Heap's RID)

-- Something else to help - use my tweaked version of sp_helpindex
sp_helpindex factinternetsales

-- You can get my version of sp_helpindex 
-- here: https://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/
EXEC sp_SQLskills_helpindex factinternetsales;
go

------ NC Index Examples from class ------ 
CREATE UNIQUE INDEX MemberCovering 
ON member(firstname, region_no, member_no)

--tree: firstname, region_no, member_no 
--leaf: firstname, region_no, member_no 


CREATE UNIQUE INDEX MemberCovering 
ON member(firstname)
INCLUDE (region_no)

--tree: firstname
--leaf: firstname, member_no, region_no 


CREATE UNIQUE INDEX MemberCovering 
ON member(firstname, member_no)
INCLUDE (region_no)

--tree: firstname, member_no
--leaf: firstname, member_no, region_no 

CREATE INDEX MemberCovering 
ON member(firstname)
INCLUDE (region_no, member_no)

--tree: firstname, member_no
--leaf: firstname, member_no, region_no 

CREATE INDEX MemberCovering 
ON member(firstname)
INCLUDE (region_no)

--tree: firstname, member_no
--leaf: firstname, member_no, region_no 

CREATE INDEX MemberCovering 
ON member(firstname, region_no, member_no)

--tree: firstname, member_no, region_no
--leaf: firstname, member_no, region_no 

--------- Other examples
--CL: c6, c8, c12

--NC unique: c5, c8, c2

--Tree: c5, c8, c2
--Leaf: c5, c8, c2, c6, c12

--NC non-unique: c5, c8, c2

--Tree: c5, c8, c2, c6, c12
--Leaf: c5, c8, c2, c6, c12