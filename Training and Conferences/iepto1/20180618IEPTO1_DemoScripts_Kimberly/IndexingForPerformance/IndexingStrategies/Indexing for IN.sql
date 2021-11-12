-- You've optimized for a seek
create index SeekOnCategory 
on charge (category_no, charge_amt)
go

set statistics io on
go

select category_no, min(charge_amt)
from charge
where category_no IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
group by category_no
go

select category_no, min(charge_amt)
from charge
where category_no = 1
group by category_no
UNION ALL
select category_no, min(charge_amt)
from charge
where category_no = 2
group by category_no
UNION ALL
select category_no, min(charge_amt)
from charge
where category_no = 3
group by category_no
UNION ALL
select category_no, min(charge_amt)
from charge
where category_no = 4
group by category_no
UNION ALL
select category_no, min(charge_amt)
from charge
where category_no = 5
group by category_no
UNION ALL
select category_no, min(charge_amt)
from charge
where category_no = 6
group by category_no
UNION ALL
select category_no, min(charge_amt)
from charge
where category_no = 7
group by category_no
UNION ALL
select category_no, min(charge_amt)
from charge
where category_no = 8
group by category_no
UNION ALL
select category_no, min(charge_amt)
from charge
where category_no = 9
group by category_no
UNION ALL
select category_no, min(charge_amt)
from charge
where category_no = 10
group by category_no
OPTION (MAXDOP 1)