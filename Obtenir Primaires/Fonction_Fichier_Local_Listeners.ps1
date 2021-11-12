################################################################################
#                                                                              #
# Importation et exportation des résultats pour l'obtention des primaires      #
# des listeners                                                                # 
#                                                                              #
# Créer par : Francis Thérien                                                  #
# Créer le 2017-06-28                                                          #
#                                                                              #
################################################################################
#
# Modification
# ¯¯¯¯¯¯¯¯¯¯¯¯
# Projet      Date       Nom
# xxxxxxxxxx  xx/xx/xxxx xxxxxxxxxxxxxxxxxxxxxxxx
#
################################################################################


function Import-ListenersState()
{
    [string] $DesktopPath = $env:USERPROFILE + "\Desktop";
    [string] $path = $DesktopPath + "\Listeners.txt";
    
    
    if (Test-Path -Path $path)
    {
        $Content = Get-Content -Path $path

    }

    return $content

}

function Export-ListenersState([PSObject] $Export_Listeners)
{
    [string] $DesktopPath = $env:USERPROFILE + "\Desktop";
    [string] $path = $DesktopPath + "\Listeners.txt";
    [string] $oldpath = $DesktopPath + "\Listeners_OLD.txt";
    [string] $oldFileName = "Listeners_OLD.txt";
    
    if (Test-Path -Path $path)
    {
        if (Test-Path -Path $oldPath)
        {
            $result = Remove-Item -Path $oldpath;
        }
        
        $result = Rename-Item -Path $path -NewName $oldFileName;
    }
    
    $result = New-Item -Path $path -ItemType File;

    ## Écriture de l'entête
    ## ********************

    Add-Content -Path $path -Value "*****************************************************************************";
    Add-Content -Path $path -Value "* Fichier sortie : Résultat de l'obtention des primaires pour les listeners *";
    Add-Content -Path $path -Value "*****************************************************************************";
    Add-Content -Path $path -Value "";
    [string] $DateTime = "En date du: ";
    $DateTime += Get-Date -Format F;
    Add-Content -Path $path -Value $DateTime;
    Add-Content -Path $path -Value "";    
    Add-Content -Path $path -Value "";

    ## Écriture du détail
    ## ******************
    [int] $count = 0;


    While ($count -lt $Export_listeners.Count)
    {
        # Listener
        [string] $content = "Listener            : ";
        $content += $Export_listeners[$count].Listener;
        Add-Content -Path $path -Value $content;
        
        [string] $content = "Primary             : ";
        $content += $Export_listeners[$count].Primary;
        Add-Content -Path $path -Value $content;

        [string] $content = "Health              : ";
        $content += $Export_listeners[$count].Health;
        Add-Content -Path $path -Value $content;

        [string] $content = "Availability group  : ";
        $content += $Export_listeners[$count].'Availability Group';
        Add-Content -Path $path -Value $content;

        [string] $content = "City                : ";
        $content += $Export_listeners[$count].City;
        Add-Content -Path $path -Value $content;

        
        Add-Content -Path $path -Value "";    
        $count += 1;
    }

}

function Import-ListenersList
{
    Param
    (
        [ValidateSet("QA","PD", "  ")]
        [string] $Env = "  "
    )
    
    [string] $RootPath = $PSScriptRoot;
    [string] $FullFileName = $RootPath + "\Liste Listeners.txt"
	
	
    If (Test-Path -Path $FullFileName)
    {

        $list = @()

		$Content = Get-Content -Path $FullFileName
		
		#Les lignes 0 à 6 sont des entêtes.
        [int] $count = 7
		
		#Déterminer l'endroit où se trouve le code d'environnement.
		[int]$EnvPos = $Content[$count].ToString().IndexOf(" PD")
		if ($EnvPos -lt 1)
		{
			[int]$EnvPos = $Content[$count].ToString().IndexOf(" QA")
		}
		
        While ($count -lt $Content.Count)
		{
			
			[string]$listenerName = $Content[$count].ToString().Substring(0, $Content[$count].ToString().IndexOf(" ") + 1)
			
			if ($listenerName.trim() -ne "")
			{
				
				
				
				if ($Env -ne "  ")
				{
					if ($Content[$count].ToString().Substring($EnvPos + 1, 2) -eq $Env)
					{
						$list += $listenerName
					}
				}
				else
				{
					$list += $listenerName
				}
			}
			$count += 1
			
			
		}
		
		return $list
	}
    else
    {
        return "Erreur - Fichier local Listener.txt non trouvé"
    }
    
}

function Export-ListenersList ([PSObject] $Listeners_List)
{
    [string] $RootPath = $PSScriptRoot;
    [string] $FullFileName = $RootPath + "\Liste Listeners.txt"
    [string] $Content = " "
    $result = New-Item -Path $FullFileName -ItemType File -Value "" -Force


    ## Écriture entête
    ## ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Add-Content -Path $FullFileName -Value "***********************************************************************"

    $Content = "* Liste des listeners en date du "
    $Content += Get-Date -Format F
    Add-Content -Path $FullFileName -Value $Content

    Add-Content -Path $FullFileName -Value "***********************************************************************"
    Add-Content -Path $FullFileName -Value ""
   
    ## Écriture détail
    ## ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    $Content = $Listeners_List | Out-String
    Add-Content -Path $FullFileName -Value $Content
	
	
}

