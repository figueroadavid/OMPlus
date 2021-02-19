#Requires -RunAsAdministrator

$Global:OMHOMEPath          = (Get-ItemProperty -Path 'HKLM:\Software\PlusTechnologies\OMPlusServer' -Name OMHOMEPath).OMHOMEPath
$GLobal:OMPlusPrinterPath   = [System.IO.Path]::Combine($Global:OMHOMEPath, 'printers')
$Global:OMPlusBinPath       = [System.IO.Path]::Combine($Global:OMHOMEPATH, 'bin')
$Global:OMPlusFormsPath     = [System.IO.Path]::Combine($Global:OMHOMEPATH, 'forms')
$Global:OMPLusSystemPath    = [System.IO.Path]::Combine($Global:OMHOMEPath, 'system')

Write-Verbose -Message 'Setting parameters for OMPlusPrimaryMPS, OMPlusSecondaryMPS'
$pingMaster = Get-Content -Path ([System.IO.Path]::Combine( $Global:OMPLusSystemPath, 'pingMaster'))
if ($pingMaster -eq 'none') {
    $Global:OMPlusPrimaryMPS   = [system.net.dns]::GetHostByName($env:computername).hostname
    $Global:IsOMPLusPrimaryMPS = $true

    $pingParmPath = [system.io.path]::combine($Global:OMPLusSystemPath, 'pingParms')
    $Global:OMPlusSecondaryMPS = (Get-Content -Path $pingParmPath |
        Where-Object { $_ -match '^Backup'}).Split('=')[1]
}
else {
    $Global:IsOMPLusPrimaryMPS = $false
    $Global:OMPlusPrimaryMPS   = $pingMaster
    $Global:OMPlusSecondaryMPS = [System.Net.Dns]::GetHostByName($env:computername).hostname
}

Remove-Variable -Name pingMaster,pingParmPath

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
if ($Global:IsOMPLusPrimaryMPS) {
    $Global:ValidTypes      = Get-OMPLusDriverNames | Select-Object -ExpandProperty Driver | Sort-Object
}

$Global:CRLF                = [Environment]::NewLine
