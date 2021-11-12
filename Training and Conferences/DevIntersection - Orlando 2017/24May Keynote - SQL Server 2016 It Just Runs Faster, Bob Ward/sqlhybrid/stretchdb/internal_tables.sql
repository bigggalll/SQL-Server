-- Connect with DAC first
--
use letsgorangers
go
select * from sys.objects where name like '%remote%'
go
select * from sys.remote_data_archive_batch_id_timer
go
select * from sys.remote_data_archive_rpo_565577053
go