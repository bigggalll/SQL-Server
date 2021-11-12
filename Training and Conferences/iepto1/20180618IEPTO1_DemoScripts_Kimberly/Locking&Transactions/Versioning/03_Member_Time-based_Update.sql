/*============================================================================
Understanding the point in time when a transaction begins...

  File:     Member_Time-based_Update.sql

  Summary:  This script is used to show how we can see data AFTER our 
            BEGIN TRAN statement because that's not officially when our
            transaction has begun. As a result, that's NOT the point in
            time to which our snapshot-based transactions reconcile.
  
  Date:     June 2012

  SQL Server Version: 2008 R2
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

USE Credit
go

-- Note, this is not that interesting of an update. However,
-- it sets the firstsname to a TIME and you'll see that this
-- time (that's visible inside of our snapshot tranaction) is
-- AFTER the time when we executed BEGIN TRAN

UPDATE member 
    SET firstname = convert(varchar(15), GETDATE(), 114)
        , lastname = 'transaction' 
WHERE member_no < 100 
    AND member_no %2 = 0
go 

SELECT * FROM member where member_no between 1 and 100; 