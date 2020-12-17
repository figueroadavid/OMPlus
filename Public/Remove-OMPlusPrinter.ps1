function  Remove-OMPlusPrinter {
    <#
    .SYNOPSIS
        Remove a printer from OMPlus
    .DESCRIPTION
        Uses lpadmin to remove a print destination
    .EXAMPLE
        PS C:\> Remove-OMPlusPrinter -PrinterName Printer1

        Deletes the printer destination from OMPlus
    .INPUTS
        [system.string]
    .OUTPUTS
        none
    .NOTES
        Uses the -x option of LPAdmin to remove the print destination.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [string[]]$PrinterName
    )

    Begin {
        $RootPath = (Get-ItemProperty -Path 'HKLM:\Software\PlusTechnologies\OMPlusServer' -Name OMHOMEPath).OMHOMEPath
        $BinPath = [System.IO.Path]::Combine($RootPath, 'bin')
        $ExePath = [system.io.path]::Combine($BinPath, 'lpadmin.exe')
    }

    Process {
        $Arguments = '-x {0}' -f $PrinterName.ToUpper()
        if ($PSCmdlet.ShouldProcess(('Remove printer {0}' -f $PrinterName), '', '')) {
            Start-Process -FilePath $ExePath -ArgumentList $Arguments -Wait -WindowStyle Hidden
            Write-Warning -Message ('Do not forget to Remove the EPR Record for {0}' -f $PrinterName)
        }
    }

    end {
    }
}
