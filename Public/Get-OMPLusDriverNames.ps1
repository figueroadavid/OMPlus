$OMHOMEPath = (Get-ItemProperty -Path 'HKLM:\Software\PlusTechnologies\OMPlusServer' -Name OMHOMEPath).OMHOMEPath

function Get-OMPLusDriverNames {
    <#
    .SYNOPSIS
        Retrieves the list of valid driver types for OMPlus
    .DESCRIPTION
        It locates the default installation path for OMPlus, and retrieves the type.conf.
        It then searches for all of the various types and returns the list of those types.
    .EXAMPLE
        PS C:\> Get-OMPlustDriverNames
        DellOPDPCL5
        XeroxUPDPS
        LexUPDv2
        LexUPDv2XL
        LexUPDv2PS3
        XeroxUPDPCL6
        HPUPD6
        HPUPD5
        RICOHPCL6
    .INPUTS
        none
    .OUTPUTS
        [string]
    .NOTES
        The installation path of OMPlus is pulled from the registry
    #>
    [CmdletBinding()]
    param()
    $XMLPath = [system.io.path]::combine($OMHOMEPath, 'system','types.conf')
    if (Test-Path -Path $XMLPath) {
    $XML = New-Object -TypeName XML
    $XML.Load($XMLPath)
    Select-XML -Xml $XML -XPath '//PTYPE' |
        Select-Object -ExpandProperty Node |
        Select-Object -ExpandProperty Name
    }
    else {
        throw 'Could not retrieve printer driver names'
    }
}
