###########################################################
#                      Variables globales                 #
###########################################################
#

function private:compare-ib1PSVersion ($ibVersion='4.0') {
if ($PSVersionTable.PSCompatibleVersions -notcontains $ibVersion) {
  write-warning "Attention, script pr�vu pour Fonctionner avec Powershell $ibVersion"}}

function private:get-ib1elevated ($ibElevationNeeded=$false) {
if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{ return $true }
else {
if ($ibElevationNeeded) {
  write-error "Attention, cette commande n�cessite d'�tre execut�e en tant qu'administrateur"; break}
else { return $false}}}


function global:set-ib1VhdBoot {
<#
.SYNOPSIS
Cette commande permet de monter le disque virtuel contenu dans le fichier VHD sp�cifi� et de rajouter le d�marrage sur la partition non r�serv�e contenue au BCD.
.PARAMETER VHDFile
Nom du fichier VHD contenant le disque virtuel � monter.
.PARAMETER restart
Red�marre l'ordinateur � la fin du script (inactif par d�faut)
.EXAMPLE
set-ib1vhboot -VHDFile 'c:\program files\microsoft learning\base\20470b-lon-host1.vhd
Monte la partition contenue dans le fichier VHD fourni.
.EXAMPLE
set-ib1vhboot -VHDFile 'c:\program files\microsoft learning\base\20470b-lon-host1.vhd -restart
Monte la partition contenue dans le fichier VHD fourni et red�marre dessus.
#>
[CmdletBinding(
DefaultParameterSetName='VHDFile',
SupportsShouldProcess=$true)]
PARAM(
[parameter(Mandatory=$true,ValueFromPipeLine=$true,HelpMessage='Fichier VHD contenant le disque virtuel � monter (avec une partition syst�me)')]
[string]$VHDfile,
[switch]$restart=$false)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
# Attacher un VHD et le rajouter au menu de d�marrage
process {
write-debug "`$VHDfile=$VHDfile"
try { Mount-VHD -Path $vhdFile -ErrorAction stop }
catch {
  write-error "Impossible de monter le disque virtuel contenu dans le fichier $VHDFile."
  break}
$dLetter=(get-disk|where friendlyname -ilike "*microsoft*"|Get-Partition|Get-Volume|where {$_.filesystemlabel -ine "system reserved" -and $_.filesystemlabel -ine "r�serv�e au syst�me"}).driveletter+":"
write-debug "Disque(s) de lecteur Windows trouv�(s) : $dLetter"
if ($dLetter.Count -ne 1) {
 write-error 'Impossible de trouver un disque virtuel mont� qui contienne une unique partition non r�serv�e au syst�me.'
 break}
bcdboot $dLetter\windows /l fr-FR >> $null
bcdedit /set '{default}' Description ([io.path]::GetFileNameWithoutExtension($VHDFile)) >> $null
if ($restart) {Restart-Computer}}}

function global:remove-ib1VhdBoot {
<#
.SYNOPSIS
Cette commande permet de supprimer l'entr�e par d�faut du BCD et de d�monter tous les disques virtuels mont�s sur la machine.
.PARAMETER restart
Red�marre l'ordinateur � la fin du script (inactif par d�faut)
.EXAMPLE
remove-ib1vhboot -restart
supprimer l'entr�e par d�faut du BCD et red�marre la machine.
#>
[CmdletBinding(
DefaultParameterSetName='restart')]
PARAM(
[switch]$restart=$false)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
#Trouve tous les disques virtuels pour les d�monter
process {

get-disk|where FriendlyName -ilike "*microsoft*"|foreach {write-debug $_;get-partition|dismount-vhd -erroraction silentlycontinue}
write-debug "Supression de l'entr�e {Default} du BCD"
bcdedit /delete '{default}' >> $null
if ($restart) {Restart-Computer}}}