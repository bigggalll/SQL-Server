param ($server)

Import-Module sqlps -DisableNameChecking

if( ($server -match "\\") -eq $false) {
	$server = "$server\default"
}

#$sqlserver = Get-Item "SQLSERVER:\SQL\"

$sqlserver = Get-Item "SQLSERVER:\SQL\$($server.name)"

$fields = $sqlserver.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database])
[void]$fields.Add("DataSpaceUsage")
[void]$fields.Add("Name")
[void]$fields.Add("SpaceAvailable")
$sqlserver.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $fields)

$x1 = @{Name="SpaceUsage (MB)";formatstring="N0";Expression={ [Math]::Round($_.DataSpaceUsage/1KB,0) }}
$x2 = @{Name="SpaceAvail (MB)";formatstring="N0";Expression={ [Math]::Round($_.SpaceAvailable/1KB,0) }}

$dblist = $sqlserver.databases 
#$dblist | Select Name, DataSpaceUsage, SpaceAvailable | ft Name,$x1,$x2 -Auto

$files = @()
$record = @{}

Foreach($database in $dblist) {
	$database.Refresh()
	Foreach($fg in $database.FileGroups) {
		Foreach($f in $fg.Files) {
			$f.Refresh()
			$file = New-Object Object
			Add-Member -InputObject $file -MemberType NoteProperty -Name Database -Value $database.Name
			Add-Member -InputObject $file -MemberType NoteProperty -Name FileId -Value $f.Id
			Add-Member -InputObject $file -MemberType NoteProperty -Name Name -Value $f.Name
			Add-Member -InputObject $file -MemberType NoteProperty -Name FileName -Value $f.FileName
			Add-Member -InputObject $file -MemberType NoteProperty -Name Size -Value $f.Size
			Add-Member -InputObject $file -MemberType NoteProperty -Name UsedSpace -Value $f.UsedSpace
			Add-Member -InputObject $file -MemberType NoteProperty -Name IsReadOnly -Value $f.IsReadOnly

			$files += $file
		}
	}

	Foreach($log in $database.LogFiles) {
		$log.Refresh()
		$file = New-Object Object
		Add-Member -InputObject $file -MemberType NoteProperty -Name Database -Value $database.Name
		Add-Member -InputObject $file -MemberType NoteProperty -Name FileId -Value $log.ID
		Add-Member -InputObject $file -MemberType NoteProperty -Name Name -Value $log.Name
		Add-Member -InputObject $file -MemberType NoteProperty -Name FileName -Value $log.FileName
		Add-Member -InputObject $file -MemberType NoteProperty -Name Size -Value $log.Size
		Add-Member -InputObject $file -MemberType NoteProperty -Name UsedSpace -Value $log.UsedSpace
		Add-Member -InputObject $file -MemberType NoteProperty -Name IsReadOnly -Value $log.IsReadOnly
	
		$files += $file
	}

}

$size = @{Name="Size (MB)";formatstring="N0";Expression={ [Math]::Round($_.Size/1KB,0) }}
$usedspace = @{Name="UsedSpace (MB)";formatstring="N0";Expression={ [Math]::Round($_.UsedSpace/1KB,0) }}
$spaceavail = @{Name="Available (MB)";formatstring="N0";Expression={ [Math]::Round(($_.Size-$_.UsedSpace)/1KB,0) }}

$files | ft Database,FileId,Name,FileName,$size,$usedspace,$spaceavail,IsReadonly -auto
