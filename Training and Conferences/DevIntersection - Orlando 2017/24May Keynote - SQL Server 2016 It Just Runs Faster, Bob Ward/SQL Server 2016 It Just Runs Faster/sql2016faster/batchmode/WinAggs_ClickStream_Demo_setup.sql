-- Creating the database 
use master
go
drop database if exists ClickStreamDemo
create database ClickStreamDemo
go
use ClickStreamDemo
go
-- Creating tables
drop table if exists clickstream
drop table if exists clickstream_row
go
create table clickstream(ip nvarchar(32), currtime datetime2, x float, y float)
go
create clustered columnstore index csidx on clickstream
go
-----------------------------------------------
-- Generate sample data
declare @i int = 0
while @i < 10
begin
	declare @session_time datetime2 = DATEADD(minute, (ABS(CHECKSUM(NEWID())) % 525600), 42000);	-- somewhere in 2015
	declare @session_duration int = ABS(CHECKSUM(NEWID())) % 1000*60*90 + 1000*60*30;	-- between 30 min and 120 min in milliseconds
	insert into clickstream(ip, currtime, x, y) 
	select 
		CONCAT('128.0.0.', (ABS(CHECKSUM(NEWID())) % 1000)),	-- random client ip address, 1000 clients in total
		DATEADD(ms, (ABS(CHECKSUM(NEWID())) % @session_duration), @session_time),	-- random click event time within session time
		ABS(CHECKSUM(NEWID())) % 1920, 
		ABS(CHECKSUM(NEWID())) % 1080
	from sys.objects a, sys.objects b, sys.objects c
	set @i = @i + 1
end
-- Generate heap dataset (for row mode comparison)
select * 
into clickstream_row
from clickstream
go
