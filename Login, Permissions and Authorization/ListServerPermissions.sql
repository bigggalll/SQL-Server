:connect cpga21p\ax01p
SELECT pr.principal_id, pr.name, pr.type_desc, 
    pe.state_desc, pe.permission_name 
FROM sys.server_principals AS pr 
JOIN sys.server_permissions AS pe 
    ON pe.grantee_principal_id = pr.principal_id
where pr.name in ('GJC\DW_MSBI_ADMIN','GJC\mors1');
go
:connect cpga22r\ax01p
SELECT pr.principal_id, pr.name, pr.type_desc, 
    pe.state_desc, pe.permission_name 
FROM sys.server_principals AS pr 
JOIN sys.server_permissions AS pe 
    ON pe.grantee_principal_id = pr.principal_id
where pr.name in ('GJC\DW_MSBI_ADMIN','GJC\mors1');
go

:connect cpga12r\ax01p
SELECT pr.principal_id, pr.name, pr.type_desc, 
    pe.state_desc, pe.permission_name 
FROM sys.server_principals AS pr 
JOIN sys.server_permissions AS pe 
    ON pe.grantee_principal_id = pr.principal_id
where pr.name in ('GJC\DW_MSBI_ADMIN','GJC\mors1');
go
:connect cpga11p\ax01p
SELECT pr.principal_id, pr.name, pr.type_desc, 
    pe.state_desc, pe.permission_name 
FROM sys.server_principals AS pr 
JOIN sys.server_permissions AS pe 
    ON pe.grantee_principal_id = pr.principal_id
where pr.name in ('GJC\DW_MSBI_ADMIN','GJC\mors1');
go
