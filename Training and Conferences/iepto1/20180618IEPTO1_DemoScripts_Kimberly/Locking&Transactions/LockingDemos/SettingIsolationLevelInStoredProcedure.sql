/* *********************************************
** The oddities around transaction isolation level
** connection pooling (sp_reset_connection). (these are odd)
** And, stored procedures do it correctly!
********************************************* */

USE Credit;
go

alter procedure TestIsolation
as
set transaction isolation level read uncommitted;
select * from member;
dbcc useroptions;
go


dbcc useroptions;
go

exec TestIsolation;
go

dbcc useroptions;
go

-- So... we're reset correctly!

-- The weird scenario I was remembering was around sp_reset_connection and the fact
-- that it DOES not reset the isolation level.

-- A lot of people do NOT like this (see Connect Item: 243527 )
-- https://connect.microsoft.com/SQLServer/feedbackdetail/view/243527/sp-reset-connection-doesnt-reset-isolation-level

-- And, interestingly, in 2014 RTM - they "fixed" and some people loved it...
-- but, it caused some breaking problems in older apps and so they reversed it back
-- to the older behavior (which some people still think needs to change)
-- Anyway, here's the KB for the "fix" to go back to NOT resetting it with sp_reset_connection
-- KB: 3025845: https://support.microsoft.com/en-us/help/3025845/fix-the-transaction-isolation-level-is-reset-incorrectly-when-the-sql-server-connection-is-released-in-sql-server-2014

-- Recompilation problems - OLD article
-- 2000 procedure-level recompiles (compile locks)
-- 2005 statement-level recompiles {PREFERRED}
-- KB article 243586