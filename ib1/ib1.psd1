﻿#
# Manifeste de module pour le module « PSGet_ib1 »
#
# Généré par : Wangler
#
# Généré le : 14/12/2017
#

@{

# Module de script ou fichier de module binaire associé à ce manifeste
RootModule = 'ib1.psm1'

# Numéro de version de ce module.
ModuleVersion = '1.0.8'

# ID utilisé pour identifier de manière unique ce module
GUID = '369b9a24-09ce-4df3-840f-80315b499bd4'

# Auteur de ce module
Author = 'Wangler'

# Société ou fournisseur de ce module
CompanyName = 'ib'

# Déclaration de copyright pour ce module
Copyright = '(c) 2017 ib. Tous droits réservés.'

# Description de la fonctionnalité fournie par ce module
Description = 'Simplification des installations'

# Version minimale du moteur Windows PowerShell requise par ce module
PowerShellVersion = '3.0'

# Nom de l'hôte Windows PowerShell requis par ce module
# PowerShellHostName = ''

# Version minimale de l'hôte Windows PowerShell requise par ce module
# PowerShellHostVersion = ''

# Version minimale du Microsoft .NET Framework requise par ce module
# DotNetFrameworkVersion = ''

# Version minimale de l'environnement CLR (Common Language Runtime) requise par ce module
# CLRVersion = ''

# Architecture de processeur (None, X86, Amd64) requise par ce module
# ProcessorArchitecture = ''

# Modules qui doivent être importés dans l'environnement global préalablement à l'importation de ce module
# RequiredModules = @()

# Assemblys qui doivent être chargés préalablement à l'importation de ce module
# RequiredAssemblies = @()

# Fichiers de script (.ps1) exécutés dans l’environnement de l’appelant préalablement à l’importation de ce module
# ScriptsToProcess = @()

# Fichiers de types (.ps1xml) à charger lors de l'importation de ce module
# TypesToProcess = @()

# Fichiers de format (.ps1xml) à charger lors de l'importation de ce module
# FormatsToProcess = @()

# Modules à importer en tant que modules imbriqués du module spécifié dans RootModule/ModuleToProcess
# NestedModules = @()

# Fonctions à exporter à partir de ce module
FunctionsToExport = 'compare-ib1PSVersion', 'get-ib1elevated', 'start-ib1VMWait', 
               'get-ib1VM', 'reset-ib1VM', 'set-ib1VhdBoot', 'remove-ib1VhdBoot', 
               'switch-ib1VMFr', 'test-ib1VMNet', 'connect-ib1VMNet', 
               'set-ib1TSSecondScreen', 'import-ib1TrustedCertificate'

# Applets de commande à exporter à partir de ce module
# CmdletsToExport = @()

# Variables à exporter à partir de ce module
# VariablesToExport = @()

# Alias à exporter à partir de ce module
# AliasesToExport = @()

# Ressources DSC à exporter depuis ce module
# DscResourcesToExport = @()

# Liste de tous les modules empaquetés avec ce module
# ModuleList = @()

# Liste de tous les fichiers empaquetés avec ce module
# FileList = @()

# Données privées à transmettre au module spécifié dans RootModule/ModuleToProcess. Cela peut également inclure une table de hachage PSData avec des métadonnées de modules supplémentaires utilisées par PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'ib'

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/renaudwangler/ib'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/renaudwangler/ib'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '1.0.8'

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable
    
 } # End of PrivateData hashtable

# URI HelpInfo de ce module
# HelpInfoURI = ''

# Le préfixe par défaut des commandes a été exporté à partir de ce module. Remplacez le préfixe par défaut à l’aide d’Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

