# PowershellScript
Script Powershell d'automatisation de tâche dans l'Active Directory

Ce projet "PowershellScript" comporte 4 script versionnés et commentés qui vont permettrent l’automatisation de différentes tâches dans l’active directory.
Les scripts sont interactif si les arguments ne sont pas fournis.

## P7_Zeboudj_Script01.ps1

Ce script permet d'ajouter un utilisateur dans l'AD et de créer un dossier partagé à son nom, seul le nouvel utilisateur et l’administrateur auront accès à ce dossier
Executer en ligne de commande avec trois arguments Prénom,  Nom et GroupName, de type String => *powershell ./NewUser.ps1 -Prenom "Alain" -Nom "Firmerie" -GroupName "Direction Generale"*

## P7_Zeboudj_Script02

Ce script permet de lister tous les membres d'un groupe AD, puis enregistre la réponse dans un fichier .txt
Executer en ligne de commande avec un argument GroupName de type String => *powershell ./ListerMembres.ps1 -GroupName "Accueil"*

## P7_Zeboudj_Script03

Ce script permet de lister les différents groupes dans lesquel l'utilisateur est membre, puis enregistre la réponse dans un fichier .txt
Executer en ligne de commande avec un argument Username de type String => *powershell ./GetGroupAd.ps1 -Username "afirmerie"*

## P7_Zeboudj_Script04.ps1

Ce script permet de sauvegarder les dossiers de l'utilisateur sur le serveur Windows, dans un dossier partagé nommé « SAV »
*Le script est lancé avec le planificateur de tâches tous les jours à 17h*


Créez des services partagés en entreprise et automatisez des tâches

Auteur: Zeboudj Tristan
