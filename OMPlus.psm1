#Requires -RunAsAdministrator

$Script:OMPrinterPath   = [System.IO.Path]::Combine($env:OMHOME, 'printers')
$Script:OMBinPath       = [System.IO.Path]::Combine($env:OMHOME, 'bin')
$Script:OMFormsPath     = [System.IO.Path]::Combine($env:OMHOME, 'forms')
$Script:OMSystemPath    = [System.IO.Path]::Combine($env:OMHOME, 'system')
$Script:OMModelPath     = [System.IO.Path]::Combine($env:OMHOME, 'model')

Write-Verbose -Message 'Setting parameters for OMPrimaryMPS, OMSecondaryMPS'
$pingMaster = Get-Content -Path ([System.IO.Path]::Combine( $OMSystemPath, 'pingMaster'))
if ($pingMaster -eq 'none') {
    $Script:OMPrimaryMPS   = [system.net.dns]::GetHostByName($env:computername).hostname
    $Script:IsOMPrimaryMPS = $true

    $pingParmPath   = [system.io.path]::combine($OMSystemPath, 'pingParms')
    $Script:OMSecondaryMPS = (Get-Content -Path $pingParmPath |
        Where-Object { $_ -match '^Backup'}).Split('=')[1]
}
else {
    $Script:IsOMPrimaryMPS = $false
    $Script:OMPrimaryMPS   = $pingMaster
    $Script:OMSecondaryMPS = [System.Net.Dns]::GetHostByName($env:computername).hostname
}

Remove-Variable -Name pingMaster,pingParmPath -ErrorAction SilentlyContinue

Get-ChildItem -Path $PSScriptRoot\Private -File -Filter *.ps1 | Where-Object fullname -notmatch '`.tests`.ps1' |
    ForEach-Object {
        Write-Verbose -Message ('Importing script: {0}' -f $_.FullName ) -Verbose
        . $_.FullName
    }

Get-ChildItem -Path $PSScriptRoot\Public -File -Filter *.ps1 | Where-Object fullname -notmatch '`.tests`.ps1' |
    ForEach-Object {
        Write-Verbose -Message ('Importing script: {0}' -f $_.FullName ) -Verbose
        . $_.FullName
    }

if ($IsOMPrimaryMPS) {
    $script:ValidTypes      = Get-OMDriverNames | Select-Object -ExpandProperty Driver | Sort-Object
}

$script:ValidModels = Get-ChildItem -Path $OMModelPath | Select-Object -ExpandProperty Name

$CRLF                = [Environment]::NewLine
