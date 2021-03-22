#Requires -RunAsAdministrator

$Global:OMHOMEPath          = (Get-ItemProperty -Path 'HKLM:\Software\PlusTechnologies\OMPlusServer' -Name OMHOMEPath).OMHOMEPath
$OMPlusPrinterPath   = [System.IO.Path]::Combine($Global:OMHOMEPath, 'printers')
$OMPlusBinPath       = [System.IO.Path]::Combine($Global:OMHOMEPATH, 'bin')
$OMPlusFormsPath     = [System.IO.Path]::Combine($Global:OMHOMEPATH, 'forms')
$OMPlusSystemPath    = [System.IO.Path]::Combine($Global:OMHOMEPath, 'system')

Write-Verbose -Message 'Setting parameters for OMPlusPrimaryMPS, OMPlusSecondaryMPS'
$pingMaster = Get-Content -Path ([System.IO.Path]::Combine( $OMPlusSystemPath, 'pingMaster'))
if ($pingMaster -eq 'none') {
    $OMPlusPrimaryMPS   = [system.net.dns]::GetHostByName($env:computername).hostname
    $IsOMPLusPrimaryMPS = $true

    $pingParmPath = [system.io.path]::combine($OMPlusSystemPath, 'pingParms')
    $OMPlusSecondaryMPS = (Get-Content -Path $pingParmPath |
        Where-Object { $_ -match '^Backup'}).Split('=')[1]
}
else {
    $IsOMPLusPrimaryMPS = $false
    $OMPlusPrimaryMPS   = $pingMaster
    $OMPlusSecondaryMPS = [System.Net.Dns]::GetHostByName($env:computername).hostname
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
if ($IsOMPLusPrimaryMPS) {
    $Global:ValidTypes      = Get-OMDriverNames | Select-Object -ExpandProperty Driver | Sort-Object
}

$Global:CRLF                = [Environment]::NewLine
