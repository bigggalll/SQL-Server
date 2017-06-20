dbcc MEMORYSTATUS 

select type, name, sum((pages_kb*1024)/8192) as stolen_pages
from sys.dm_os_memory_clerks
where pages_kb > 0
group by type, name
order by stolen_pages desc
