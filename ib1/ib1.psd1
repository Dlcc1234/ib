#
# Manifeste de module pour le module ��PSGet_ib1��
#
# G�n�r� par�: Wangler
#
# G�n�r� le�: 02/08/2019
#

@{

# Module de script ou fichier de module binaire associ� � ce manifeste
RootModule = 'ib1.psm1'

# Num�ro de version de ce module.
ModuleVersion = '2.5.20'

# �ditions PS prises en charge
# CompatiblePSEditions = @()

# ID utilis� pour identifier de mani�re unique ce module
GUID = '369b9a24-09ce-4df3-840f-80315b499bd4'

# Auteur de ce module
Author = 'Wangler'

# Soci�t� ou fournisseur de ce module
CompanyName = 'ib'

# D�claration de copyright pour ce module
Copyright = '(c) 2018 ib. Tous droits r�serv�s.'

# Description de la fonctionnalit� fournie par ce module
Description = 'Simplification des installations'

# Version minimale du moteur Windows PowerShell requise par ce module
PowerShellVersion = '5.0'

# Nom de l'h�te Windows PowerShell requis par ce module
# PowerShellHostName = ''

# Version minimale de l'h�te Windows PowerShell requise par ce module
# PowerShellHostVersion = ''

# Version minimale du Microsoft .NET Framework requise par ce module. Cette configuration requise est valide uniquement pour PowerShell Desktop Edition.
# DotNetFrameworkVersion = ''

# Version minimale de l�environnement CLR (Common Language Runtime) requise par ce module. Cette configuration requise est valide uniquement pour PowerShell Desktop Edition.
# CLRVersion = ''

# Architecture de processeur (None, X86, Amd64) requise par ce module
# ProcessorArchitecture = ''

# Modules qui doivent �tre import�s dans l'environnement global pr�alablement � l'importation de ce module
# RequiredModules = @()

# Assemblys qui doivent �tre charg�s pr�alablement � l'importation de ce module
# RequiredAssemblies = @()

# Fichiers de script (.ps1) ex�cut�s dans l�environnement de l�appelant pr�alablement � l�importation de ce module
ScriptsToProcess = '.\moduleImport.ps1'

# Fichiers de types (.ps1xml) � charger lors de l'importation de ce module
# TypesToProcess = @()

# Fichiers de format (.ps1xml) � charger lors de l'importation de ce module
# FormatsToProcess = @()

# Modules � importer en tant que modules imbriqu�s du module sp�cifi� dans RootModule/ModuleToProcess
# NestedModules = @()

# Fonctions � exporter � partir de ce module. Pour de meilleures performances, n�utilisez pas de caract�res g�n�riques et ne supprimez pas l�entr�e. Utilisez un tableau vide si vous n�avez aucune fonction � exporter.
FunctionsToExport = 'install-ib1Chrome', 'complete-ib1Setup', 'invoke-ib1NetCommand', 
               'new-ib1Shortcut', 'reset-ib1VM', 'mount-ib1VhdBoot', 
               'remove-ib1VhdBoot', 'switch-ib1VMFr', 'test-ib1VMNet', 
               'connect-ib1VMNet', 'set-ib1TSSecondScreen', 
               'import-ib1TrustedCertificate', 'set-ib1VMCheckpointType', 
               'repair-ib1VMNetwork', 'Copy-ib1VM', 'start-ib1SavedVMs', 'get-ib1Log', 
               'get-ib1Version', 'stop-ib1ClassRoom', 'new-ib1Nat', 'invoke-ib1Clean', 
               'invoke-ib1Rearm', 'get-ib1Repo', 'set-ib1VMExternalMac', 
               'install-ib1Course', 'set-ib1ChromeLang', 'set-ib1VMCusto', 
               'invoke-ib1TechnicalSupport'

# Applets de commande � exporter � partir de ce module. Pour de meilleures performances, n�utilisez pas de caract�res g�n�riques et ne supprimez pas l�entr�e. Utilisez un tableau vide si vous n�avez aucune applet de commande � exporter.
CmdletsToExport = @()

# Variables � exporter � partir de ce module
# VariablesToExport = @()

# Alias � exporter � partir de ce module. Pour de meilleures performances, n�utilisez pas de caract�res g�n�riques et ne supprimez pas l�entr�e. Utilisez un tableau vide si vous n�avez aucun alias � exporter.
AliasesToExport = 'set-ib1VhdBoot', 'ibreset', 'get-ib1Git', 'ibSetup', 'stc', 'ibStop'

# Ressources DSC � exporter depuis ce module
# DscResourcesToExport = @()

# Liste de tous les modules empaquet�s avec ce module
# ModuleList = @()

# Liste de tous les fichiers empaquet�s avec ce module
FileList = 'ibInit.ps1'

# Donn�es priv�es � transmettre au module sp�cifi� dans RootModule/ModuleToProcess. Cela peut �galement inclure une table de hachage PSData avec des m�tadonn�es de modules suppl�mentaires utilis�es par PowerShell.
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
        ReleaseNotes = '2.3.2'

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# URI HelpInfo de ce module
# HelpInfoURI = ''

# Le pr�fixe par d�faut des commandes a �t� export� � partir de ce module. Remplacez le pr�fixe par d�faut � l�aide d�Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

