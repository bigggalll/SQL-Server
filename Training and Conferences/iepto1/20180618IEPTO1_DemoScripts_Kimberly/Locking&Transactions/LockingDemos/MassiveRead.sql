/*============================================================================
  File:     MassiveRead.sql

  Summary:  What locks are held for various statements...  
  
  SQL Server Version: 2008
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

------------------------------------------------------------------------------
-- Scenario 1: Massive reads, what kind of page locks?!
------------------------------------------------------------------------------

-- First example, DB=S, Table=IS, Page=S (trickling through - not escalation)
-- Kick off a MASSIVE read (not row locks)
USE AdventureWorksDW2008_ModifiedSalesKey
go

SELECT * FROM FactInternetSales
go

-- check the locks...



-- Second example, DB=S, Page = IS (not row) 
--    -> Table=S (escalate so that we don't need to manage any other locks)

-- What if someone uses HOLDLOCK
SELECT * FROM FactInternetSales WITH (HOLDLOCK)
go

-- check the locks...

-- But, what about other users?
-- Readers, yes
-- Writers, no (HOLDLOCK is synonymous with SERIALIZABLE)