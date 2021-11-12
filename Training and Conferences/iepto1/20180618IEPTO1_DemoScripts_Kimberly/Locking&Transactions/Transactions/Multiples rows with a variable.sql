set xact_abort on

update member set lastname = 'Tripp'
where member_no % 151 = 0

declare @test   int
select @test = member_no
from member
where lastname = 'Tripp'
select @test
go

declare @test   int
update member
    set @test = member_no,
        firstname = 'foo'
where lastname = 'Tripp'
select @test

select firstname, member_no
from member
where lastname = 'Tripp'