-- understanding the scenario
SELECT SCHEMA_NAME(schema_id), name from sys.tables
go

create table schema2.testnolock (c1 int);
go

begin tran
select * from Schema2.testnolock



select * from sys.dm_tran_locks where request_session_id = @@spid

rollback tran


begin tran
select * from schema1.testxml


select * from sys.dm_tran_locks where request_session_id = @@spid

use AdventureWorks2014;
go


select * from person.person

select @@TRANCOUNT

select request_SESSION_ID as RS2, * from sys.dm_tran_locks
ORDER BY RS2

SP_WHOISACTIVE