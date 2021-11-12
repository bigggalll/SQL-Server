################################################################################
#                                                                              #
# Obtenir la liste des listeners                                               #
#                                                                              #
# Créer par : Francis Thérien                                                  #
# Créer le 2017-06-28                                                          #
#                                                                              #
################################################################################
#
# Modification
# ¯¯¯¯¯¯¯¯¯¯¯¯
# Projet      Date       Nom
# xxxxxxxxxx  08/12/2017 Francis Thérien
#       Ajouter la validation de Biztalk Server (Log Shipping)
#
# xxxxxxxxxx  02/02/2018 Francis Thérien
#       Ajouter le support des listeners avec instance comme INFOSHIPP 
#
################################################################################


Function Get-CIRXPrimaries
{
    <#
    .SYNOPSIS
    Obtien la santé et la localisation des différents listeners des serveurs SQL avec Always On.
    .DESCRIPTION
    Outil utilisé pour obtenir la liste des noeuds primaires des listeners et leur état de santé avec AlwaysOn.
    La liste des listeners provient de LstnDefaultP, base de données DBA_SQL01P dans la table Listeners.
    Le fichier texte "LISTENER.TXT" est créé dans le même répertoire que ce script avec la liste des listeners. 
    Vous pouvez utiliser cette liste seulement avec le paramètre -ListenerTextFileOnly
    .EXAMPLE
    Get-CIRXPrimaries
    Obtenir la liste des primaires des listeners de tous les environnements
    .EXAMPLE
    Get-CIRXPrimaries -ENV QA -OutGrid
    Obtenir la liste des primaires des listeners de QA, affiché dans une fenêtre de type OUT-GRID.
    .EXAMPLE
    Get-CIRXPRIMARIES -ENV PD -ListenerTextFileOnly
    Obtenir la liste des primaires des listeners de production depuis le fichier texte seulement.
    #>

    Param(
    [parameter(Mandatory=$false,
     HelpMessage="Spécifier l'environnement voulu (QA=Qualité, PD=Production, vide=tous)")]
    [ValidateSet("QA","PD")]
    [string] $Env = "  ",
    [parameter(HelpMessage="Utilise le fichier texte seulement, aucune connexion sur Serveur SQL pour obtenir la liste des listeners")]
    [alias("TxtOnly","NoConnection")]
    [switch] $ListenerTextFileOnly,
    [parameter(HelpMessage="Sortie dans une fenêtre Windows au lieu de console.")]
    [Switch] $OutGrid
    

    )

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force


    $ScriptRoot = $PSScriptRoot
    $ExecuteSQLQueryPath = $PSScriptRoot + "\ExecuteSQLQuery.ps1"
    $Fonction_Fichier_Local_Listeners_Path = $PSScriptRoot + "\Fonction_Fichier_Local_Listeners.ps1"

    If (Test-Path -Path $ExecuteSQLQueryPath)
    {
        .$ExecuteSQLQueryPath
    }
    else
    {
        Write-Host "Dépendance 'ExecuteSQLQuery' manquante" -BackgroundColor Red
        Break;
    }

    If (Test-Path -Path $Fonction_Fichier_Local_Listeners_Path)
    {
        .$Fonction_Fichier_Local_Listeners_Path
    }
    else
    {
        Write-Host "Dépendance 'Fonction_Fichier_Local_Listeners' manquante" -BackgroundColor Red
        Break;
    }
    Write-Host " "


    ## Début du programme principal
    ## ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Write-host #Ligne vide
    Write-Host "Début obtention des primaires par Listener..." -BackgroundColor Green

    ### Initialisation
    [string] $Database = "master"
	[string]$UserSqlQuery = "IF SERVERPROPERTY ('IsHadrEnabled') = 1
                                BEGIN
                                    SELECT
                                        AGL.dns_name as [Listener] -- Listener name
                                      , ARS.role_desc [Role] -- Role de l'instance
                                      , RCS.replica_server_name as [Instance] -- SQL cluster node name
                                      , ARS.synchronization_health_desc as [Health] -- Health condition
                                      , AGC.name as [Availability group] -- Availability Group
                                    FROM
                                        sys.availability_groups_cluster AS AGC
                                    INNER JOIN sys.dm_hadr_availability_replica_cluster_states AS RCS
                                        ON RCS.group_id = AGC.group_id
                                    INNER JOIN sys.dm_hadr_availability_replica_states AS ARS
                                        ON ARS.replica_id = RCS.replica_id
                                    INNER JOIN sys.availability_group_listeners AS AGL
                                        ON AGL.group_id = ARS.group_id
                                END"
                         
    [string] $UserID = "userid"
    [string] $Pass = "pass"
    [int] $count = 0
    [int] $servernamefound = 0


    $listeners = New-Object System.Data.DataTable
    $resultsDataTable = New-Object System.Data.DataTable

	
	## Liste des listeners 
	$listenersInfo = New-Object System.Data.DataTable
	$result = $listenersInfo.Columns.Add("Listener")
	$result = $listenersInfo.Columns.Add("Primary")
	$result = $listenersInfo.Columns.Add("Health")
	$result = $listenersInfo.Columns.Add("Availability Group")
	$result = $listenersInfo.Columns.Add("City")
	$result = $listenersInfo.Columns.Add("Message")
	
    ## Liste des listeners n'ayant pas pu être contacté
    $lostListener = New-Object System.Data.DataTable
    $result = $lostListener.Columns.Add("Listener")
    $result = $lostListener.Columns.Add("Message")

    $resultsDataTable.Clear()

    if (!$ListenerTextFileOnly)
    {
        $listenerListServerLocation = "LstnDefaultQ"
		$listenerListSQLInstance = ""
		if ($listenerListSQLInstance -ne "")
		{
			$listenerListSQLServer = $listenerListServerLocation + "\" + $listenerListSQLInstance
		}
		else
		{
			$listenerListSQLServer = $listenerListServerLocation
		}
		
		### Obtenir la liste des listeners depuis SQL Server et l'exporter si succès
        if (Test-Connection -ComputerName $listenerListServerLocation -Count 1 -Quiet)
        {
            $listeners = ExecuteSqlQuery -Server $listenerListSQLServer -Database "DBA_SQL00Q" -SQLQuery "Select Listener, Env from Listeners Order By Priority"
            if ($listeners.GetType().Name -ne "String")
            {
                Export-ListenersList($listeners)
            }
   
        }
        else
        {
            Write-Warning "Le serveur SQL '$listenerListSQLServer n'a pu être rejoint. Tentative d'utilisation du fichier local 'listeners.txt'"
            Write-Host " "

        }
    }


    ### Obtenir la dernière liste des listeners depuis le fichier texte
    Remove-Variable Listeners -ErrorAction SilentlyContinue
    $listeners = Import-ListenersList -Env $Env

    if ($listeners.GetType().Name -eq "String")
    {
        Write-Host $listeners -BackgroundColor Red
        Write-Host " "
        Write-Host "Traitement terminé avec erreur" -BackgroundColor Red
    
        break
    }
	
	
	### Pour chaque listener, trouver le Primary et la condition ALWAYSON pour les secondaires sa condition
	$count = 0;
    While ($count -lt $listeners.Count)
	{
		[string]$listener = $listeners[$count].trim()
        Write-Progress -Activity "Obtenir la liste des primaires" -PercentComplete ($count / $listeners.Count * 100) -CurrentOperation $Listener
        $servernamefound = 1
		
		# Détection si le listener a une instance
		if ($listener.ToUpper().IndexOf('\') -gt 0)
		{
			[bool]$HasInstance = $true
		}
		else
		{
			[bool]$HasInstance = $false
		}
		
		# Détection si le listener récupéré n'est pas un vrai listener (Pour Biztalk)
		if ($listener.ToUpper().IndexOf("LSTN") -eq 0)
		{
			[bool]$IsTrueListener = $true
		}
		else
		{
			[bool]$IsTrueListener = $false
		}
		
		
		# Récupération du node et de l'instance
		if ($HasInstance)
		{
			[int]$slash = $listener.IndexOf('\')
			[string]$NodePrimaire = $listener.Substring(0, $slash)
			
			[int]$pos = $slash + 1
			[int]$lenght = $listener.Length - $pos
			[string]$Instance = $listener.Substring($pos, $lenght)
		}
		else
		{
			[string]$NodePrimaire = $listener.Trim()
			[string]$Instance = ""
		}
		
		
		# Résoudre l'adresse de la node Primaire 
		TRY
		{
			$servernameList = Resolve-DnsName -Name $NodePrimaire -QuickTimeout -Type A -ErrorAction Stop | Select-Object -Property "Name", "Type"
			[string]$ServeurNomComplet = ""
			Foreach ($servername in $servernameList)
			{
				
				if ($servername.Type -eq 'A')
				{
					if ($ServeurNomComplet -eq "")
					{
						[string]$ServeurNomComplet = $servername.Name
					}
					[int]$slash = $servername.Name.IndexOf(".")
					if ($slash -ge 1)
					{
						[string]$ServeurNomCourt = $servername.Name.Substring(0, $slash)
					}
					else
					{
						[string]$ServeurNomCourt = $servername.Name.Trim()
					}
				}
				if ($servername.Type -eq 'CNAME')
				{
					[string]$ServeurNomComplet = $servername.Name
				}
				
			}
			Remove-Variable servernameList -ErrorAction SilentlyContinue
			$servernamefound = 1
		}
		CATCH
		{
			$servernamefound = 0
			[string]$Message = "Erreur : Impossible de communiquer avec '$listener'."
			$row = $lostListener.NewRow()
			$row.Listener = $listener
			$row.Message = $Message
			$lostListener.Rows.Add($row)
		}
		
		
		if ($servernamefound -eq 1)
		{
			
			if ($IsTrueListener)
			{
				[string]$dns = $ServeurNomComplet
				if ($HasInstance)
				{
					$dns += "\" + $Instance
				}
				
				$resultsDataTable = ExecuteSqlQuery $dns $Database $UserSqlQuery $UserId $Pass
				
				[int]$SQLServerCount = 0
				$row = $listenersInfo.NewRow()
				$row.Listener = $listener
				[bool]$Healty = $true
				[string]$Message = ""
				while ($SQLServerCount -lt $resultsDataTable.count)
				{
					if ($resultsDataTable[$SQLServerCount].Role -eq "PRIMARY")
					{
						$row.Primary = $resultsDataTable[$SQLServerCount].Instance
						$row."Availability group" = $resultsDataTable[$SQLServerCount]."Availability group"
						[string]$City = Get-CIRXSQLServerCity -SQLServer $resultsDataTable[$SQLServerCount].Instance
						$row.City = $City.trim()
					}
					
					[string]$HealthState = $resultsDataTable[$SQLServerCount].Health
					if ($HealthState.trim() -ne "HEALTHY")
					{
						$Healty = $false
						if ($resultsDataTable[$SQLServerCount].Role -ne "PRIMARY")
						{
							if ($Message -eq "")
							{
								$Message = "L'instance SQL secondaire " + $resultsDataTable[$SQLServerCount].Instance + " est reportée en problème de synchronisation."
							}
							Else
							{
								$Message += " L'instance SQL secondaire " + $resultsDataTable[$SQLServerCount].Instance + " est reportée en problème de synchronisation."
							}
							
						}
						
					}
					
					$SQLServerCount += 1
				}
				if ($Healty)
				{
					$row.Health = "HEALTHY"
				}
				else
				{
					$row.Health = "NOT_HEALTHY"
				}
				
				$row.Message = $Message
				
				$listenersInfo.Rows.add($row)
			}
			
			else
			{
				
				$row = $listenersInfo.NewRow()
				$row.Listener = $listener
				[bool]$Healty = $true
				[string]$Message = ""
				
				$row.Primary = $ServeurNomCourt.ToUpper()
				if ($HasInstance){$row.Primary += '\' + $Instance}
				$row."Availability group" = "N/A"
				[string]$City = Get-CIRXSQLServerCity -SQLServer $ServeurNomComplet
				$row.City = $City.trim()
				$row.Health = "N/A"
				$listenersInfo.Rows.add($row)
				
				Remove-Variable primary -ErrorAction SilentlyContinue
				
			}
			
		}
		
		Remove-Variable servername -ErrorAction SilentlyContinue
        $count += 1;
    }
    Write-Progress -Activity "Obtenir la liste des primaires" -Completed
	
	
	
	### AFFICHAGE DES RÉSULTATS SELON OPTION CHOISIE
    If (!$OutGrid)
	{
		$listenersInfo.Rows | Format-Table -AutoSize
    }

    if ($lostListener.Rows.Count -gt 0)
    {
        [int] $count = 0
        While ($count -lt $lostListener.Rows.Count)
        {

            Write-Host -Object $lostListener.Rows[$count].Message -BackgroundColor Red 
            Write-Host -Object " "
            $count += 1 
        }
        Write-Host " "
    }

    if ($OutGrid)
    {
		$listenersInfo.Rows | Out-GridView -Title "Listes des primaires par listeners" -Wait
    }

    Write-Host "Fin du traitement" -BackgroundColor Green

    if (!$OutGrid)
    {
        Read-Host -Prompt "Appuyez sur ''ENTRÉE'' pour continuer..."
    }
	
}


function Get-CIRXSQLServerCity
{
	
	Param (
		[parameter(Mandatory = $true,
				   HelpMessage = "Spécifier le nom du serveur (windows ou SQL)")]
		[string]$SQLServer
		
	)
	
	$count = 0
	[string]$node = $SQLServer
	[string]$ReturnCity
	
		
		
	if ($node -like '*\*')
	{
		$node = $node.Substring(0, $node.indexof("\"))
	}
	
	Try
	{
		$ip = Test-Connection -count 1 -ComputerName $node | Select-Object -Property "IPV4Address"
	}
	Catch
	{
		Return "Serveur $node inconnu"	
	}
		
	[string]$ip_string = $ip.IPV4Address.ToString()
	if ($ip_string.Substring(4, 2) -eq "16")
	{
		$ReturnCity = "LONGUEUIL"
	}
	elseif ($ip_string.Substring(4, 2) -eq "19")
	{
		$ReturnCity = "VARENNES"
	}
	else
	{
		$ReturnCity = "INCONNU"
	}
		
	return $ReturnCity	
	
}


