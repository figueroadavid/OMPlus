if ($Global:IsOMPrimaryMPS) {
    Function Get-OMDriverNames {
        <#
        .SYNOPSIS
            Retrieves the list of valid driver types for OMPlus
        .DESCRIPTION
            It locates the default installation path for OMPlus, and retrieves the OM_EPS_WIN_Queues.csv file.
            It then searches for all of the various types and returns the list of those types.
        .EXAMPLE
            PS C:\> Get-OMDriverNames
            Driver                                                                   Display
            ------                                                                   -------
            ZDesignerAM400                                                           ZDesigner ZM400 200 dpi (ZPL)
            HPUPD6                                                                   HP Universal Printing PCL 6
            LexUPDv2                                                                 Lexmark Universal v2
            DellOPDPCL5                                                              Dell Open Print Driver (PCL 5)
            RICOHPCL6                                                                RICOH PCL6 UniversalDriver V4.14
            HPUPD5                                                                   HP Universal Printing PCL 5
            Zebra2.5x4                                                               ZDesigner ZM400 200 dpi (ZPL)
            LexUPDv2PS3                                                              Lexmark Universal v2 PS3
            LexUPDv2XL                                                               Lexmark Universal v2 XL
            XeroxUPDPS                                                               Xerox Global Print Driver PS
            XeroxUPDPCL6                                                             Xerox Global Print Driver PCL6

        .INPUTS
            none
        .OUTPUTS
            [string]
        .NOTES
            This function is not available on the secondary/backup Master Print Server
        #>
        [CmdletBinding()]
        param()

        $CSVPath = [system.io.path]::combine($Global:OMHOMEPath, 'system','OM_EPS_WIN_Queues.csv')

        if (Test-Path -Path $CSVPath) {
            $QueueTypes = Import-Csv -Path $CSVPath -Header DriverName,DisplayName
            for ($i = 1; $i -le $QueueTypes.Count; $i++) {
                [pscustomobject]@{
                    Driver  = $QueueTypes[$i].DriverName
                    Display = $QueueTypes[$i].DisplayName
                }
            }
        }
        else {
            throw 'Could not retrieve printer driver names'
        }
    }
}
else {
    Write-Verbose -Message 'Not running on Primary OMPlus Server, unable to retrieve driver names'
}
