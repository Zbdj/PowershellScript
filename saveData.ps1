#===========================================================================================#
# Usage : Ce script permet de sauvegarder les dossiers de l'utilisateur sur le serveur      #
# Cmd : Le script est lancé avec le plannificateur de tâches                                #
# Version : 1.4                                                                             #
# Auteur : Zeboudj Tristan                                                                  #
#===========================================================================================#

#Le script récupere le nom de la session actuellement en cours
$session = $env:USERNAME

function checkFolder {
    #Test-Path vérifie si un dossier au nom de l'utilisateur sur le serveur existe
    if((Test-Path -Path \\Win-fqm9kj6kb7n\SAV\$session) -eq $false){
        #Si le dossier n'existe pas, cette commande le crée
        New-Item -ItemType directory -Path \\Win-fqm9kj6kb7n\SAV\$session | Out-Null
    }

    #Appel de la fonction saveData qui permet d'enregistrer tous les documents
    saveData
}

function saveData {
        #Boucle sur les dossiers de l'utilisateur afin de récupérer le nom des fichiers/dossier qui ne sont pas cachés
         ForEach ($Files in (Get-ChildItem -Path "C:\Users\$session\" -Name -Recurse)) {
            #Robocopy copie les données d’un fichier d’un emplacement à un autre.
                #/SEC copie les securités ACL / NTFS
                #/MIR copie tous les sous répertoires + supprime les fichiers qui n'existe plus
                #/NFl /NDL indique que les noms de fichier/répertoire ne doivent pas être consignés. (?:*<>)
            robocopy "C:\Users\$session\$Files" "\\Win-fqm9kj6kb7n\SAV\$session\$Files" /COPYALL /SEC /MIR /R:0 /W:0 /NFL /NDL
            #Les fichiers enfants hériste des autorisations du dossier parent
            icacls "\\Win-fqm9kj6kb7n\SAV\$session\$Files" /reset /t /c
      }
        return 0
}

checkFolder