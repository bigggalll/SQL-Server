SELECT a.name,
       a.type_desc,*
FROM   sys.server_principals a
       LEFT OUTER JOIN sys.server_role_members b ON a.principal_id = b.member_principal_id
WHERE  b.member_principal_id IS NULL
       AND a.is_fixed_role = 0
       AND a.type NOT IN
			(
			  'R'
			, 'C'
			, 'K'
			)
ORDER BY a.type,a.name;

select a.name,a.type,b.class_desc,b.permission_name from sys.server_principals a left outer join sys.server_permissions b on a.principal_id=b.grantee_principal_id
where a.is_fixed_role=0
and b.type <> 'COSQ'
