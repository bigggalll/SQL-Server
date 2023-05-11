SELECT 'IF (SUSER_ID('+QUOTENAME(SP.name,'''')+') IS NULL) BEGIN CREATE LOGIN ' +QUOTENAME(SP.name)+
			   CASE 
					WHEN SP.type_desc = 'SQL_LOGIN' THEN ' WITH  PASSWORD = ' +CONVERT(NVARCHAR(MAX),SL.password_hash,1)+ ' HASHED, SID = ' +convert(varchar(max),sp.sid,1)  + ', CHECK_EXPIRATION = ' 
						+ CASE WHEN SL.is_expiration_checked = 1 THEN 'ON' ELSE 'OFF' END +', CHECK_POLICY = ' +CASE WHEN SL.is_policy_checked = 1 THEN 'ON,' ELSE 'OFF,' END
					ELSE ' FROM WINDOWS WITH'
				END 
	   +' DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[' +SP.default_language_name+ '] END;' COLLATE SQL_Latin1_General_CP1_CI_AS AS [-- Logins To Be Created --]
FROM sys.server_principals AS SP LEFT JOIN sys.sql_logins AS SL
		ON SP.principal_id = SL.principal_id
--WHERE SP.name = 'usrOpenShiftP';


--IF (SUSER_ID('usrRemoteDesktopManager') IS NULL) BEGIN CREATE LOGIN [usrRemoteDesktopManager] WITH  PASSWORD = 0x0200FC4B7042A98EA5E546D5AD71ACCEFF867D07762AF27C0080AFFBFFB5DB1F57E1990DADBE9F4E4E7B38C99CDB6CC51B7FDCCD794ADEFB665A9CD835B600970AFD6D9BA236 HASHED, SID = 0x474DF0622505094E9CB83003D544C10B, CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF, DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english] END;

select *,
'IF (SUSER_ID('+QUOTENAME(SP.name,'''')+') IS NULL) BEGIN CREATE LOGIN ' +QUOTENAME(SP.name)+
			   CASE 
					WHEN SP.type_desc = 'SQL_LOGIN' THEN ' WITH  PASSWORD = ' +CONVERT(NVARCHAR(MAX),SL.password_hash,1)+ ' HASHED, SID = ' +convert(varchar(max),sp.sid,1)  + ', CHECK_EXPIRATION = ' 
						+ CASE WHEN SL.is_expiration_checked = 1 THEN 'ON' ELSE 'OFF' END +', CHECK_POLICY = ' +CASE WHEN SL.is_policy_checked = 1 THEN 'ON,' ELSE 'OFF,' END
					ELSE ' FROM WINDOWS WITH'
				END 
	   +' DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[' +SP.default_language_name+ '] END;' --COLLATE SQL_Latin1_General_CP1_CI_AS 
	   AS [-- Logins To Be Created --]
	   FROM sys.server_principals AS SP LEFT JOIN sys.sql_logins AS SL
		ON SP.principal_id = SL.principal_id
