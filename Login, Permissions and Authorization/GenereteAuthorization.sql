declare @RoleName varchar(50) = 'AAD_USER'

select 'GRANT ' + prm.permission_name + ' ON ' + OBJECT_NAME(major_id) + ' TO ' + rol.name + char(13) COLLATE Latin1_General_CI_AS 
from sys.database_permissions prm
    join sys.database_principals rol on
        prm.grantee_principal_id = rol.principal_id
where rol.name = @RoleName

