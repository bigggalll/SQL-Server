use master
go
drop database letsgorangers
go
create database letsgorangers
go
use letsgorangers
go
drop table rangerstotheworldseries
go
create table rangerstotheworldseries (col1 int primary key clustered, col2 int, completed int)
go
-- Insert into this table 50000 rows that are not completed
--
set nocount on
go
declare @x int
set @x = 0
while (@x < 50000)
begin
	insert into rangerstotheworldseries values (@x, @x+1, 0)
	set @x = @x + 1
end
go
set nocount off
go
-- Insert into this table 50000 rows that are completed. These the ones we will stretch
--
set nocount on
go
declare @x int
set @x = 50000
while (@x < 100000)
begin
	insert into rangerstotheworldseries values (@x, @x+1, 1)
	set @x = @x + 1
end
go
set nocount off
go