#=======================================================================================================#
# Usage : Ce script permet d'ajouter un utilisateur dans l'AD et de créer un dossier partagé a son nom  #
# Cmd : Interactif ou silencieux avec => powershell ./NewUser.ps1 -Prenom -Nom -GroupName        #
# Version : 2.3                                                                                         #
# Auteur : Zeboudj Tristan                                                                              #
#=======================================================================================================#

param($Prenom, $Nom, $GroupName)
Import-Module ActiveDirectory

function newUserInAd {
    #Si les paramètre ne sont pas renseigné le script demande l'information
    if($Prenom -eq ""){
        $Prenom = Read-Host "Prénom du nouvel utilisateur:"
    }
    if($Nom -eq ""){
        $Nom = Read-Host "Nom du nouvel utilisateur:"
    }
    if($GroupName -eq ""){
        #La commande Get-ADObject récupère toutes les OU disponibles au sein de notre active directory en les filtrant par Nom
        $OU = Get-ADObject -Filter {ObjectClass -eq 'organizationalunit'} | select name | Where-Object {$_.name -notlike "Domain Controllers"}
        
        #Boucle dans le tableau de reponse afin de lister les differentes OU
        foreach($organisation in $OU){
            Write-Host $OU.IndexOf($organisation) - $organisation.name
        }

        $GroupName = Read-Host "`n Indiquez le chiffre correspondant au groupe du nouvel utilisateur"
        $GroupName = $OU[$GroupName].name
    }
#------------------------------------------------------------------------------------------------------------------------------#
    #Création des variables nécessaire à la commande d'ajout d'utilisateur dans l'ad

    #Prenom et Nom avec la premiere lettre en majuscule
    $Prenom = ($Prenom.substring(0,1)).ToUpper() + $Prenom.substring(1)
    $Nom = ($Nom.substring(0,1)).ToUpper() + $Nom.substring(1)

    #Premiere lettre du prenom + le nom de l'utilisateur en minuscule
    $accountName = ($Prenom.Substring(0,1)+$Nom).ToLower()
    $defaultPwd = "pwd2021?"

    #Prenom suivit des initiales en majuscule ainsi que le nom (ex: Prenom PN. Nom)
    $nameInit = $Prenom + " " + ($Prenom.Substring(0,1) + $Nom.Substring(0,1) + ". ").ToUpper() + $Nom
#------------------------------------------------------------------------------------------------------------------------------#

    #Get-ADUser vérifie si l'utilisateur existe dans l'AD
    $UserExist = Get-ADUser -Filter "SamAccountName -eq '$accountName'"

    #Si l'utilisateur n'existe pas le script l'ajoute dans l'ad sinon le script s'arrête, il y a la possibilité de le relancer en tapant "A"
    if($UserExist -eq $null){
        #Cette commande ajoute l'utilisateur dans l'ad
        New-ADUser -Name $nameInit -GivenName $Prenom -Surname $Nom -SamAccountName $accountName -UserPrincipalName $accountName@acme.fr -AccountPassword (ConvertTo-SecureString -AsPlainText $defaultPwd -Force) -Enabled $true -ChangePasswordAtLogon $true -Path "OU=$Groupname,dc=acme,dc=fr"
        #Puis dans le groupe de sécurité correspondant à l'OU choisie
        Add-ADGroupMember -Identity $GroupName -Members $accountName

        #Cette commande crée un nouveau dossier au nom de l'utilisateur
        New-Item -ItemType directory -Path C:\Partage\UserPartage\$accountName@acme.fr | Out-Null
        #New-SmbShare partage le dossier sur le serveur
        New-SmbShare -Name $accountName@acme.fr -Path C:\Partage\UserPartage\$accountName@acme.fr

        #Le script récupère les autorisasions sur le dossier et supprime toutes les autorisations héritées
        $acl = Get-Acl C:\Partage\UserPartage\$accountName@acme.fr
        $acl.SetAccessRuleProtection($true,$false)
        $acl | Set-Acl

        #Ajout des droits FullControl pour l'utilisateur ainsi que l'administrateur
        $accessUser = New-Object System.Security.AccessControl.FileSystemAccessRule("$accountName","FullControl","ContainerInherit, ObjectInherit", "None","Allow")
        $accessAdmin = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrateur","FullControl","ContainerInherit, ObjectInherit", "None","Allow")
        $acl.SetAccessRule($accessUser)
        $acl.SetAccessRule($accessAdmin)
        $acl | Set-Acl

        #Cette condition permet de relancer le script en rapellant la fonction newUserInAd ou bien de le quitter
        $End = Read-Host "`nL'action s'est déroulée avec succès, taper A pour relancer le script ou n'importe quelle touche pour quitter... "

            if($End -eq 'A'){
                newUserInAd
            } else {
                return 0
            }
    } else {
        $End = Read-Host "L'utilisateur $Prenom,$Nom, existe déja dans l'AD, taper A pour relancer le script ou n'importe quelle touche pour quitter..."
        
            if($End -eq 'A'){
                newUserInAd
            } else {
                return 0
            }
    }
}

newUserInAd
