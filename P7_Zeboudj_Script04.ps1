#===========================================================================================#
# Usage : Ce script permet de sauvegarder les dossiers de l'utilisateur sur le serveur      #
# Cmd : Le script est lancé avec le plannificateur de tâches                                #
# Version : 1.4                                                                             #
# Auteur : Zeboudj Tristan                                                                  #
#===========================================================================================#

#Le script récupere le nom de la session actuellement en cours
$session = $env:USERNAME
$pc = $env:COMPUTERNAME

function checkFolder {
    #Test-Path vérifie si un dossier au nom de l'utilisateur sur le serveur existe
    if((Test-Path -Path \\Win-fqm9kj6kb7n\SAV\$pc) -eq $false){
        #Si le dossier n'existe pas, cette commande le crée
        New-Item -ItemType directory -Path \\Win-fqm9kj6kb7n\SAV\$pc | Out-Null
    }

    #Appel de la fonction saveData qui permet d'enregistrer tous les documents
    saveData
}

function saveData {
        #Boucle sur les dossiers de l'utilisateur afin de récupérer le nom des fichiers/dossier qui ne sont pas cachés
         ForEach ($Files in (Get-ChildItem -Path "C:\Users" -Name -Recurse)) {
         if($Files -notmatch "Public"){
          #Robocopy copie les données d’un fichier d’un emplacement à un autre.
          robocopy "C:\Users\$Files" "\\Win-fqm9kj6kb7n\SAV\$pc\$Files" /COPYALL
        }
     
      }
        return 0
}

checkFolder
