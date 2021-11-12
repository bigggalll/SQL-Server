-- Run queries
--
use letsgorangers
go
select * from rangerstotheworldseries where completed = 1
go
use letsgorangers
go
select * from rangerstotheworldseries where completed = 0
go
USE letsgorangers
GO
SELECT * FROM rangerstotheworldseries
WITH (REMOTE_DATA_ARCHIVE_OVERRIDE = LOCAL_ONLY)
GO
SELECT * FROM rangerstotheworldseries
WITH (REMOTE_DATA_ARCHIVE_OVERRIDE = REMOTE_ONLY)
GO
SELECT * FROM rangerstotheworldseries
WITH (REMOTE_DATA_ARCHIVE_OVERRIDE = STAGE_ONLY)
GO