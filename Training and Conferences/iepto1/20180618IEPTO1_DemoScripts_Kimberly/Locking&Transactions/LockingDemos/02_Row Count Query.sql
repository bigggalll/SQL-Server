/*============================================================================
  Inconsistent Analysis through Non Repeatable Reads in Read Committted

  File:     02_Row Count Query.sql

  Summary:  Everything's tied to whether or not you can actually count a 
            row TWICE within the bounds of a single statement? 
            Unfortunately, YES!  
            
            This script reads the data - but then gets blocked by script 01.
  
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

-- If you want to play around with RR, you can uncomment this:
--SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
--GO

USE Credit;
go

SELECT COUNT(*) FROM MembersOrdered;
go

-- This should be "waiting"

-- Next, go to 03 to MOVE that first row...

--SP_SPACEUSED MembersOrdered

-- SET TRANSACTION ISOLATION LEVEL REPEATABLE READ