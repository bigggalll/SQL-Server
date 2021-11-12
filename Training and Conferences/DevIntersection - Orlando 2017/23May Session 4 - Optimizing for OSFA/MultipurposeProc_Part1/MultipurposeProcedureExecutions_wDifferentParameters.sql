/*============================================================================
  File:     MultipurposeProcedureExecutions_wDifferentParameters.sql

  Summary:  What's really happening across all of these executions?
  
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

--sp_recompile [GetMemberInformation]
SELECT SYSDATETIME() AS StartingTime;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

USE [Credit];
GO

-- Test Scenario 1
EXEC [GetMemberInformation] 
    @Member_no = 9912;
GO

-- Test Scenario 2
EXEC [GetMemberInformation] 
    @Lastname = 'Tripp'
    , @Firstname = 'Kimberly';
GO

-- Test Scenario 3
EXEC [GetMemberInformation] 
    @EmailAddress = N'BFXETPSUKOP.X.FLORINI@company02.com';
GO

-- Test Scenario 4
EXEC [GetMemberInformation] 
    @EmailAddress = '%2%.com'
    , @Region_No = 6
    , @Member_Code = 2;
GO  

-- Test Scenario 5
EXEC [GetMemberInformation] 
    @Member_no = 1234;
GO

-- Test Scenario 6
EXEC [GetMemberInformation] 
    @EmailAddress = N'GXRERSSCFTMISY.R.VANN@company16.com';
GO

-- Test Scenario 7
EXEC [GetMemberInformation] 
    @EmailAddress = '%27.com';
GO

-- Test Scenario 8
EXEC [GetMemberInformation] 
    @Lastname = 'Ran%'
    , @Firstname = 'P%';
GO  

-- Test Scenario 9
EXEC [GetMemberInformation] 
    @EmailAddress = N'NWGUMXWETJPPSN.G.JONES@company01.com';
GO

-- Test Scenario 10
EXEC [GetMemberInformation] 
    @Member_no = 2479;
GO

-- Test Scenario 11
EXEC [GetMemberInformation] 
    @EmailAddress = '%2%.com'
    , @Region_No = 6
    , @Lastname = 'L%'
    , @Member_Code = 2;
GO  

-- Test Scenario 12
EXEC [GetMemberInformation] 
    @EmailAddress = N'PZJWXGMEXPTSQJ.J.EFLIN@company16.com';
GO

-- Test Scenario 13
EXEC [GetMemberInformation] 
    @Lastname = '%i%'
    , @Firstname = '%e%'
    , @EmailAddress = N'%z%';
GO

-- Test Scenario 14
EXEC [GetMemberInformation] 
    @Lastname = '%i%'
    , @Firstname = '%e%'
    , @EmailAddress = N'z%';
GO

SELECT SYSDATETIME() AS EndingTime;
GO
