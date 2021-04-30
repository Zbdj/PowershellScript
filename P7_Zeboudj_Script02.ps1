#===========================================================================================#
# Usage : Ce script permet de lister les membres d'un groupe                                #
# Cmd : Interactif ou silencieux avec => powershell ./ListerMembres.ps1 -GroupName String   #
# Version : 1.6                                                                             #
# Auteur : Zeboudj Tristan                                                                  #
#===========================================================================================#

param([string]$GroupName)
Import-Module ActiveDirectory

function MembersInGroup{
    #Si le paramètre -GroupName n'est pas renseigné le script demande l'information
    if($GroupName -eq ""){
        #La commande Get-ADObject récupère toutes les OU disponibles au sein de notre active directory en les filtrant par Nom
        $OU = Get-ADObject -Filter {ObjectClass -eq 'organizationalunit'} | select name | Where-Object {$_.name -notlike "Domain Controllers"}

        #Boucle dans le tableau de reponse afin de lister les differentes OU
        foreach($organisation in $OU){
            Write-Host $OU.IndexOf($organisation) - $organisation.name
        }
        
        $GroupName = Read-Host "`nChoisissez un chiffre pour afficher les membres du groupe AD"
        $GroupName = $OU[$GroupName].name
    }

    #Cette commande récupere le nom de tous les utilisateurs présent dans le groupe en question
    try{
        $Response = Get-ADGroupMember -Identity ($GroupName)  | select name | Out-String
    } catch{}
  

    if($Response -eq $null){
        Write-Output "Le groupe $GroupName n'existe pas dans l'AD... Vous pouvez relancer le script sans paramètre afin d'afficher la liste des groupes présent dans l'AD"
        return 1
    } else {
        Write-Output "Vous avez choisis le groupe $GroupName, voici les membres :"
        Write-Output $Response
        #La réponse qui contient les noms des utilisateurs du groupe est enregistré dans un fichier .txt avec le nom du groupe en question
        "Membres du groupe $GroupName `n"+ $Response | Out-File C:\Users\Administrateur\Documents\GroupMembers$GroupName.txt

        $End = Read-Host "`nL'action s'est déroulée avec succès, taper A pour relancer le script ou n'importe quelle touche pour quitter... "

        #Cette condition permet de relancer le script en rapellant la fonction MembersInGroup ou bien de le quitter
        if($End -eq 'A'){
            $GroupName = ""
            MembersInGroup
        } else {
            return 0
        }
    }

}

MembersInGroup
