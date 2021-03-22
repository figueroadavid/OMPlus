function  Remove-OMPrinter {
    <#
    .SYNOPSIS
        Remove a printer from OMPlus
    .DESCRIPTION
        Uses lpadmin to remove a print destination
    .EXAMPLE
        PS C:\> Remove-OMPrinter -PrinterName Printer1

        Deletes the printer destination from OMPlus
    .INPUTS
        [system.string]
    .OUTPUTS
        [system.string]
    .NOTES
        Uses the -x option of LPAdmin to remove the print destination.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [string[]]$PrinterName
    )

    Begin {
        $BinPath = [System.IO.Path]::Combine($Global:OMHOMEPATH, 'bin')
        $ExePath = [system.io.path]::Combine($BinPath, 'lpadmin.exe')
    }

    Process {
        foreach ($Printer in $PrinterName) {
            $Arguments = '-x {0}' -f $Printer.ToUpper()
            if ($PSCmdlet.ShouldProcess(('Remove printer {0}' -f $Printer), '', '')) {
                Start-Process -FilePath $ExePath -ArgumentList $Arguments -Wait -WindowStyle Hidden
                Write-Warning -Message ('Do not forget to Remove the EPR Record for {0}' -f $Printer)
            }
        }
    }

    end {
    }
}
