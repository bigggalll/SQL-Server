-- LOGIN: Générer le script de création des droits serveurs
	select --@@servername, sp.type_desc, sp.name, 
		'IF (SUSER_ID('''+sp.name+''') IS NULL)' +  CHAR(10) +
		case when sp.type in ('G','U')
			then '	CREATE LOGIN ' + QUOTENAME(sp.name) + ' FROM WINDOWS WITH DEFAULT_DATABASE=' + QUOTENAME(sp.default_database_Name)
				+ ', DEFAULT_LANGUAGE=' + QUOTENAME(coalesce(sp.default_language_Name,''))
			when sp.type = 'S'
			then '	CREATE LOGIN ' + QUOTENAME(sp.name) + ' WITH PASSWORD=' + CONVERT(varchar(max) ,sl.password_hash,1) + ' hashed'
				+ ', DEFAULT_DATABASE=' + QUOTENAME(sl.default_database_Name) 
				+ ', DEFAULT_LANGUAGE=' + QUOTENAME(sl.default_language_Name)
				+ ', CHECK_POLICY=' + case sl.is_policy_checked when 0 then 'OFF' when 1 then 'ON' end
				+ ', CHECK_EXPIRATION=' + case sl.is_expiration_checked when 0 then 'OFF' when 1 then 'ON' end
				+ ', SID=' + convert(varchar(max),sp.sid,1) 
			when sp.type = 'R'
			then '	CREATE SERVER ROLE ' + QUOTENAME(sp.name) + ' AUTHORIZATION ' + QUOTENAME(suser_name(sp.owning_principal_id))
			end + CHAR(10) 
			+ COALESCE(MEMBERSHIP,'') 
			+ COALESCE(LOGIN_PERM,'') 
			+ 'GO ' + char(10) + CHAR(10)
				AS sqlstatement
	from sys.server_principals (NOLOCK) sp 
	left outer join  sys.sql_logins (NOLOCK) sl on sl.name = sp.name 
	outer APPLY (SELECT 'ALTER SERVER ROLE ' + QUOTENAME(SR.name) + ' ADD MEMBER ' + QUOTENAME(sp.name) + ';' + CHAR(10)
					FROM master.sys.server_role_members (NOLOCK) SRM
						inner JOIN master.sys.server_principals (NOLOCK) SR ON SR.principal_id = SRM.role_principal_id
					where SRM.member_principal_id = sp.principal_id 
					order by SR.name
					FOR XML PATH ('')) mm (MEMBERSHIP)
	outer APPLY (SELECT CASE WHEN SrvPerm.state_desc <> 'GRANT_WITH_GRANT_OPTION' THEN SrvPerm.state_desc ELSE 'GRANT' END +
					space(1) + SrvPerm.permission_name +
					Case when SrvPerm.class = 101 and sp2.type = 'R' then ' ON SERVER ROLE::'+QUOTENAME(sp2.name)
						when SrvPerm.class = 101 then ' ON LOGIN::'+QUOTENAME(sp2.name)
						when SrvPerm.class = 105 then ' ON ENDPOINT::'+QUOTENAME(ep.name)
						when SrvPerm.class = 108 then ' ON AVAILABILITY GROUP::'+QUOTENAME(ag.name)
						else space(0) end +
					' TO ' + QUOTENAME(sp.name) + 
					CASE WHEN SrvPerm.state_desc <> 'GRANT_WITH_GRANT_OPTION' THEN '' ELSE ' WITH GRANT OPTION' END collate database_default  
					+ ';' + CHAR(10)			
				FROM master.sys.server_permissions (NOLOCK) AS SrvPerm 
				left outer join master.sys.server_principals (nolock) as sp2 on SrvPerm.class = 101 and sp2.principal_id = SrvPerm.major_id 
				left outer JOIN master.sys.endpoints (nolock) as ep ON SrvPerm.class = 105 and ep.endpoint_id = SrvPerm.major_id 
				left outer join (select ags.name, ar.replica_metadata_id from master.sys.availability_groups ags
								 inner join master.sys.availability_replicas ar on ags.group_id =ar.group_id) as ag on SrvPerm.class = 108 and ag.replica_metadata_id = SrvPerm.major_id 
				where SrvPerm.grantee_principal_id = sp.principal_id 
				order by SrvPerm.major_id, SrvPerm.permission_name
				FOR XML PATH ('')) ll (LOGIN_PERM)
	where sp.type in ('R','S','G','U') 
	and sp.[is_fixed_role]=0
	order by sp.principal_id

------------------------------------

-- USER: Générer le script de création des droits d'une base de données
	SELECT --@@servername, usr.type_desc, usr.name, 
		'USE ' + QUOTENAME(db_name()) + ';' + char(10) + 
		'IF NOT EXISTS (SELECT * FROM sys.database_principals (NOLOCK) z WHERE z.name = ''' + usr.[name] collate SQL_Latin1_General_CP1_CI_AS + ''')' + char(10) + 
		case when usr.type = 'R'
		Then '	CREATE ROLE ' + QUOTENAME(usr.[name]) collate SQL_Latin1_General_CP1_CI_AS + ' AUTHORIZATION ' + QUOTENAME(suser_name(usr.owning_principal_id) collate SQL_Latin1_General_CP1_CI_AS) + char(10) 
		else '	CREATE USER ' + QUOTENAME(usr.[name]) collate SQL_Latin1_General_CP1_CI_AS+ ' FOR LOGIN ' + QUOTENAME(coalesce(sp.[name] collate SQL_Latin1_General_CP1_CI_AS, usr.[name])) + coalesce(' WITH DEFAULT_SCHEMA=' + QUOTENAME(usr.default_schema_name collate SQL_Latin1_General_CP1_CI_AS),'') + char(10) + 
			'ALTER USER ' + QUOTENAME(usr.[name]) collate SQL_Latin1_General_CP1_CI_AS + ' WITH LOGIN = ' + QUOTENAME(coalesce(sp.[name] collate SQL_Latin1_General_CP1_CI_AS, usr.[name])) + ' -- Corriger si usager orphelin' + char(10) 
		end
		+ COALESCE(ALTER_ROLE,space(0)) 
		+ COALESCE(GRANT_PERM,space(0)) 
			+ 'GO ' + char(10) + CHAR(10)
			AS sqlstatement
	from sys.database_principals (NOLOCK) as usr
		left outer JOIN master.sys.server_principals (NOLOCK) sp ON usr.sid = sp.sid
	outer APPLY (SELECT 'ALTER ROLE ' + QUOTENAME(dpr.name)  + ' ADD MEMBER ' + QUOTENAME(usr.name) + ';' + CHAR(10)
				FROM sys.database_role_members (NOLOCK) drm 
				inner join sys.database_principals (NOLOCK) as dpr on dpr.principal_id = drm.role_principal_id
				where drm.member_principal_id = usr.principal_id
				order by dpr.name
				FOR XML PATH ('')) ar (ALTER_ROLE)
	outer APPLY (SELECT CASE WHEN perm.state <> 'W' THEN perm.state_desc ELSE 'GRANT' END + SPACE(1) 
						+ perm.permission_name + space(1) 
						+ CASE perm.class
							WHEN 0 THEN space(0)
							WHEN 1 THEN 'ON ' + (SELECT QUOTENAME(SCHEMA_NAME(o.schema_id)) + '.' + QUOTENAME(o.name) FROM sys.all_objects o WHERE o.object_id = perm.major_id)
								-- optionally concatenate column names
								+ CASE WHEN max(perm.minor_id) > 0 THEN ' (' + replace((SELECT QUOTENAME(sc.name) + ', ' FROM sys.all_columns sc WHERE sc.object_id = perm.major_id AND sc.column_id IN (SELECT sc_perm.minor_id FROM sys.database_permissions sc_perm WHERE sc_perm.permission_name = perm.permission_name and sc_perm.major_id = perm.major_id AND sc_perm.grantee_principal_id = perm.grantee_principal_id) FOR XML PATH('')) + ')' ,', )', ')') else space(0) END 
							WHEN 3 THEN 'ON SCHEMA::' + QUOTENAME(SCHEMA_NAME(perm.major_id))
							WHEN 4 THEN 'ON ' + (SELECT RIGHT(type_desc, 4) + '::' + QUOTENAME(name) FROM sys.database_principals WHERE principal_id = perm.major_id)
							WHEN 5 THEN 'ON ASSEMBLY::' + (SELECT QUOTENAME(name) FROM sys.assemblies WHERE assembly_id = perm.major_id)
							WHEN 6 THEN 'ON TYPE::' + (SELECT QUOTENAME(name) FROM sys.types WHERE user_type_id = perm.major_id)
							WHEN 10 THEN 'ON XML SCHEMA COLLECTION::' + (SELECT QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) FROM sys.xml_schema_collections WHERE xml_collection_id = perm.major_id)
							WHEN 15 THEN 'ON MESSAGE TYPE::' + (SELECT QUOTENAME(name) FROM sys.service_message_types WHERE message_type_id = perm.major_id)
							WHEN 16 THEN 'ON CONTRACT::' + (SELECT QUOTENAME(name) FROM sys.service_contracts WHERE service_contract_id = perm.major_id)
							WHEN 17 THEN 'ON SERVICE::' + (SELECT QUOTENAME(name) FROM sys.services WHERE service_id = perm.major_id)
							WHEN 18 THEN 'ON REMOTE SERVICE BINDING::' + (SELECT QUOTENAME(name) FROM sys.remote_service_bindings WHERE remote_service_binding_id = perm.major_id)
							WHEN 19 THEN 'ON ROUTE::' + (SELECT QUOTENAME(name) FROM sys.routes WHERE route_id = perm.major_id)
							WHEN 23 THEN 'ON FULLTEXT CATALOG::' + (SELECT QUOTENAME(name) FROM sys.fulltext_catalogs WHERE fulltext_catalog_id = perm.major_id) 
							WHEN 24 THEN 'ON SYMMETRIC KEY::' + (SELECT QUOTENAME(name) FROM sys.symmetric_keys WHERE symmetric_key_id = perm.major_id) 
							WHEN 25 THEN 'ON CERTIFICATE::' + (SELECT QUOTENAME(name) FROM sys.certificates WHERE certificate_id = perm.major_id) 
							WHEN 26 THEN 'ON ASYMMETRIC KEY::' + (SELECT QUOTENAME(name) FROM sys.asymmetric_keys WHERE asymmetric_key_id = perm.major_id) 
							else 'ON CLASS=' + cast(perm.class as varchar)
						 END COLLATE SQL_Latin1_General_CP1_CI_AS
						+ ' TO ' + QUOTENAME(usr.name) collate SQL_Latin1_General_CP1_CI_AS 
						+ CASE WHEN perm.state = 'W' THEN ' WITH GRANT OPTION' ELSE space(0) END 
						+ ';' + CHAR(10)
				from sys.database_permissions (NOLOCK) AS perm 
				where perm.grantee_principal_id = usr.principal_id
				group by perm.grantee_principal_id, perm.permission_name, perm.state, perm.state_desc, perm.class, perm.major_id
				order by perm.class, perm.major_id, perm.permission_name
				FOR XML PATH ('')) gp (GRANT_PERM)
		where usr.principal_id not in (1,2,3,4)
		and usr.type in ('R','S','G','U') 
		and usr.[is_fixed_role]=0
		order by usr.principal_id


----------------------------------------------------------