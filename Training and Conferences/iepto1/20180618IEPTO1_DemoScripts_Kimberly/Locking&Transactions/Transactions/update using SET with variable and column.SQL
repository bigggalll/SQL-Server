/*============================================================================
  File:     Update using SET with a variable.sql

  Summary:  Setting variables within the bounds of an UPDATE.
  
  SQL Server Version: most... 
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE CREDIT
go

-- Imagine a VERY volatile database
-- The minimum could EASILY change between the time of the select and the update.
-- Is that OK?
DECLARE @id varchar(10)
SELECT @id = (SELECT min(member_no) 
		    FROM member
		    WHERE region_no = 7)
UPDATE member
  SET region_no = 8 
  WHERE member_no = @id 

SELECT @id
go

-- Better choice would be to perform the subquery as part of the update to
-- guarantee that the row you've modified doesn't change. But, now we have 
-- to query to get the ID and the min (now) might not be what we modified?
DECLARE @id varchar(10)
UPDATE member
  SET region_no = 8 
  WHERE member_no = (SELECT min(member_no) 
		    FROM member
		    WHERE region_no = 7)
-- Is there a way to know what row we modified?? 
-- Even a transaction wouldn't help here. 
SELECT @id = (SELECT min(member_no) 
		    FROM member
		    WHERE region_no = 7)
SELECT @id
go

-- This final scenario guarantees that you see the min at the time 
-- that you updated it.
-- This is hard to do ANY other way!
DECLARE @id varchar(10)
UPDATE titles
  SET region_no = 8, @id = member_no
  WHERE member_no = (SELECT min(member_no) 
		    FROM member
		    WHERE region_no = 7)
SELECT @id
go

-- And, (quick pseudo-code) you can assign a variable while 
-- you're changing the column (in the same statement):

DECLARE @balance money,
    @BankingTran money
SET @BankingTran = $4
UPDATE member
  SET @balance = curr_balance = prev_balance + @BankingTran
  WHERE member_no = 1234
SELECT @balance AS FinalBalance
go

-- Concepts:
-- If you read and then do something with that info - it may have changed
-- In RC, shared locks are only held for the life of the statement
-- So, a lot of people use HOLDLOCK
begin tran
select @balance = balance from ...... UPDLOCK (HOLDLOCK)
if @balance - @debit > 0
    update... X
select...
 
-- Better...    
-- at least no one can modify the data that you're looking at
-- but, then you need to go and re-check it 
begin tran
update checking 
    set balance = balance - @debit
select @balance...
if @balance < 0
    
-- BEST!    
-- Now you get the fewest locks in the shortest period of time 
-- and you assign the variable at the same time!
begin tran
update checking 
    set @balance = balance = balance - @debit
 if @balance < 0


 -- There's a bit of other "controversy" surrounding this type of update.
 -- Check out this SQL Server Central post for more info
 -- http://www.sqlservercentral.com/articles/T-SQL/68467/