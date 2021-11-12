USE [TestSchemaChanges];
GO

BEGIN TRAN
select * from schema1.t1 WITH (holdlock);
select * from schema1.t2 WITH (holdlock);

select @@TRANCOUNT

exec sp_lock @@spid

-- rollback tran

select * from sys.dm_tran_locks where request_session_id = @@spid

select * from schema1.t100 with (nolock);
select * from schema2.foo2 with (nolock);


SELECT OBJECT_ID('schema1.t100')

SELECT OBJECT_NAME(245575913)
SELECT OBJECT_NAME(261575970)