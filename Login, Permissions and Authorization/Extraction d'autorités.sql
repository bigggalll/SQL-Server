
--	=================================================================================================================	
--											EXTRACTION D'AUTORIT�S
--										                        
--	Extraire les autorit�s d'une base de donn�es pour pouvoir les r�appliquer ensuite sur une autre BD
--	=================================================================================================================	

-- Ce script permet de faire une sauvegarde rapide des s�curit�s d'une base de donn�es.  Nous utilisons principalement	
-- ce sript pour conserver les s�curit�s d'une base de donn�es qu'on veut remplacer avec une version d'un autre environnement

-- Par exemple, si on veut �craser une BD TEST sur QA avec la BD TEST de prod, on extrait les autorit�s de la BD TEST de QA
-- Avant de la remplacer par la restauration de la prod.  Ensuite on peut enlever les user sur la nouvelle BD restaur�e et
-- appliquer le script g�n�r� pour remettre les droits de QA qui �taient pr�sent avant.
--	=================================================================================================================
--
-- **** Comment utiliser ce script ****
--		-Ouvrir ce script sur le serveur et la BD qu'on veut extraire les autorit�s.  
--      -Faire un right click sur le r�sultat et choisir "Select All"
--		-Faire un bouton de droite et faire COPY
--		-Coller dans un autre Query et modifier le nom de la database dans le "USE" du haut pour y mettre le nom de la BD 
--          Sur laquelle on veut appliquer les m�mes droits.
--		-Si on �crase la BD avec celle d'un autre environnement, il faut enlever manuellement les "User" d�finis sur la BD
--		-Ex�cuter le Query d�fini un peu plus t�t, et la BD aura les droits qu'on avait avant.
--
--	**** Notes ****  
--		-Ce script ne couvre pas tout, mais il couvre la majorit� des autorit�s et il semble faire le travail
--		-Il est normal que les ajouts de Login ne fonctionne pas s'ils existent d�j�... 
--	=================================================================================================================
--     Param�tre     		Utilisation 
-- 
--     Aucun
--	=================================================================================================================


create table #security(query varchar(1000))

insert into #security 
select 'use '+db_name() +';'

/*ASSIGN SERVER ROLES TO LOGIN*/
--insert into #security 
--SELECT
--'EXEC sp_addsrvrolemember '
--+ SPACE(1) + QUOTENAME(rm.name, '''')+','
--+ SPACE(1) + QUOTENAME(rm1.name, '''') AS '--Role Memberships'
--from sys.server_role_members a
--INNER JOIN
--sys.server_principals rm ON a.member_principal_id = rm.principal_id
--INNER JOIN
--sys.server_principals rm1 ON a.role_principal_id = rm1.principal_id

-----------------------------------------------------------

/*CREATE DATABASE USERS*/
insert into #security 
SELECT 'CREATE USER [' + a.name + '] for login [' + b.name + ']'  from sys.database_principals a
INNER JOIN sys.server_principals b ON a.sid = b.sid
where a.name <> 'dbo'

-----------------------------------------------------------

/*CREATE DATABASE ROLES*/
insert into #security 
SELECT 'CREATE ROLE [' + a.name + '] AUTHORIZATION [' + b.name + ']' from sys.database_principals a
INNER JOIN sys.database_principals b ON a.owning_principal_id = b.principal_id
where a.type = 'R' and a.is_fixed_role <> 1
GO

------------------------------------------------------------

/*ASSIGN ROLES TO USER*/
insert into #security 
SELECT 'EXEC sp_AddRoleMember ''' + dpr.NAME + ''', ''' + dpu.NAME + '''' AS '--Add Users to Database Roles--'
--SELECT 'ALTER ROLE ' + quotename(dpr.name,'[')  + ' ADD MEMBER ' + quotename(dpu.name,'[')
FROM sys.database_principals dpr
JOIN sys.database_role_members drm on (dpr.principal_id = drm.role_principal_id)
JOIN sys.database_principals dpu on (drm.member_principal_id = dpu.principal_id)
WHERE dpu.principal_id > 4
ORDER BY drm.role_principal_id 
GO

------------------------------------------------------------

/*SELECT OBJECT LEVEL PERMISSION*/

insert into #security 
SELECT
CASE WHEN perm.state != 'W' THEN perm.state_desc ELSE 'GRANT' END + SPACE(1) +
perm.permission_name + SPACE(1) + 'ON '+ QUOTENAME(Schema_NAME(obj.schema_id)) + '.'
+ QUOTENAME(obj.name) collate Latin1_General_CI_AS_KS_WS
+ CASE WHEN cl.column_id IS NULL THEN SPACE(0) ELSE '(' + QUOTENAME(cl.name) + ')' END
+ SPACE(1) + 'TO' + SPACE(1) + QUOTENAME(usr.name)
+ CASE WHEN perm.state <> 'W' THEN SPACE(0) ELSE SPACE(1) + 'WITH GRANT OPTION' END AS '--Object Level Permissions'
FROM sys.database_permissions AS perm
INNER JOIN
sys.objects AS obj
ON perm.major_id = obj.[object_id]
INNER JOIN
sys.database_principals AS usr
ON perm.grantee_principal_id = usr.principal_id
LEFT JOIN
sys.columns AS cl
ON cl.column_id = perm.minor_id AND cl.[object_id] = perm.major_id
ORDER BY usr.name

------------------------------------------------------------

/*SELECT OBJECT LEVEL PERMISSION FOR A OBJECT*/
insert into #security 
SELECT
CASE WHEN perm.state != 'W' THEN perm.state_desc ELSE 'GRANT' END + SPACE(1) +
perm.permission_name + SPACE(1) + 'ON '+ QUOTENAME(Schema_NAME(obj.schema_id)) + '.'
+ QUOTENAME(obj.name) collate Latin1_General_CI_AS_KS_WS
+ CASE WHEN cl.column_id IS NULL THEN SPACE(0) ELSE '(' + QUOTENAME(cl.name) + ')' END
+ SPACE(1) + 'TO' + SPACE(1) + QUOTENAME(usr.name)
+ CASE WHEN perm.state <> 'W' THEN SPACE(0) ELSE SPACE(1) + 'WITH GRANT OPTION' END AS '--Object Level Permissions'
FROM sys.database_permissions AS perm
INNER JOIN
sys.objects AS obj
ON perm.major_id = obj.[object_id]
INNER JOIN
sys.database_principals AS usr
ON perm.grantee_principal_id = usr.principal_id
LEFT JOIN
sys.columns AS cl
ON cl.column_id = perm.minor_id AND cl.[object_id] = perm.major_id
Where obj.name = 'ULTIMATES_CURRENT'
ORDER BY usr.name





-------------------------------
/* Generate statements to create server permissions for SQL logins, Windows Logins, and Groups */ 
 insert into #security
-- Role Members 
SELECT  'EXEC sp_addsrvrolemember @rolename =' + SPACE(1) + QUOTENAME(usr1.name, '''') + ', @loginame =' + SPACE(1) + QUOTENAME(usr2.name, '''')  
FROM    sys.server_principals AS usr1
        INNER JOIN sys.server_role_members AS rm ON usr1.principal_id = rm.role_principal_id
        INNER JOIN sys.server_principals AS usr2 ON rm.member_principal_id = usr2.principal_id
WHERE   usr2.name <> 'sa'
ORDER BY rm.role_principal_id ASC; 
 

 insert into #security 
select 'use Master;'

insert into #security
-- Permissions 
SELECT  sp.state_desc COLLATE SQL_Latin1_General_CP1_CI_AS + ' ' + sp.permission_name COLLATE SQL_Latin1_General_CP1_CI_AS
        + ' TO [' + s.name COLLATE SQL_Latin1_General_CP1_CI_AS + ']'  
FROM    sys.server_permissions AS sp WITH (NOLOCK)
        INNER JOIN sys.server_principals AS s WITH (NOLOCK) ON sp.grantee_principal_id = s.principal_id
WHERE   s.type IN ('S', 'U', 'G') and s.name <> 'sa'
ORDER BY s.name ,
        sp.state_desc ,
        sp.permission_name;

-- Afficher r�sultat
select * from #security
drop table #security
