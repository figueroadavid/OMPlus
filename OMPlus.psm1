#Requires -RunAsAdministrator

$OMPrinterPath   = [System.IO.Path]::Combine($env:OMHOME, 'printers')
$OMBinPath       = [System.IO.Path]::Combine($env:OMHOME, 'bin')
$OMFormsPath     = [System.IO.Path]::Combine($env:OMHOME, 'forms')
$OMSystemPath    = [System.IO.Path]::Combine($env:OMHOME, 'system')
$OMModelPath     = [System.IO.Path]::Combine($env:OMHOME, 'model')

Write-Verbose -Message 'Setting parameters for OMPrimaryMPS, OMSecondaryMPS'
$pingMaster = Get-Content -Path ([System.IO.Path]::Combine( $OMSystemPath, 'pingMaster'))
if ($pingMaster -eq 'none') {
    $OMPrimaryMPS   = [system.net.dns]::GetHostByName($env:computername).hostname
    $IsOMPrimaryMPS = $true

    $pingParmPath   = [system.io.path]::combine($OMSystemPath, 'pingParms')
    $OMSecondaryMPS = (Get-Content -Path $pingParmPath |
        Where-Object { $_ -match '^Backup'}).Split('=')[1]
}
else {
    $IsOMPrimaryMPS = $false
    $OMPrimaryMPS   = $pingMaster
    $OMSecondaryMPS = [System.Net.Dns]::GetHostByName($env:computername).hostname
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
    $ValidTypes      = Get-OMDriverNames | Select-Object -ExpandProperty Driver | Sort-Object
}
$ValidModels = Get-ChildItem -Path $OMModelPath | Select-Object -ExpandProperty Name 

$CRLF                = [Environment]::NewLine
