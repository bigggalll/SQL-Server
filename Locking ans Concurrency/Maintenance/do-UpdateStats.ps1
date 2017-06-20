# do-UpdateStats.ps1
# usage: ./do-UpdateStats.ps1 <Instance name> <Database name> <Login> <Password> <Threads>

param(
	[string]$p_instance=$null,
	[string]$p_database=$null,
	[string]$p_userid=$null,
	[string]$p_passwd=$null,
	[int]$p_threads=$null
     )

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo') | out-null

##### Separate out the instance name if not the default instance #####

$inst = $p_instance.Split("\")
if ($inst.Length -eq 1)
{
	$instance = $inst[0]
}
else
{
	$instance = $inst[1]
}

##### Generate update stats statements #####

$connection = new-object system.data.sqlclient.sqlconnection( `
    "Data Source=$p_instance;Initial Catalog=$p_database;User Id=$p_userid; Password=$p_passwd;");
$connection.Open()
$cmd = $connection.CreateCommand()

$query = ";with statsCTE as (
		select 'UPDATE STATISTICS '+quotename(s.name, '[')+'.'+quotename(o.name,'[')+' WITH FULLSCAN;' as sqlstmt
			, (ROW_NUMBER() OVER (order by (max(i.rowcnt)*count(i.id)) desc)-1) % $p_threads as asc_threadnum
			, ($p_threads - 1) - ((ROW_NUMBER() OVER (order by (max(i.rowcnt)*count(i.id)) desc) -1 ) % $p_threads) as desc_threadnum
			, ((ROW_NUMBER() OVER (order by (max(i.rowcnt)*count(i.id)) desc)-1) / $p_threads) %2 as odd_even
		from sysindexes i
		join sys.objects o on o.object_id = i.id and o.type in ('U', 'V')
		join sys.schemas s on s.schema_id = o.schema_id
		group by s.name, o.name
	)
	select s.sqlstmt
		 ,case(s.odd_even)
			when 0 then s.asc_threadnum
			when 1 then s.desc_threadnum
		end as threadnum
	from statsCTE s
	order by threadnum, s.sqlstmt"

$cmd.CommandText = $query
$reader = $cmd.ExecuteReader()

##### Write commands to script files #####

$jobname = "$instance"+"_"+"$p_database"+"_updstats"

$outfile = "$pwd\$jobname"+".log"
$ofile = New-Item -type file $outfile -force
add-content $outfile "$(get-date) : Building SQL Scripts"

while($reader.Read()) {

	$sqlstmt = $reader['sqlstmt']
	$threadnum = $reader['threadnum']

	$statsfile = $jobname+"_"+$threadnum+".sql"

	if (Test-Path $pwd\$statsfile)
	{
		add-content $pwd\$statsfile $sqlstmt
	}
	else
	{
		$file = New-Item -type file $pwd\$statsfile
		add-content $file "SET NOCOUNT ON;"
		add-content $file $sqlstmt
	}

}

##### Now run the scripts #####

$files = Get-ChildItem $pwd -filter "$jobname*.sql"

foreach( $file in $files)
{

	$file = "$pwd\$file"

#	Start-Job -filepath  "$pwd\update-stats.ps1" -ArgumentList @($p_instance, $p_database, $p_userid, $p_passwd, $file, $outfile) -name $jobname

} 