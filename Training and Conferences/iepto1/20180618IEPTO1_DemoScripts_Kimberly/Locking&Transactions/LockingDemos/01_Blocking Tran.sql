/*============================================================================
  Inconsistent Analysis through Non Repeatable Reads in Read Committted

  File:     01_Blocking Tran.sql

  Summary:  Everything's tied to whether or not you can actually count a 
            row TWICE within the bounds of a single statement? 
            Unfortunately, YES!  
            
            This script sets up a blocking situation... blocking a row mid-way
            through the set.
  
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

BEGIN TRANSACTION
UPDATE [dbo].[MembersOrdered]
    SET [lastname] = 'test',
        [firstname] = 'test'
WHERE [member_no] = 9965;

--(who is that? It's a row with a lastname of 'Gohan')

-- leave this transaction "holding" the data

-- Now, go to script 02 - query the data (and be blocked)

-- ROLLBACK TRANSACTION;
-- COMMIT TRANSACTION;