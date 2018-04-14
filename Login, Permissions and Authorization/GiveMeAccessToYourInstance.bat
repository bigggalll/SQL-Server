@ECHO OFF

sqlcmd -S localhost\acombax -E -e -Q "EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2"

sqlcmd -S localhost\acombax -E -e -Q "CREATE LOGIN [INT\amartin] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]"

sqlcmd -S localhost\acombax -E -e -Q "EXEC master..sp_addsrvrolemember @loginame = N'INT\amartin', @rolename = N'sysadmin'"

net stop MSSQL$ACOMBAX && net start MSSQL$ACOMBAX

net stop SQLBrowser && net start SQLBrowser