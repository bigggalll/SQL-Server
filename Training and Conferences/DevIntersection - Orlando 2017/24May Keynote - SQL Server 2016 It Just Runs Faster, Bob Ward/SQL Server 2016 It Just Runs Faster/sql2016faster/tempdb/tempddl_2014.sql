drop database tempdb_test
go
create database tempdb_test
go
use tempdb_test
go
drop proc letstesttempproc
go
create proc letstesttempproc @pagecount int
as
create table #gorangers (westdivchamps int, alcsIhope char(7000) not null)
declare @x int
set @x = 0
while (@x < @pagecount)
begin
insert into #gorangers values (@x, 'Repeat baby!')
set @x = @x + 1
end
go
