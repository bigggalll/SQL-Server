SELECT sp.[name] 
FROM sys.server_principals sp 
  JOIN sys.server_permissions perm 
    ON sp.principal_id = perm.grantee_principal_id 
WHERE perm.class = 100 
  AND perm.[type] = 'CL' 
  AND state = 'G'