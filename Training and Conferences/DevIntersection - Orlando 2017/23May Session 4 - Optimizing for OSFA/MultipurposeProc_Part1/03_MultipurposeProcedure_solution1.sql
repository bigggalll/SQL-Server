/*============================================================================
  File:     MultipurposeProcedures_Solution1.sql

  Summary:  Troubleshooting and solving a parameter sniffing problem
            usually results in using OPTION (RECOMPILE). I'm not
            against this (it can often be incredibly useful) BUT
            I want to caution you and stop you from using it everywhere
            and all the time. It can add up to a lot more CPU than
            you think... (more details in later demos)
  
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

USE [Credit];
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-----------------------------------------------------
-- Using OPTION (RECOMPILE)
-----------------------------------------------------

-- Will OPTION (RECOMPILE) save the day?

ALTER PROC [dbo].[GetMemberInformation]
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
    AND ([m].[member_code] = @Member_code OR @Member_code IS NULL)
OPTION (RECOMPILE);
GO

-- Let's try a couple of simple executions
EXEC [GetMemberInformation] @Lastname = 'Tripp';
GO  -- Now, it's an index SEEK!

EXEC [GetMemberInformation] @EmailAddress = '%27.com';
GO  -- Table scan... well, it's not a great search
    -- far fewer I/Os

EXEC [GetMemberInformation] @Member_no = 9912;
GO

-- Excellent! Everything has a great plan BUT
-- we're compiling EVERY execution.
-- What if this is executed tens of thousands of times an 
-- hour and by thousands of users...