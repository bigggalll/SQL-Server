/*============================================================================
  File:     Using-sys.dm_db_index_physical_stats.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  This script shows examples of how to use the DMV
            sys.dm_db_index_physical_stats as described in 
            Chapter 6 of SQL Server 2008 Internals.
  
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

------------------------------------------------------------------------------
-- Probably not what you want, but you can run this against all databases and 
-- all tables within those databases:
------------------------------------------------------------------------------
SELECT * 
FROM sys.dm_db_index_physical_stats (NULL, NULL, NULL, NULL, NULL);
go

------------------------------------------------------------------------------
-- To limit it, you can specify a database - be sure to enter in the correct 
-- name!
------------------------------------------------------------------------------
SELECT * 
FROM sys.dm_db_index_physical_stats(DB_ID ('AdventureWorks208'), NULL, NULL, NULL, NULL);
go


------------------------------------------------------------------------------
-- As per the Books Online, but updated here. You can avoid this issue by
-- capturing the IDs into variables and error-checking the values in the 
-- variables before calling the DMV, as shown in this code:
------------------------------------------------------------------------------
DECLARE @db_id SMALLINT; 
DECLARE @object_id INT; 
 
SET @db_id = DB_ID (N'AdventureWorks2008'); 
SET @object_id = OBJECT_ID (N'AdventureWorks2008.Person.Address'); 
 
IF (@db_id IS NULL OR @object_id IS NULL)
BEGIN
    IF @db_id IS NULL 
    BEGIN 
        PRINT N'Invalid database'; 
    END; 
    ELSE IF @object_id IS NULL 
    BEGIN 
        PRINT N'Invalid object'; 
    END
END
ELSE
SELECT * 
FROM sys.dm_db_index_physical_stats  
    (@db_id, @object_id, NULL, NULL, NULL);
go


------------------------------------------------------------------------------
-- More insidious are object name problems...
-- Be careful, if you're trying to specify the database but you don't 
-- properly set the database (or fully qualify the object name). In this
-- case the object doesn't exist and therefore the DMV fails.
------------------------------------------------------------------------------
USE AdventureWorks2008;
go

SELECT *
FROM sys.dm_db_index_physical_stats
    (DB_ID (N'pubs')
    , OBJECT_ID (N'dbo.authors')
    , NULL
    , NULL
    , NULL);
go


------------------------------------------------------------------------------
-- Stranger still - what if the object does exist?! 
-- But, it has a different ID - so, this should still fail!
------------------------------------------------------------------------------
USE AdventureWorks2008;
go

CREATE TABLE dbo.authors
(
    ID      CHAR(11), 
    name    VARCHAR(60)
);
go

SELECT *
FROM sys.dm_db_index_physical_stats
    (DB_ID (N'pubs')
    , OBJECT_ID (N'dbo.authors')
    , NULL
    , NULL
    , NULL);
go


------------------------------------------------------------------------------
-- Here are some extended examples using this DMV - not directly described
-- in the chapter. Enjoy!
------------------------------------------------------------------------------
USE master;
go

-- All base objects, ALL databases (already heard the warning above :)
SELECT * 
FROM sys.dm_db_index_physical_stats
	(NULL
	, NULL
	, NULL
	, NULL
	, NULL);
go

-- All base objects, *only* in specified database
SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id('AdventureWorks2008')
	, NULL
	, NULL
	, NULL
	, NULL);
go

-- All base objects, *only* in specified database (same as the prior example 
-- because NULL and DEFAULT have same meaning within this function).
SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id('AdventureWorks2008')
	, DEFAULT
	, DEFAULT
	, DEFAULT
	, DEFAULT);
go

-- Specified object, in specified database
-- NOTE: Must use FULLY qualified names if executing
-- outside of the database.
SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id('AdventureWorks2008')
	, object_id('AdventureWorks2008.person.person')
	, NULL
	, NULL
	, NULL);
go

-- All previous executions use the default MODE of 'Limited'
-- Specifying limited doesn't change the results...

-- Limited returns the fragmentation of the leaf level only - 
-- with only the external (left/right) fragmentation details.
-- Places an IS lock on table. 
-- Concurrent modifications (except X-Table lock) ARE allowed.

USE AdventureWorks2008;
go

SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id()
	, object_id('person.person')
	, NULL
	, NULL
	, 'LIMITED');
go

-- Sampled returns details about only the leaf level 
-- but includes internal fragmentation as well as external.
-- Useful on larger tables as it does NOT read the entire
-- table. Good for a detailed (relatively fast) estimate.
-- Places an IS lock on table. 
-- Concurrent modifications (except X-Table lock) ARE allowed.
USE AdventureWorks2008;
go

SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id()
	, object_id('person.person')
	, NULL
	, NULL
	, 'SAMPLED');
go

-- Detailed returns after a thorough evaluation of ALL
-- levels of an index, including the b-tree. However, this
-- may take a considerable amount of time and essentially
-- cycle your cache (if run over many tables). 
USE AdventureWorks2008;
go

SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id()
	, object_id('person.person')
	, NULL
	, NULL
	, 'DETAILED');
go

-- What about partitions?
-- One requirement is that you MUST state the index
-- for which you want to see partitions.
USE AdventureWorks2008;
go

SELECT * 
FROM sys.dm_db_index_physical_stats
	(db_id()
	, object_id('Production.TransactionHistory')
	, 1
	, 8
	, 'DETAILED');
go
