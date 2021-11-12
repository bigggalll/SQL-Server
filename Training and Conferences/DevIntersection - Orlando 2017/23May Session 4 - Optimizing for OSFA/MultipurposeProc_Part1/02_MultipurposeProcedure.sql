/*============================================================================
  File:     MultipurposeProcedure.sql

  Summary:  This is the start of the problem - the creation
            of the multipurpose / OSFA procedure.
  
  SQL Server Version: 2008+
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

-----------------------------------------------------
-- Procedure concept / overview
-----------------------------------------------------

-- A common problem with performance is around 
-- 'multipurpose procedures' where the procedure is
-- supposed to be a "one-size-fits-all" proc (or, OSFA 
-- proc).

-- Typically, the developer has a complicated number
-- of possible parameters supplied in order to 
-- "search" for a row. 

-- The dialog in the application gives ALL of the 
-- options and then they handle the request with only
-- a single procedure.

-- The resulting statement in procedure often looks 
-- like this:

-- WHERE (column1 = variable1 OR variable1 IS NULL)
--	 AND (column2 = variable2 OR variable2 IS NULL)
--	 AND (column3 = variable3 OR variable3 IS NULL)
--   ...
--	 AND (columnN = variableN OR variableN IS NULL)

-- This just can't end well. Sorry!

-----------------------------------------------------
-- The procedure specifics:
-----------------------------------------------------

-- We might look up members by:
--      member_no (unique)
--      lastname (allow wildcards?)
--      firstname (allow wildcards?)
--      middleinitial
--      email (allow wildcards?)
--      region_no (not selective)
--      member_code (not selective)

-- And the user can supply ANY combination 
-- of these parameters above. Some are selective; some
-- are horribly NOT selective. And, some of these
-- even support wildcards (sure, why not!).

-- And, because we're going to have these columns in
-- a WHERE clause, let's also make sure there's an 
-- index on each of these columns.

-- IMPORTANT NOTE:
-- I'm not saying this is a good idea but it's
-- often done to "help" these types of searches

USE [Credit];
GO

-- Add an index to SEEK for FirstNames
CREATE INDEX [MemberFirstName] 
ON [dbo].[member] ([FirstName]);
GO

-- Add an index to SEEK for LastNames
CREATE INDEX [MemberLastName] 
ON [dbo].[member] ([LastName]);
GO

-- Add an index to SEEK for Email
CREATE INDEX [MemberEmail] 
ON [dbo].[member] ([Email]);
GO

-- Add an index to SEEK for member_code
CREATE INDEX [MemberCode] 
ON [dbo].[member] ([member_code]);
GO

-- If you want to see all of the indexes currently on
-- the member table:
EXEC [sp_helpindex] '[dbo].[member]'
GO
-----------------------------------------------------
-- Create the 'oh-so-clever' OSFA procedure
-----------------------------------------------------

IF OBJECTPROPERTY (OBJECT_ID (N'dbo.GetMemberInformation')
    , N'IsProcedure') = 1
	DROP PROCEDURE [dbo].[GetMemberInformation];
GO

CREATE PROC [dbo].[GetMemberInformation]
(
    @member_no	INT = NULL
    , @Lastname	VARCHAR (15) = NULL
	, @Firstname	VARCHAR (15) = NULL
    , @MiddleInitial  letter = NULL
    , @EmailAddress VARCHAR(128) = NULL
    , @Region_no  numeric_id = NULL
    , @Member_code status_code = NULL
)
AS
SELECT [m].* FROM [dbo].[member] AS [m]
WHERE ([m].[member_no] = @member_no OR @member_no IS NULL)
    AND ([m].[lastname] LIKE @lastname OR @lastname IS NULL)
	AND ([m].[firstname] LIKE @firstname OR @firstname IS NULL)
    AND ([m].[middleinitial] = @MiddleInitial OR @MiddleInitial IS NULL)
    AND ([m].[Email] LIKE @EmailAddress OR @EmailAddress IS NULL)
    AND ([m].[region_no] = @Region_no OR @Region_no IS NULL)
    AND ([m].[member_code] = @Member_code OR @Member_code IS NULL);
GO

-- Let's try a couple of simple executions
EXEC [GetMemberInformation] @Lastname = 'Tripp';
GO  

EXEC [GetMemberInformation] @EmailAddress = '%27.com';
GO

EXEC [GetMemberInformation] @Member_no = 9912;
GO

-- Does it work?
-- Does it run fast?
-- We're done!




-- ********************************
-- **** PLAN STABILITY TESTING ****
-- ********************************

-- Turn Graphical Showplan on, plus:
SET STATISTICS IO ON;
SET STATISTICS time ON;
GO

-- Let's try a couple of simple executions
EXEC [GetMemberInformation] @Lastname = 'Tripp';
GO  

EXEC [GetMemberInformation] @EmailAddress = '%27.com';
GO

EXEC [GetMemberInformation] @Member_no = 9912;
GO

-- Yikes - that's not a great plan for ANY of them!
-- Definitely NOT a great plan for ALL of them!!

-- If you suspect that the plan wasn't for you?

EXEC [GetMemberInformation] @EmailAddress = '%27.com';
GO

EXEC [GetMemberInformation] @EmailAddress = '%27.com' WITH RECOMPILE;
GO

EXEC [GetMemberInformation] @Member_no = 9912;
GO

EXEC [GetMemberInformation] @Member_no = 9912 WITH RECOMPILE;
GO

-- NOTE: Some procedures do better than others when
-- adding WITH RECOMPILE. But, unfortunately, the
-- structure of this "multipurpose proc" is absolutely
-- one of the WORST.

-- Remember, look at:
-- * Time
-- * I/Os
-- * Plan (compiled v. runtime)

-- What happens with other executions?
-- Use script: MultipurposeProcedureExecutions_wDifferentParameters.sql