<#CompareSearch-Missingfiles.ps1
#File/folder comparison tool to check a source and destination for missing files/folders
#Reports missing source files, ignores extra files on the destination

#Imporovement scopes:
*Make it efficient by skipping missing folder files, folder is missing so files will be as well
#Satyajit321
4:39 PM 18/1/2016

.EXAMPLE
Search-MissingFiles.ps1 | Out-File MissingSource.txt
#>


$SourcePath = "N:\MEP_SGE\MEP 2017-03-30"
$DestPath = "\\cva862u\d$\Demande_MEP_SGE\Planified"

#Equivalent cmd for 'dir /b /s'
$Source = (dir $SourcePath -Recurse).FullName
$Dest = (dir $DestPath -Recurse).FullName

#1/-1 - Different, 0 - Same
#$Source[1].CompareTo($Dest[1])

#$Source[1].CompareTo($Source[1])

#Cleanup to make the paths appear same
#Basically removing the uncommon source and destination paths portion
for($i=0;$i -lt $Source.Count;$i++)
{
$Source[$i] = $Source[$i].Replace($SourcePath, "")
}

for($i=0;$i -lt $Dest.Count;$i++)
{
    $Dest[$i] = $Dest[$i].Replace($DestPath, "")
}



#Loop the Source files
foreach ($fileS in $Source)
{
    #Counter for match
    $Found = $false

    #Loop destination files to Compare with each source
    foreach ($fileD in $Dest)
    {
        #Check Exact Match
        if($fileD.CompareTo($fileS) -eq 0)
            {$Found = $true}
    
    }
    #Writeout missing files
    if(-not $Found)
        {"$SourcePath$fileS"}

}

