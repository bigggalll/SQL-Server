select UPPER(a.name) as Name,
 -- quotename(b.default_database_Name),
  case 
       when a.type in ('G','U')
       then 'create login ' + quotename(a.name) 
    + ' from windows with default_database=[master]' --+ quotename(a.default_database_Name)
    + ', default_language=' + quotename(a.default_language_Name)
    when a.type in ('S')
    then 'create login '+ quotename(a.name) 
    + ' with password=' + CONVERT(varchar(max) ,b.password_hash,1) + ' hashed'
    + ', default_database=' + quotename(b.default_database_Name) --', default_database=[master]'al
    + ', default_language=' + quotename(b.default_language_Name)
    + ', check_policy=' + case b.is_policy_checked when 0 then 'off' when 1 then 'on' end
    + ', check_expiration=' + case b.is_expiration_checked when 0 then 'off' when 1 then 'on' end
    + ', SID=' + convert(varchar(max),a.sid,1) 
  end as SRVLogin
from sys.server_principals a
left outer join sys.sql_logins b
on a.name = b.name
where a.type not in ('R','C','K')
and a.name not like '##%##'
and a.sid != 0x01