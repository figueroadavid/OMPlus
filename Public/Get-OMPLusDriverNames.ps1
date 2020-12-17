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
    .PARAMETER Path
        This is the installation path for OMPlus.  It is pulled from the registry by default.
    .INPUTS
        [string]
    .OUTPUTS
        [string]
    .NOTES
        By default, it reads the registry to find the types.conf file.
        If this is not desired, the user can input a path.
    #>
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({
            if (Test-Path -path $_) {
                $true
            }
            else {
                throw ('OMPlus does not appear to be installed at the specified location {0}' -f $_ )
            }
             })]
        [string]$Path = ('{0}\system\types.conf' -f (Get-ItemProperty -Path 'HKLM:\Software\PlusTechnologies\OMPlusServer' -Name OMHOMEPath).OMHOMEPath)
    )
        $XML = New-Object -TypeName XML
        $XML.Load($Path)
        Select-XML -Xml $XML -XPath '//PTYPE' |
            Select-Object -ExpandProperty Node |
            Select-Object -ExpandProperty Name
}
