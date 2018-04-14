Import-Module sqlps  -DisableNameChecking
$usager       = "usrPlanifCirc"             #usager de la base de données
$Instance     = "dps271d"  #instance Sql server
$databasename = "PlanifCirculaire"          #base de données
$role         = "sysadmin"         #role de l'instance
$grant        = ("EXECUTE","VIEW DEFINITION")         #permission dans la bd  ##future développement

$server =   New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList   $Instance
$login = $Server.Logins  
$SysAdmins = $null;
$SysAdmins = foreach($SQLUser in $login)
{
    foreach($roleInstance in $SQLUser.ListMembers())
    { 
        if($SQLUser.Name -notin ( "NT Service\MSSQLSERVER" `
                                ,"NT SERVICE\SQLSERVERAGENT" `
                                ,"NT SERVICE\SQLSERVERAGENT" `
                                ,"NT SERVICE\SQLWriter" `
                                ,"NT SERVICE\Winmgmt" `
                                ,"sa" ))
        {
            if($roleInstance-match $role )
            { 
                Write-Host "le role $role pour le login $($SQLUser.Name) de l'instance $Instance" -ForegroundColor Yellow;
                $SQLuser | Select-Object `
                @{label = "SQLServer"; Expression = {$Instance}}, `
                @{label = "CurrentDate"; Expression ={(Get-Date).ToString("yyyy-MM-dd")}}, `
                Name, LoginType, CreateDate, DateLastModified;     
            };
        };
    };
}; 
#Write-Host $SysAdmins
$databd = $server.Databases
$dbroles = foreach($db in  $databd.GetEnumerator())
{
    if($db-match $databasename)   
    {
       foreach($dbuser in $db.Users)
       {
        if($dbuser-notin ("[dbo]","[guest]", "[INFORMATION_SCHEMA]", "[sys]")  )
        {
                Write-Host $dbuser.Name "l'usager"  `
                            "sur la base de données" $databasename -ForegroundColor Cyan
                foreach($dbperm in $db.EnumDatabasePermissions())
                {
                    if ($dbperm-match $dbuser.Name )
                    {
                       #Write-Host  $dbperm
                        Write-Host "    "$($dbperm.Grantee) "a la permission" `
                                        $($dbperm.PermissionState) $($dbperm.PermissionType)`
                        "sur la base de données"$($dbperm.ObjectName) -ForegroundColor Magenta
                    }
                }
                foreach($userrole in $db.Roles)
                {
                    foreach ($dbuserole in $userrole.EnumMembers())
                    {
                        if ($dbuserole-match $dbuser.Name)
                        {
                            Write-Host "    "$dbuser.Name "est membre de" $userrole.Name "sur la base de données" $($db.Name)
                        }
                    }
                }
                $userpermtype = $db.EnumObjectPermissions() | Where-Object {$_.'GranteeType' -eq 'user' -and $_.'Grantee' -eq $dbuser.Name } | 
               # Select-Object $($_.Grantee)
                ForEach-Object {$_.'PermissionType'} | Select-Object  $($_.PermissionType)  
                Write-Host "    "$userpermtype

                $userpermstate = $db.EnumObjectPermissions() | Where-Object {$_.'GranteeType' -eq 'user' -and $_.'Grantee' -eq $dbuser.Name } | 
               # Select-Object $($_.Grantee)
                #ForEach-Object {$_.'PermissionState'} 
                 Select-Object @{label = "state"; Expression = {$_.PermissionState}} , @{label = "type"; Expression = {$_.PermissionType}}
                 Write-Host $userpermstate


        }
       }  
       #foreach($dbperm in $db.EnumDatabasePermissions())
       #{
       # if ($dbperm-notmatch 'dbo')
       # { 
       #     Write-Host "la permission" $($dbperm.PermissionState) $($dbperm.PermissionType)`
       #                 "pour l'usager" $($dbperm.Grantee)`
       #                 "sur la base de données"$($dbperm.ObjectName) -ForegroundColor Magenta
       # }
       #}
       #foreach($userrole in $db.Roles)
       #{
       # foreach ($dbuserole in $userrole.EnumMembers())
       # {
       #     if ($dbuserole-match $usager)
       #     {
       #         Write-Host "l'usager"$usager "est membre de" $userrole.Name "sur la base de données" $($db.Name)
       #     }
       # }
       #}
       foreach($perm in  $db.EnumObjectPermissions())
      { 
        if ($perm -notmatch 'public')
        {
            Write-Host "l'objet" $($perm.ObjectName) `
                       "pour le"$($perm.GranteeType)  $($perm.Grantee) `
                       "a la permission" $($perm.PermissionState) $($perm.PermissionType) `
                       "sur la base de données" $($db.Name)  -ForegroundColor Green
        };
       };
       $userrole| Select-Object `
       @{label = "rolebd"; Expression = {$userrole}}, `
       @{label = "CurrentDate"; Expression ={(Get-Date).ToString("yyyy-MM-dd")}}, `
       Name, LoginType, CreateDate, DateLastModified;   
    };
};
#Write-Host $dbroles

#$SysAdmins | Export-Csv -Path 'c:\temp\SQLSysAdminList.csv' -Force -NoTypeInformation;

