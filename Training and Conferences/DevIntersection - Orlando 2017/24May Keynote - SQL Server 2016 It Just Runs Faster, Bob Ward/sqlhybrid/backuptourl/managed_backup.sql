--------------------
---BEGIN TSQL Script
--------------------
CREATE CREDENTIAL [<your container URL>]
WITH IDENTITY = 'Shared Access Signature',
     SECRET = 'sv=2015-04-05&sr=c&sig=NWWIiuvrhk%2FMlrtuJqyqBA48UgdoXfFpj%2FtFDkpeC1A%3D&se=2017-05-24T03%3A18%3A51Z&sp=rwdl'

GO

EXEC msdb.managed_backup.sp_backup_config_basic
 @enable_backup = 1,
 @database_name = 'howboutthemcowboys',
 @container_url = '<Your container URL>',
 @retention_days = 30
GO
 --------------------
 ---END TSQL Script
 --------------------

