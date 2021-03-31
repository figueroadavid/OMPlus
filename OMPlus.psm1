#Requires -RunAsAdministrator

$Global:OMHOMEPath          = (Get-ItemProperty -Path 'HKLM:\Software\PlusTechnologies\OMPlusServer' -Name OMHOMEPath).OMHOMEPath
$Global:OMPrinterPath   = [System.IO.Path]::Combine($Global:OMHOMEPath, 'printers')
$Global:OMBinPath       = [System.IO.Path]::Combine($Global:OMHOMEPath, 'bin')
$Global:OMFormsPath     = [System.IO.Path]::Combine($Global:OMHOMEPath, 'forms')
$Global:OMSystemPath    = [System.IO.Path]::Combine($Global:OMHOMEPath, 'system')

Write-Verbose -Message 'Setting parameters for OMPrimaryMPS, OMSecondaryMPS'
$pingMaster = Get-Content -Path ([System.IO.Path]::Combine( $Global:OMSystemPath, 'pingMaster'))
if ($pingMaster -eq 'none') {
    $Global:OMPrimaryMPS   = [system.net.dns]::GetHostByName($env:computername).hostname
    $Global:IsOMPrimaryMPS = $true

    $pingParmPath = [system.io.path]::combine($Global:OMSystemPath, 'pingParms')
    $Global:OMSecondaryMPS = (Get-Content -Path $pingParmPath |
        Where-Object { $_ -match '^Backup'}).Split('=')[1]
}
else {
    $Global:IsOMPrimaryMPS = $false
    $Global:OMPrimaryMPS   = $pingMaster
    $Global:OMSecondaryMPS = [System.Net.Dns]::GetHostByName($env:computername).hostname
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
if ($Global:IsOMPrimaryMPS) {
    $Global:ValidTypes      = Get-OMDriverNames | Select-Object -ExpandProperty Driver | Sort-Object
}

$Global:CRLF                = [Environment]::NewLine
