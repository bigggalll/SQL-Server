/*============================================================================
  File:     Nested Savepoints.sql

  Summary:  Can a savepoint name be reused. And, if the name is reused inside
            of nested procedures/transactions - what happens? 
  
  Date:     September 2011

  SQL Server Version: SQL Server 2008
------------------------------------------------------------------------------
  (c) SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by SQLskills.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- Remember to always start with a clean version of the credit database
-- See the project: OtherUsefulScripts for RestoreCredit.sql
SELECT * FROM fn_dblog(null, null)
go

USE credit
go

SELECT * 
FROM member 
WHERE member_no IN (1260, 1261, 1262)

-- Batch level...
BEGIN TRAN
SAVE TRAN foo -- this is the first savepoint
UPDATE member
		SET firstname = 'Kimberly'
		WHERE member_no = 1260
SAVE TRAN foo -- this is the second savepoint (just has the same name)
UPDATE member
		SET firstname = 'Kimberly'
		WHERE member_no = 1261
SELECT * FROM member WHERE member_no IN (1260, 1261, 1262)
ROLLBACK TRAN foo
SELECT * FROM member WHERE member_no IN (1260, 1261, 1262)
ROLLBACK TRAN foo
SELECT * FROM member WHERE member_no IN (1260, 1261, 1262)
SELECT @@TRANCOUNT
ROLLBACK TRAN

SELECT @@TRANCOUNT
go

CREATE PROC Level2
AS
BEGIN TRAN
SAVE TRAN FOO
UPDATE member
		SET firstname = 'Kimberly'
		WHERE member_no = 1262
COMMIT TRAN
go

CREATE PROC lEVEL1
AS
BEGIN TRAN
SAVE TRAN FOO
UPDATE member
		SET firstname = 'Kimberly'
		WHERE member_no = 1261
EXEC LEVEL2
ROLLBACK TRAN FOO		
COMMIT TRAN
go

SELECT * 
FROM member 
WHERE member_no IN (1260, 1261, 1262)
go

EXEC level1
    -- rolls back to the most recent foo in the SINGLE "stack"

SELECT * 
FROM member 
WHERE member_no IN (1260, 1261, 1262)
-- 1261 will be modified

go
CREATE PROC lEVEL1_2RBs
AS
BEGIN TRAN
UPDATE member
		SET firstname = 'kimberly'
		WHERE member_no = 1260
SAVE TRAN FOO
UPDATE member
		SET firstname = 'kimberly'
		WHERE member_no = 1261
EXEC LEVEL2
SELECT * 
FROM member 
WHERE member_no IN (1260, 1261, 1262)
ROLLBACK TRAN FOO		
ROLLBACK TRAN FOO		
COMMIT TRAN
go

-- reset the data..
UPDATE member
		SET firstname = 'test'
		WHERE member_no = 1261
go

-- check the data
SELECT * 
FROM member 
WHERE member_no IN (1260, 1261, 1262)
go

exec lEVEL1_2RBs
    -- rolls back EACH foo in the SINGLE "stack"
go
SELECT * 
FROM member 
WHERE member_no IN (1260, 1261, 1262)
