create table person.lobtest
(
    c1  int identity,
    c2  varchar(10)     not null,
    c3  char(8000)      not null,
    c4  varchar(max)    not null
);
go

insert person.lobtest values ('test', 'test big value', replicate(convert(nvarchar(max),'abc'), 8000))
go

select c1, DATALENGTH (c4) from person.lobtest


sp_help 'Person.Person'
begin tran 
select * -- NO index covers this so it must do a table scan
from Person.Person with (nolock)
where LastName = 'Singh'

exec sp_lock @@spid

-- rollback tran

select * from sys.dm_tran_locks where request_session_id = @@spid

select @@TRANCOUNT