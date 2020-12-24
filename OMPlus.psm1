Get-ChildItem -Path $PSScriptRoot\Private -File -Filter *.ps1 | Where-Object fullname -notmatch '`.tests`.ps1' |
    ForEach-Object {
        Write-Verbose -Message ('Importing script: {0}' -f $_.FullName ) -Verbose
        . $_.FullName }

Get-ChildItem -Path $PSScriptRoot\Public -File -Filter *.ps1 | Where-Object fullname -notmatch '`.tests`.ps1' |
    ForEach-Object {
        Write-Verbose -Message ('Importing script: {0}' -f $_.FullName ) -Verbose
        . $_.FullName
    }

$Global:OMHOMEPath          = (Get-ItemProperty -Path 'HKLM:\Software\PlusTechnologies\OMPlusServer' -Name OMHOMEPath).OMHOMEPath
$GLobal:OMPlusPrinterPath   = [System.IO.Path]::Combine($Global:OMHOMEPath, 'printers')
$Global:BinPath             = [System.IO.Path]::Combine($Global:OMHOMEPATH, 'bin')
$Global:OMPLusSystemPath    = [System.IO.Path]::Combine($Global:OMHOMEPath, 'system')
$Global:ValidTypes          = Get-OMPLusDriverNames
$Global:CRLF                = [Environment]::NewLine
$Global:OMPlusServerFQDN    = [system.net.dns]::GetHostByName($env:COMPUTERNAME).hostname
