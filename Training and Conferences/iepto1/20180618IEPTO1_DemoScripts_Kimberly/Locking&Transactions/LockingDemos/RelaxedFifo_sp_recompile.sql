------------------------------
-- Step 1 - Setup
------------------------------

USE AdventureWorksDW2008_ModifiedSalesKey
go

DROP PROCEDURE test
go

CREATE PROCEDURE test
(@prodkey int)
AS
SELECT * 
FROM factinternetsales 
WHERE productkey = @Prodkey
go

------------------------------
-- Step 2 - Query with NOLOCK
------------------------------

-- Go to the Query script and create a long running
-- NOLOCK query

------------------------------
-- Step 3 - Check the locks
------------------------------

-- Go to the CheckLocks script and
-- make sure there's a table-level 
-- Schema S(shared) lock.

------------------------------
-- Step 4 - Try these recompiles
------------------------------

-- Does not required a table-level Sch_M lock
exec sp_recompile test
    -- this is just fine...


-- table-level Sch_M
exec sp_recompile factinternetsales
    -- this waits...