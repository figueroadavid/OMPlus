function Enable-OMPlusPrinter {
    <#
    .SYNOPSIS
        Enables a previously disabled printer in OMPlus
    .DESCRIPTION
        Uses dccenable.exe to enable a previously disable printer in OMPlus
    .EXAMPLE
        PS C:\> Enable-OMPlusPrinter -PrinterName PRINTER01

        Enables PRINTER01
    .PARAMETER PrinterName
        The list of printers to enable
    .PARAMETER ShowProgress
        A switch to show the progress of the command
    .INPUTS
        [string]
    .OUTPUTS
        [none]
    .NOTES

    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$PrinterName,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$ShowProgress
    )

    begin {
        $PrinterList = Get-OMPlusPrinterList
        if ($ShowProgress) {
            $PrinterNameCount = $PrinterName.Count
            $CurrentCount = 0
        }
        $DCCEnable = [system.io.path]::combine( $global:omhomepath, 'bin','dccenable.exe' )
    }

    process {
        foreach ($printer in $PrinterName) {
            if ($ShowProgress) {
                $CurrentCount ++
                $ProgSplat = @{
                    Activity        = 'Enabling {0}' -f $Printer
                    status          = '{0} of {1}' -f $CurrentCounter, $PrinterNameCount
                    PercentComplete = [math]::Round( $CurrentCount/$PrinterNameCount * 100, [System.MidpointRounding]::AwayFromZero)
                }
                Write-Progress @ProgSplat
            }
            if ($Printer -in $PrinterList) {
                $ProcSplat = @{
                    FilePath        = $DCCEnable
                    ArgumentList    = '-d {0}' -f $Printer
                    Wait            = $true
                    WindowStyle     = 'Hidden'
                }
                Start-Process @ProcSplat -Verb RunAs
            }
            else {
                $Message = 'Printer: {0} is not a valid printer for this system; skipping' -f $Printer
                Write-Warning -Message $Message
                continue
            }
        }
    }
}
