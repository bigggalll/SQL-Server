/*============================================================================
  Inconsistent Analysis through Non Repeatable Reads in Read Committted

  File:     00_Setup.sql

  Summary:  Everything's tied to whether or not you can actually count a 
            row TWICE within the bounds of a single statement? 
            Unfortunately, YES!  
            
            This script is the initial setup script.
  
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

-- These samples use the Credit database. You can download and restore the
-- credit database from here:
-- http://www.sqlskills.com/resources/conferences/CreditBackup100.zip (2008)
-- http://www.sqlskills.com/resources/conferences/CreditBackup80.zip (2000)

-- NOTE: You can restore the 2000 backup to 2000 or 2005. While you can restore
--       the 2000 backup to 2008, instead - use the 2008 backup for 2008-2014.

-- Also, I recently blogged this example in a post titled: Inconsistent analysis in read committed using locking
-- Here: https://www.sqlskills.com/blogs/kimberly/inconsistent-analysis-in-read-committed-using-locking/


USE [Credit];
GO

IF OBJECTPROPERTY(object_id('[dbo].[MembersOrdered]'), 'IsUserTable') = 1
    DROP TABLE [dbo].[MembersOrdered];
GO

-- Create a copy of the Member table to mess with!
SELECT * 
INTO [dbo].[MembersOrdered]
FROM [dbo].[Member];
GO

-- Create a bad clustered index that's prone to both fragmentation and
-- record relocation. This is part of what makes this scenario more likely!
CREATE CLUSTERED INDEX [MembersOrderedLastname]
ON [dbo].[MembersOrdered]
    ([lastname], [firstname], [middleinitial]);
GO

-- Just to show you some data!
SELECT COUNT(*) FROM [dbo].[MembersOrdered];
GO

EXEC [sp_help] '[dbo].[MembersOrdered]';
GO