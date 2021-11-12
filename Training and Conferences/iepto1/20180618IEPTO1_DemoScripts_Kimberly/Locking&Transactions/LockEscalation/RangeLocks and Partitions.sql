ALTER TABLE ChargesPT
SET (LOCK_ESCALATION = TABLE);
GO

BEGIN TRAN  --2380
SELECT * FROM ChargesPT WITH (HOLDLOCK)
WHERE [Charge_dt] >= '20040701' 
	AND [Charge_dt] < '20040801'

--next, run this in a separate window
--SELECT * 
--FROM sys.dm_tran_locks
--WHERE request_session_id = 54

ROLLBACK TRAN


ALTER TABLE ChargesPT
SET (LOCK_ESCALATION = AUTO);
GO

BEGIN TRAN  -- 2382 (two HOBT IS locks ONE for this partition and one for Aug partition)
SELECT * FROM ChargesPT WITH (HOLDLOCK)
WHERE [Charge_dt] >= '20040701' 
	AND [Charge_dt] < '20040801'

--next, run this in a separate window
--SELECT * 
--FROM sys.dm_tran_locks
--WHERE request_session_id = 54

ROLLBACK TRAN


BEGIN TRAN  -- this will also take PAGEs in the Aug partition
SELECT * FROM ChargesPT WITH (HOLDLOCK)
WHERE [Charge_dt] >= '20040701' 
	AND [Charge_dt] < '20040802'

--next, run this in a separate window
--SELECT * 
--FROM sys.dm_tran_locks
--WHERE request_session_id = 54

ROLLBACK TRAN