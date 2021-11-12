/*============================================================================
  What happens to versions during a rebuild or a reorg?

  File:     Versions in REBUILD or REORG.sql

  Summary:  This script needs a temporary "junkdb" to create these objects. You
            should have at least 25-50 MB of free space for the inserts/rebuilds.
            
  Date:     May 2012

  SQL Server Version: 2005+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/


----------------------------------------------------------------------------
------------------------ LARGE ROW SCENARIO --------------------------------
----------------------------------------------------------------------------
SET NOCOUNT ON
go

ALTER DATABASE JunkDB
    SET READ_COMMITTED_SNAPSHOT OFF
    WITH ROLLBACK IMMEDIATE
go

ALTER DATABASE JunkDB
    SET ALLOW_SNAPSHOT_ISOLATION OFF
go

USE JunkDB
go

DROP TABLE TestVersions
go

CREATE TABLE TestVersions
(
    col1    int identity not null,
    col2    char(4035),
) -- Why? 4046 rows + 2 byte slot array
-- total 4048 means 2 per page
-- ask can the full 8096 be used?
go

CREATE UNIQUE CLUSTERED INDEX TestVersionsCL
    ON TestVersions (col1)
go

insert TestVersions
values ('abc')
go 126

SELECT * FROM sys.dm_db_index_physical_stats 
    (db_id(), object_id('TestVersions'), null, null, 'detailed')
go -- min, max, avg = 4046

-- This shows two things:
-- The limit of 8060 is ONLY for a single row, not multiple...
--(4 [header], 4 [col1], 3 [null block], 4035 = 4046 + 2 bytes in the slot array)

-- Now, let's turn versioning on

USE master
go

ALTER DATABASE JunkDB
    SET READ_COMMITTED_SNAPSHOT ON
    WITH ROLLBACK IMMEDIATE
go

USE JunkDB
go

-- Nothing's changed in terms of size....
SELECT * FROM sys.dm_db_index_physical_stats 
    (db_id(), object_id('TestVersions'), null, null, 'detailed')
go -- min, max, avg = 4046

-- Next, let's update some rows and check how the table's changed
UPDATE TestVersions
    SET col2 = 'def'
    WHERE col1 % 6 = 0
go

SELECT * FROM sys.dm_db_index_physical_stats 
    (db_id(), object_id('TestVersions'), null, null, 'detailed')
go 
--min_record_size_in_bytes	max_record_size_in_bytes	    avg_record_size_in_bytes
--4046	                    4060 (added 14 byte version)    4048.24

ALTER INDEX TestVersionsCL
    ON TestVersions REBUILD
go

--Versions all removed...
SELECT * FROM sys.dm_db_index_physical_stats 
    (db_id(), object_id('TestVersions'), null, null, 'detailed')
go -- min, max, avg = 4046


-- Next, let's update some rows and check how the table's changed
UPDATE TestVersions
    SET col2 = 'ghi'
    WHERE col1 % 7 = 0
go

ALTER INDEX TestVersionsCL
    ON TestVersions REBUILD
    WITH (ONLINE = ON)
go

--Versions all removed...
SELECT * FROM sys.dm_db_index_physical_stats 
    (db_id(), object_id('TestVersions'), null, null, 'detailed')
go -- min, max, avg = 4060
-- EVERY row got versioned!!


--min_record_size_in_bytes	max_record_size_in_bytes	    avg_record_size_in_bytes
--4046	                    4060 (added 14 byte version)    4048.24

-- What about a REORG
ALTER INDEX TestVersionsCL
    ON TestVersions REORGANIZE
go

UPDATE TestVersions
    SET col2 = 'jkl'
    WHERE col1 % 5 = 0
go

--Leaves existing version pointer (14 bytes) intact
SELECT * FROM sys.dm_db_index_physical_stats 
    (db_id(), object_id('TestVersions'), null, null, 'detailed')
go -- min, max, avg = 4060

----------------------------------------------------------------------------
------------------------ SMALL ROW SCENARIO --------------------------------
----------------------------------------------------------------------------
SET NOCOUNT ON
go

DROP TABLE TestVersionsSmallRow
go

CREATE TABLE TestVersionsSmallRow
(
    col1    int identity not null,
    col2    char(40),
)
go

CREATE UNIQUE CLUSTERED INDEX TestVersionsSmallRowCL
    ON TestVersionsSmallRow (col1)
go

insert TestVersionsSmallRow
values ('abc')
go 12500

SELECT * FROM sys.dm_db_index_physical_stats 
    (db_id(), object_id('TestVersionsSmallRow'), null, null, 'detailed')
go -- min, max, avg = 65 (4 [header], 4 [col1], 3 [null block], 40 [col2] + 14 [version] = 65)

-- Next, let's update some rows and check how the table's changed
UPDATE TestVersionsSmallRow
    SET col2 = 'def'
    WHERE col1 % 6 = 0
go

SELECT * FROM sys.dm_db_index_physical_stats 
    (db_id(), object_id('TestVersionsSmallRow'), null, null, 'detailed')
go 
--min_record_size_in_bytes	max_record_size_in_bytes	    avg_record_size_in_bytes
-- nothing changes because all of the rows were versioned when they were inserted!

ALTER INDEX TestVersionsSmallRowCL
    ON TestVersionsSmallRow REBUILD
go

--Versions all removed...
SELECT * FROM sys.dm_db_index_physical_stats 
    (db_id(), object_id('TestVersions'), null, null, 'detailed')
go -- min, max, avg = 65 (4 [header], 4 [col1], 3 [null block], 40 [col2] = 51)


-- Next, let's update some rows and check how the table's changed
UPDATE TestVersionsSmallRow
    SET col2 = 'ghi'
    WHERE col1 % 7 = 0
go

SELECT * FROM sys.dm_db_index_physical_stats 
    (db_id(), object_id('TestVersionsSmallRow'), null, null, 'detailed')
go 
--min_record_size_in_bytes	max_record_size_in_bytes	    avg_record_size_in_bytes
--  51	                        65	                            52.999

-- What about a REORG
ALTER INDEX TestVersionsSmallRowCL
    ON TestVersionsSmallRow REORGANIZE
go

--Versions all removed...
SELECT * FROM sys.dm_db_index_physical_stats 
    (db_id(), object_id('TestVersionsSmallRow'), null, null, 'detailed')
go 
--min_record_size_in_bytes	max_record_size_in_bytes	    avg_record_size_in_bytes
--  51	                        65	                            52.999
