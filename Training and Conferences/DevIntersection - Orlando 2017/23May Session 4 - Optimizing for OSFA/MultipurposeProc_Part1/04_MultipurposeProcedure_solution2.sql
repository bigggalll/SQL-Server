/*============================================================================
  File:     MultipurposeProcedures_Solution2.sql

  Summary:  Troubleshooting and solving a parameter sniffing problem
            usually results in using OPTION (RECOMPILE). I have a better
            option with a different coding style...
  
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

-----------------------------------------------------
-- Building the ultimate multipurpose procedure
-----------------------------------------------------

-- It all starts with constructing the string 
-- dynamically...

-- Option 1: Build the ENTIRE string dynamically
--           ONLY including non-NULL parameters
--           Execute using EXEC (@String)
--           This has the SAME result as using:
--           OPTION (RECOMPILE)
--           Each execution will turn into an ad hoc
--           statement
--             when safe -> parameterized and saved
--             when unsafe -> not saved, compiled every
--                            time

-- Option 2: Build the ENTIRE string dynmically
--           ONLY including non-NULL parameters
--           Execute using sp_executesql 
--           The good news is that MULTIPLE statements
--           will go into cache (one for every VERSION 
--           of the constructed query)
--           * Pro is that you will have multiple plans
--             and many might be great for many (possibly
--             all combinations)
--           * Some can still fall victim to parameter 
--             sniffing problems if the distribution of
--             the data is heavily un-even OR if the 
--             parameters create wildly varying result
--             sets (predicates such as LIKE, >, < can
--             be more prone to these problems)

-- Best Option - Option 2... with a programmatic twist!

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
IF (@member_no IS NULL
    AND @Lastname IS NULL
	AND @Firstname IS NULL
    AND @MiddleInitial IS NULL
    AND @EmailAddress IS NULL
    AND @Region_no IS NULL
    AND @Member_code IS NULL)
BEGIN
	RAISERROR ('You must supply at least one parameter.', 16, -1);
    RETURN;
END;

DECLARE @spexecutesqlStr	NVARCHAR (4000),
        @Recompile  BIT = 1;

SELECT @spexecutesqlStr =
	N'SELECT [m].* FROM [dbo].[member] AS [m] WHERE 1=1';

IF @member_no IS NOT NULL
	SELECT @spexecutesqlStr = @spexecutesqlStr 
		+ N' AND [m].[member_no] = @MemberNo';

IF @LastName IS NOT NULL
	SELECT @spexecutesqlStr = @spexecutesqlStr 
		+ N' AND [m].[lastname] LIKE @LName'; 

IF @FirstName IS NOT NULL
	SELECT @spexecutesqlStr = @spexecutesqlStr 
		+ N' AND [m].[firstname] LIKE @FName';

IF @MiddleInitial IS NOT NULL
	SELECT @spexecutesqlStr = @spexecutesqlStr 
		+ N' AND [m].[middleinitial] = @MI';

IF @EmailAddress IS NOT NULL
	SELECT @spexecutesqlStr = @spexecutesqlStr 
		+ N' AND [m].[email] LIKE @Email';

IF @Region_no IS NOT NULL
	SELECT @spexecutesqlStr = @spexecutesqlStr 
		+ N' AND [m].[region_no] = @RegionNo';

IF @Member_code IS NOT NULL
	SELECT @spexecutesqlStr = @spexecutesqlStr 
		+ N' AND [m].[member_code] = @MemberCode';

-- Conditions that you know could cause MANY rows
-- to be returned.        
IF (@member_no IS NOT NULL)
    SET @Recompile = 0

IF (PATINDEX('%[%_]%', @LastName) >= 4 
        OR PATINDEX('%[%_]%', @LastName) = 0)
    AND (PATINDEX('%[%_]%', @FirstName) >= 4
        OR PATINDEX('%[%_]%', @FirstName) = 0)
    SET @Recompile = 0

IF (PATINDEX('%[%_]%', @EmailAddress) >= 10 
        OR PATINDEX('%[%_]%', @EmailAddress) = 0)
    SET @Recompile = 0

IF @Recompile = 1
    SELECT @spexecutesqlStr = @spexecutesqlStr + N' OPTION(RECOMPILE)';

-- This is just for testing / review    
SELECT @spexecutesqlStr, @Lastname, @Firstname, @member_no;

EXEC [sp_executesql] @spexecutesqlStr
    , N'@MemberNo int, @LName varchar(15), @FName varchar(15)
    , @MI letter, @Email nvarchar(128), @RegionNo numeric_id
    , @MemberCode status_code'
	, @MemberNo = @Member_no
    , @LName = @Lastname
	, @FName = @Firstname
    , @MI = @MiddleInitial
    , @Email = @EmailAddress
    , @RegionNo = @Region_no
    , @MemberCode = @Member_code;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Let's try a couple of executions
EXEC [GetMemberInformation] 
    @Member_no = 9912;
GO

EXEC [GetMemberInformation] 
    @Lastname = 'Randal'
    , @Firstname = 'Kimberly';
GO

EXEC [GetMemberInformation] 
    @EmailAddress = N'BFXETPSUKOP.X.FLORINI@company02.com';
GO

EXEC [GetMemberInformation] 
    @EmailAddress = '%45%.com'
    , @Region_No = 6
    , @Member_Code = 2;
GO  

EXEC [GetMemberInformation] 
    @Member_no = 1234;
GO

EXEC [GetMemberInformation] 
    @EmailAddress = N'GXRERSSCFTMISY.R.VANN@company16.com';
GO

EXEC [GetMemberInformation] 
    @EmailAddress = '%27.com';
GO

EXEC [GetMemberInformation] 
    @Lastname = 'Ran%'
    , @Firstname = 'P%';
GO  

EXEC [GetMemberInformation] 
    @EmailAddress = N'NWGUMXWETJPPSN.G.JONES@company01.com';
GO

EXEC [GetMemberInformation] 
    @Member_no = 2479;
GO

EXEC [GetMemberInformation] 
    @EmailAddress = '%2%.com'
    , @Region_No = 6
    , @Lastname = 'L%'
    , @Member_Code = 2;
GO  

EXEC [GetMemberInformation] 
    @EmailAddress = N'PZJWXGMEXPTSQJ.J.EFLIN@company16.com';
GO