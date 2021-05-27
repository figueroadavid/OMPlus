#Requires -RunAsAdministrator

$Script:OMVariables = @{
    HOME            = $env:OMHOME
    Printer         = [System.IO.Path]::Combine($env:OMHOME, 'printers')
    Bin             = [System.IO.Path]::Combine($env:OMHOME, 'bin')
    Forms           = [System.IO.Path]::Combine($env:OMHOME, 'forms')
    System          = [System.IO.Path]::Combine($env:OMHOME, 'system')
    Model           = [System.IO.Path]::Combine($env:OMHOME, 'model')
}


Write-Verbose -Message 'Setting parameters for OMPrimaryMPS, OMSecondaryMPS'
$pingMaster = Get-Content -Path ([System.IO.Path]::Combine( $OMVariables.System, 'pingMaster'))
if ($pingMaster -eq 'none') {
    $OMVariables.PrimaryMPS   = [system.net.dns]::GetHostByName($env:computername).hostname
    $Script:IsOMPrimaryMPS = $true

    $pingParmPath   = [system.io.path]::combine($OMVariables.System, 'pingParms')
    $OMVariables.SecondaryMPS = (Get-Content -Path $pingParmPath |
        Where-Object { $_ -match '^Backup'}).Split('=')[1]
}
else {
    $Script:IsOMPrimaryMPS      = $false
    $OMVariables.PrimaryMPS     = $pingMaster
    $OMVariables.SecondaryMPS   = [System.Net.Dns]::GetHostByName($env:computername).hostname
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

$script:ValidModels = Get-ChildItem -Path $OMVariables.Model | Select-Object -ExpandProperty Name

$CRLF                = [Environment]::NewLine
