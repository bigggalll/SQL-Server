/*============================================================================
  File:     EmployeeCaseStudy-TableDefinition.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  Review the table definition of the Employee Table - as described 
            in Chapter 6 of SQL Server 2008 Internals.
  
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

-- These samples use the IndexInternals database as included with the companion
-- content. Please restore this database and REVIEW these definitions. 
--
-- Do not execute this entire script. 
--
-- Instead, execute only the sp_help lines (LINES 60-64 and LINES 95-99) 
-- to review the already created structures inside the IndexInternals database.

------------------------------------------------------------------------------
-- Creating the Employee table, its clustered index and the nonclustered
-- index on SSN.
------------------------------------------------------------------------------

CREATE TABLE Employee
(
EmployeeID		Int				NOT NULL	Identity,
LastName		nchar(30)		NOT NULL,   -- created as fixed width to make our row size exactly 400 bytes (to simplify the math/visualization)
FirstName		nchar(29)		NOT NULL,
MiddleInitial	nchar(1)		NULL,
SSN				char(11)		NOT NULL,
OtherColumns	char(258)		NOT NULL	DEFAULT 'Junk'
);
go

-- Add the clustered index
ALTER TABLE Employee
	ADD CONSTRAINT EmployeePK
		PRIMARY KEY CLUSTERED (EmployeeID)
ON [PRIMARY];
go

-- Add the nonclustered unique key
ALTER TABLE Employee
	ADD CONSTRAINT SSNUK
		UNIQUE NONCLUSTERED (SSN);
go

USE IndexInternals;
go

sp_help Employee;
go

select * from employee

------------------------------------------------------------------------------
-- Later in the chapter, a heap structure is used for analysis. The
-- following lines show its creation, a nonclustered primary key (and index)
-- and the nonclustered index on SSN.
------------------------------------------------------------------------------

CREATE TABLE EmployeeHeap
(
    EmployeeID      INT         NOT NULL    IDENTITY,
    LastName        NCHAR(30)   NOT NULL,
    FirstName       NCHAR(29)   NOT NULL,
    MiddleInitial   NCHAR(1)    NULL,
    SSN             CHAR(11)    NOT NULL,
    OtherColumns    CHAR(258)   NOT NULL    DEFAULT 'Junk');
go

-- Add a nonclustered PRIMARY KEY for EmployeeHeap
ALTER TABLE EmployeeHeap
    ADD CONSTRAINT EmployeeHeapPK
        PRIMARY KEY NONCLUSTERED (EmployeeID);
go

-- Add the nonclustered UNIQUE KEY on SSN for EmployeeHeap
ALTER TABLE EmployeeHeap
    ADD CONSTRAINT SSNHeapUK
        UNIQUE NONCLUSTERED (SSN);
go

Use IndexInternals
go

sp_help EmployeeHeap
go

--set identity_insert Employee on

--INSERT employee (EmployeeID, LastName, SSN, FirstName)
--    values (-1, 'Tripp', '123-45-6789', 'Kimberly')

