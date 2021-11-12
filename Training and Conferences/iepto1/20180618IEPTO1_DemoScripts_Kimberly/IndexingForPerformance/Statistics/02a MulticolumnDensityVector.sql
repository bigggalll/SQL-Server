/*============================================================================
  File:     MulticolumnDensityVector.sql

  Summary:  When you create two indexes with the same columns in a different
            order, you'll find that once you get to the complete combination
            of columns the density vector is the same. But, they still have
            different seeking capabilites so this does not mean they are
            redundant for subsets.

  SQL Server Version: 2008+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- These samples use the Credit database. You can download and restore the
-- credit database from here:
-- http://www.sqlskills.com/sql-server-resources/sql-server-demos/ 

-- NOTE: You can use a SQL Server 2000 backup and restore to: 2000, 2005 or 2008/R2
-- There's also a 2008 backup that you can restore to 2008/R2 or 2012

USE [credit];
GO

CREATE INDEX [LnameFnameInd] ON [dbo].[member]([lastname], [firstname]);
CREATE INDEX [FnameLnameInd] ON [dbo].[member]([firstname], [lastname]);
GO

DBCC SHOW_STATISTICS('dbo.member', 'LnameFnameInd')
WITH DENSITY_VECTOR;
GO

-- Density for lastname alone
-- Density for lastname, firstname together
-- Density for lastname, firstname, and member_no together

DBCC SHOW_STATISTICS('dbo.member', 'FnameLnameInd')
WITH DENSITY_VECTOR;
GO

-- Density for firstname alone
-- Density for firstname, lastname together
-- Density for firstname, lastname, and member_no together


DBCC SHOW_STATISTICS('dbo.member', 'LnameFnameInd')
WITH HISTOGRAM;
