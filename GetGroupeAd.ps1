#========================================================================================#
# Usage : Ce script permet de lister les groupes dans lesquel l'utilisateur est membre   #
# Cmd : Interactif ou silencieux avec => powershell ./GetGroupAd.ps1 -Username String    #
# Version : 1.8                                                                          #
# Auteur : Zeboudj Tristan                                                               #
#========================================================================================#

param([string]$Username)
Import-Module ActiveDirectory

function GetGroup {
    #Si le paramètre -Username n'est pas renseigné le script demande l'information
    if($Username -eq ""){
        $Username = Read-Host "Pour quel utilisateur souhaitez vous afficher les groupes AD dans lesquel il est membre?"
    }

    #Get-ADUser vérifie si l'utilisateur existe dans l'AD
    $UserExist = Get-ADUser -Filter "SamAccountName -eq '$Username'"

    #Si l'utilisateur n'existe pas, le script s'arrête, il y a la possibilité de le relancer en tapant "o"
    if($UserExist -eq $null){
        $Retry = Read-Host "`nL'utilisateur $Username n'existe pas dans l'AD, souhaitez vous relancer une recherche? (OUI = o / NON = n)"
            if($Retry -eq 'o'){
                GetGroup
            }
    } else {
            #Cette commande récupere le nom des groupes dans lesquel l'utilisateur est membre
            $Response = Get-ADPrincipalGroupMembership -Identity $Username | select name | Out-String

            Write-Host "`nL'utilisateur $Username est membre des groupes suivants : `n"
            Write-Output $Response
            #La réponse qui contient les noms des groupes est enregistré dans un fichier .txt avec l'identifiant de l'utilisateur en question
            "$Username est membre des groupes:`n"+ $Response | Out-File C:\Users\Administrateur\Documents\GroupList$Username.txt
            
            #Cette condition permet de relancer le script en rapellant la fonction GetGroup ou bien de le quitter
            $End = Read-Host "L'action s'est déroulée avec succès, taper A pour relancer le script ou n'importe quelle touche pour quitter... "
                if($End -eq 'A'){
                    $Username = ""
                    GetGroup
                } else {
                    return 0
                }
            }
}

GetGroup