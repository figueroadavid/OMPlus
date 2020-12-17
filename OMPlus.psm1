Get-ChildItem -Path .\Private -File -Filter *.ps1 | Where-Object fullname -notmatch '`.tests`.ps1' |
    ForEach-Object {
        Write-Verbose -Message ('Importing script: {0}' -f $_.FullName ) -Verbose
        . $_.FullName }

Get-ChildItem -Path .\Public -File -Filter *.ps1 | Where-Object fullname -notmatch '`.tests`.ps1' |
    ForEach-Object {
        Write-Verbose -Message ('Importing script: {0}' -f $_.FullName ) -Verbose
        . $_.FullName
    }

$Global:OMHOMEPath = (Get-ItemProperty -Path 'HKLM:\Software\PlusTechnologies\OMPlusServer' -Name OMHOMEPath).OMHOMEPath
$Global:ValidTypes = Get-OMPLusDriverNames
