###########################################################
#                      Variables globales                 #
###########################################################
#
$global:ib1Version='1.0.1.2'
$global:ib1DISMUrl="https://msdn.microsoft.com/en-us/windows/hardware/dn913721(v=vs.8.5).aspx"
$global:ib1DISMPath='C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\dism.exe'

function compare-ib1PSVersion ($ibVersion='4.0') {
if ($PSVersionTable.PSCompatibleVersions -notcontains $ibVersion) {
  write-warning "Attention, script pr�vu pour Fonctionner avec Powershell $ibVersion"}}

function get-ib1elevated ($ibElevationNeeded=$false) {
if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{ if (-not $ibElevationNeeded) { return $true}}
else {
if ($ibElevationNeeded) {
  write-error "Attention, cette commande n�cessite d'�tre execut�e en tant qu'administrateur" -Category AuthenticationError; break}
else { return $false}}}

function start-ib1VMWait ($SWVmname) {
  if ((get-vm $SWVmname).state -ne "Running") {
    Start-VM $SWVmname
    while ((get-vm $SWVmname).heartbeat -ne 'OKApplicationsHealthy') {
      write-progress -Activity "D�marrage de $SWVmname" -currentOperation "Attente de signal de d�marrage r�ussi de la VM"
      start-sleep 2}
    write-progress -Activity "D�marrage de $SWVmname" -complete}}

function get-ib1VM ($gVMName) {
  if ($gVMName -eq '') {
  try { $gResult=Get-VM -ErrorAction stop }
  catch {
    write-error "Impossible de trouver des machines virtuelles sur ce Windows." -Category ObjectNotFound
    break}}
  else {
  try { $gResult=Get-VM $gVMName -ErrorAction stop }
  catch {
  write-error "Impossible de trouver une machine virtuelle nomm�e $gVMName." -Category ObjectNotFound
    break}}
  return $gResult}

function global:reset-ib1VM {
<#
.SYNOPSIS
Cette commande permet de r�tablir les VMs du serveur Hyper-v � leur dernier checkpoint.
.PARAMETER VMName
Nom de la VMs � r�tablir. si ce param�tre est omis toutes les VMs trouv�es seront r�tablies
.PARAMETER keepVMUp
N'arr�te pas les VMs dont le dernier checkpoint est dans l'�tat allum� avant de les r�tablir
.EXAMPLE
reset-ib1VM -VMName 'lon-dc1'
R�tablit la VM 'lon-dc1' � son dernier point de contr�le.
.EXAMPLE
reset-ib1VM -keepVMUp
R�tablir toutes les VMS � leur dernier point de contr�le, sans les �teindre.
#>
[CmdletBinding(
DefaultParameterSetName='keepVMUp')]
PARAM(
[switch]$keepVMUp=$false,
[string]$VMName)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
process {
$VMs2Reset=get-ib1VM $VMName
foreach ($VM2reset in $VMs2Reset) {
  if ($snapshot=Get-VMSnapshot -VMName $VM2reset.vmname|sort creationtime|select -last 1 -ErrorAction SilentlyContinue) {
    if (-not $keepVMUp -and $VM2reset.state -ieq 'running') {
      Write-Debug "Arr�t de la VM $($VM2reset.vmname)."
      stop-vm -VMName $VM2reset.vmname -confirm:$false}
    Write-Debug "Restauration du snapshot $($snapshot.Name) sur la VM $($VM2reset.vmname)."
    Restore-VMSnapshot $snapshot -confirm:$false}
  else {write-debug "La VM $($VM2reset.vmname) n'a pas de snapshot"}}}
  end {echo "Fin de l'op�ration"}}

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
DefaultParameterSetName='VHDFile')]
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
  write-error "Impossible de monter le disque virtuel contenu dans le fichier $VHDFile." -Category ObjectNotFound
  break}
$dLetter=(get-disk|where friendlyname -ilike "*microsoft*"|Get-Partition|Get-Volume|where {$_.filesystemlabel -ine "system reserved" -and $_.filesystemlabel -ine "r�serv�e au syst�me"}).driveletter+":"
write-debug "Disque(s) de lecteur Windows trouv�(s) : $dLetter"
if ($dLetter.Count -ne 1) {
 write-error 'Impossible de trouver un disque virtuel mont� qui contienne une unique partition non r�serv�e au syst�me.' -Category ObjectNotFound
 break}
bcdboot $dLetter\windows /l fr-FR >> $null
bcdedit /set '{default}' Description ([io.path]::GetFileNameWithoutExtension($VHDFile)) >> $null
echo 'BCD modifi�'
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
echo 'BCD modifi�'
if ($restart) {Restart-Computer}}}

function global:switch-ib1VMFr {
<#
.SYNOPSIS
Cette commande permet de changer le clavier d'une marchine virtuelle en Fran�ais.
(Ne fonctionne que sur les VMs �teinte au moment ou la commande est lan��e)
.PARAMETER VMName
Nom de la VM sur laquelle agir (agit sur toutes les VMs si param�tre non sp�cifi�)
.PARAMETER noCheckpoint
Ne cr�e pas les points de contr�le sur la VM avant et apr�s action
.EXAMPLE
switch-ib1VMFr
Change le clavier de la VM en Fran�ais.
#>
[CmdletBinding(
DefaultParameterSetName='VMName')]
PARAM(
[string]$VMName='',
[switch]$noCheckpoint=$false)
begin{get-ib1elevated $true; compare-ib1PSVersion "4.0"}
process {
$VMs2switch=get-ib1VM $VMName
foreach ($VM2switch in $VMs2switch) {
  if ($VM2switch.state -ine 'off') {echo "La VM $($VM2switch.name) n'est pas �teinte et ne sera pas trait�e"}
  else {
    #Remove-VMSnapshot -vm $VM2switch -ErrorAction SilentlyContinue
    #Checkpoint-VM -VM $VM2switch -SnapshotName "Original"
    Write-Debug "Changement des param�tres lingustiques de la VM $($VM2switch.name)"
    write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Montage du disque virtuel."
    $vhdPath=($VM2switch|Get-VMHardDiskDrive|where {$_.ControllerNumber -eq 0 -and $_.controllerLocation -eq 0}).path
    $testMount=$null
    mount-vhd -path $vhdPath -NoDriveLetter -passthru -ErrorVariable testMount -ErrorAction SilentlyContinue|get-disk|Get-Partition|where isactive -eq $false|Set-Partition -newdriveletter Z
    if ($testMount -eq $null) {Write-Error "Impossible de monter le disque dur... de la VM $($VM2switch.name)" -Category invalidResult}
    else {
      if (-not $noCheckpoint) {
        write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Cr�ation du checkpoint ib1SwitchFR-Avant."
        Dismount-VHD $vhdPath
        Checkpoint-VM -VM $VM2switch -SnapshotName "ib1SwitchFR-Avant"
        mount-vhd -path $vhdPath -NoDriveLetter -passthru -ErrorVariable testMount -ErrorAction SilentlyContinue|get-disk|Get-Partition|where isactive -eq $false|Set-Partition -newdriveletter Z}
      write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Changement des options linguistiques."
      & $ib1DISMPath /image:z: /set-allIntl:en-US /set-inputLocale:0409:0000040c >>$ $null
      if ($LASTEXITCODE -eq 50) {
        Start-Process -FilePath $ib1DISMUrl
        write-error "Si le probl�me vient de la version de DISM, merci de l'installer depuis la fen�tre de navigateur ouverte (installer localement et choisir les 'Deployment Tools' uniquement." -Category InvalidResult
        dismount-vhd $vhdpath
        if (-not $noCheckpoint) {
          Restore-VMSnapshot -VM $VM2switch -Name "ib1SwitchFR-Avant"
          Remove-VMSnapshot -VM $VM2switch -Name "ib1SwitchFR-Avant"}
        break}
      elseif ($LASTEXITCODE -ne 0) {
        write-warning "Probl�me pendant le changemement de langue de la VM '$($VM2switch.name)'. Merci de v�rifier!' (D�tail de l'erreur ci-dessous)."
        write-output $error|select -last 1
        if (-not $noCheckpoint) {
          Restore-VMSnapshot -VM $VM2switch -Name "ib1SwitchFR-Avant"
          Remove-VMSnapshot -VM $VM2switch -Name "ib1SwitchFR-Avant"}}
      write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "D�montage du disque."
      dismount-vhd $vhdpath
      Start-Sleep 1}
    if (-not $noCheckpoint) {
      write-progress -Activity "Traitement de $($VM2switch.name)" -currentOperation "Cr�ation du checkpoint ib1SwitchFR-Apr�s."
      Checkpoint-VM -VM $VM2switch -SnapshotName "ib1SwitchFR-Apr�s"}
    write-progress -Activity "Traitement de $($VM2switch.name)" -complete}}
}}

function global:test-ib1VMNet {
<#
.SYNOPSIS
Cette commande permet de tester si les VMs sont bien connect�es aux r�seaux virtuel de l'h�te Hyper-V.
.EXAMPLE
test-ib1VMNet
Indiquera si des VMs sont branch�es sur des switchs virtuels non d�clar�s.
#>
$vSwitchs=(Get-VMSwitch).name
$VMs=Get-VM
foreach ($VM in $VMs) {
  Write-progress -Activity "V�rification de la configuration r�seau de la VM $($VM.Name)."
  foreach ($VMnetwork in $VM.NetworkAdapters) {
    Write-progress -Activity "V�rification de la configuration r�seau de la VM $($VM.Name)." -CurrentOperation "V�rification de la pr�sence du switch $($VMnetwork.name)"
    if ($VMnetwork.SwitchName -notin $vSwitchs) {Write-Warning "La VM '$($VM.Name)' est branch�e sur le switch virtuel '$($VMnetwork.SwitchName)' qui est introuvable. Merci de v�rifier !"}}
  Write-progress -Activity "V�rification de la configuration r�seau de la VM $($VM.Name)." -Completed}}

function global:connect-ib1VMNet {
<#
.SYNOPSIS
Cette commande permet de mettre en place les pr�requis r�seau sur la machine Hyper-V H�te.
(Une et une seule carte r�seau physique doit �tre connect�e au r�seau)
.PARAMETER externalNetworkname
Nom (obligatoire) du r�seau virtuel qui sera connect� au r�seau externe
.EXAMPLE
connect-ib1VMNet "External Network"
Cr�er un r�seau virtuel nomm� "External Network" et le connecte � la carte r�seau physique branch�e (ou Wi-Fi connect�e).
#>
[CmdletBinding(
DefaultParameterSetName='externalNetworkName')]
PARAM(
[parameter(Mandatory=$true,ValueFromPipeLine=$true,HelpMessage='Nom du r�seau virtuel � connecter au r�seau externe.')]
[string]$externalNetworkname='External Network')
get-ib1elevated $true
compare-ib1PSVersion "4.0"
$extNic=Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred -PrefixOrigin Dhcp|Get-NetAdapter
if ($extNic.PhysicalMediaType -eq "Unspecified") {
  if ((Get-VMSwitch $externalNetworkname  -switchtype External -ErrorAction SilentlyContinue).NetAdapterInterfaceDescription -eq (Get-NetAdapter -Physical|where status -eq up).InterfaceDescription) {
    Write-warning "La configuration r�seau externe est d�ja correcte"
    break}
  else {
    Write-Warning "La carte r�seau est d�ja connect�e � un switch virtuel. Suppression!"
    $switch2Remove=Get-VMSwitch -SwitchType External|where {$extNic.name -like '*'+$_.name+'*'}
    Write-Progress -Activity "Suppression de switch virtuel existant" -currentOperation "Attente pour suppression de '$($switch2Remove.name)'."
    Remove-VMSwitch -Force -VMSwitch $switch2Remove
    for ($sleeper=0;$sleeper -lt 20;$sleeper++) {
      Write-Progress -Activity "Suppression de switch virtuel existant" -currentOperation "Attente pour suppression de '$($switch2Remove.name)'." -PercentComplete ($sleeper*5)
      Start-Sleep 1}
    Write-Progress -Activity "Suppression de switch virtuel existant" -Completed}
    $extNic=Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred -PrefixOrigin Dhcp|Get-NetAdapter}
  if (Get-VMSwitch $externalNetworkname -ErrorAction SilentlyContinue) {
    Write-Warning "Le switch '$externalNetworkname' existe. Branchement sur la bonne carte r�seau"
    Get-VMSwitch $externalNetworkname|Set-VMSwitch -netadaptername $extNic.Name
    start-sleep 2}
  else {
    Write-Progress -Activity "Cr�ation du switch" -CurrentOperation "Cr�ation du switch virtuel '$externalNetworkname' et branchement sur la carte r�seau."
    New-VMSwitch -Name $externalNetworkname -netadaptername $extNic.Name >> $null
    Write-Progress -Activity "Cr�ation du switch" -Completed}
test-ib1VMNet}

function global:set-ib1TSSecondScreen {
<#
.SYNOPSIS
Cette commande permet de basculer l'�cran distant d'une connexion RDP sur l'�cran s�condaire (seuls 2 �crans g�r�s).
.PARAMETER TSCFilename
Nom (obligatoire) du fichier .rdp dont la configuration par la pr�sente commande doit �tre modifi�e
.EXAMPLE
set-ib1TSSecondScreen "c:\users\ib\desktop\myremoteVM.rdp"
Modifiera le fichier indiqu� pour que l'affichage de la machine distante se fasse sur le second �cran.
#>
[CmdletBinding(
DefaultParameterSetName='TSCFilename')]
PARAM(
[parameter(Mandatory=$true,ValueFromPipeLine=$true,HelpMessage='Nom du fichier RDP � modifier.')]
[string]$TSCFilename='')
begin {compare-ib1PSVersion "4.0"}
process {
if (Test-Path $TSCFilename) {
  $oldFile=Get-Content $TSCFilename
  $newFile=@()
  Add-Type -AssemblyName System.Windows.Forms
  $Monitors = [System.Windows.Forms.Screen]::AllScreens
  foreach ($fileLine in (get-content C:\Users\ib\Desktop\marsAdmin11.rdp)){
    if ($fileLine -ilike '*winposstr*') {
      $newFile+="$($fileLine.split(",")[0]),$($fileLine.split(",")[1]),$($Monitors[1].WorkingArea.X),$($Monitors[1].WorkingArea.Y),$($Monitors[1].WorkingArea.X+$Monitors[1].Bounds.Width),$($Monitors[1].WorkingArea.Y+$Monitors[1].Bounds.Height)"}
    else {$newFile+=$fileLine}}
  Set-Content $TSCFilename $newFile}
else {write-error "Le fichier '$TSCFilename' est introuvable" -Category ObjectNotFound;break}
}}