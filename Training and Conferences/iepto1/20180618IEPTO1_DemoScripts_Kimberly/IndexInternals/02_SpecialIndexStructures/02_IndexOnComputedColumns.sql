/*============================================================================
  File:     IndexOnComputedColumns.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  This script shows an example of an index on a computed
            column as described in Chapter 6 of SQL Server 2008 
            Internals.
  
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

USE AdventureWorks2008;
go

-----------------------------------------------------------------------------
-- Session settings
------------------------------------------------------------------------------

CREATE TABLE t1 
(
    a   INT,
    b   AS 2*a
);
go

-- Turn off two required session settings:
SET QUOTED_IDENTIFIER OFF;
SET ANSI_NULLs OFF;
go

-- Attempt to create an index on the computed column (b): 
CREATE INDEX i1 
ON t1 (b);
go

-- Turn quoted_identifier back on:
SET QUOTED_IDENTIFIER ON;
go

-- Attempt to create an index on the computed column (b): 
CREATE INDEX i1 
ON t1 (b);
go

-- Turn quoted_identifier back on:
SET ANSI_NULLs ON;
go

-- Finally, success! 
CREATE INDEX i1 
ON t1 (b);
go


-----------------------------------------------------------------------------
-- Deterministic Columns
------------------------------------------------------------------------------

CREATE TABLE t2 
(
    a   INT, 
    b   DATETIME,
    c   AS DATENAME(MM, b)
);
go

-- Attempt to create an index on a nondeterministic column:
CREATE INDEX i2 
ON t2 (c);
go

-- Check the column property for determinism:
SELECT COLUMNPROPERTY (OBJECT_ID('t2'), 'c', 'IsDeterministic');
go

-- Is the column indexable (but not why - if it's not):
SELECT COLUMNPROPERTY (OBJECT_ID('t2'), 'c', 'IsIndexable');
go

-- How about column a:
SELECT COLUMNPROPERTY (OBJECT_ID('t2'), 'a', 'IsIndexable');
go