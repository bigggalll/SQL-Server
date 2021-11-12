/*============================================================================
  Inconsistent Analysis through Non Repeatable Reads in Read Committted

  File:     03_Modify and move.sql

  Summary:  Everything's tied to whether or not you can actually count a 
            row TWICE within the bounds of a single statement? 
            Unfortunately, YES!  
            
            This script causes record 1 to move... but, row 1 has already been
            "counted" in Script 02 (but, it's also still blocked by script 1).
  
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

-- 
USE [Credit];
GO

UPDATE [dbo].[MembersOrdered]
    SET [lastname] = 'ZZZembrosky',
        [firstname] = 'ZZZachary'
WHERE [lastname] = 'ANDERSON' 
    AND [firstname] = 'AMTLVWQBYOEMHD';
GO

-- rollback tran

-- Let this run...
-- Then, commit or rollback what's in script 01 "blocking"
-- Then, go to the Row Count Script (02) and you'll see 10,001 rows instead of 10,000
-- because we've read this row TWICE!