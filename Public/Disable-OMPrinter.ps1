Function Disable-OMPPrinter {
    <#
    .SYNOPSIS
        Disables a printer in OMPlus
    .DESCRIPTION
        Uses dccdisable.exe to disable printers in OMPlus
    .EXAMPLE
        PS C:\> Enable-OMPrinter -PrinterName PRINTER01,PRINTER02

        Disables PRINTER01, and PRINTER02
    .PARAMETER PrinterName
        The list of printers to disable
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
        $PrinterList = Get-OMPrinterList
        if ($ShowProgress) {
            $PrinterNameCount = $PrinterName.Count
            $CurrentCount = 0
        }
        $DCCdisable = [system.io.path]::combine( $global:omhomepath, 'bin','dccenable.exe' )
    }

    process {
        foreach ($printer in $PrinterName) {
            if ($ShowProgress) {
                $CurrentCount ++
                $ProgSplat = @{
                    Activity        = 'Disabling {0}' -f $Printer
                    status          = '{0} of {1}' -f $CurrentCounter, $PrinterNameCount
                    PercentComplete = [math]::Round( $CurrentCount/$PrinterNameCount * 100, [System.MidpointRounding]::AwayFromZero)
                }
                Write-Progress @ProgSplat
            }
            if ($Printer -in $PrinterList) {
                $ProcSplat = @{
                    FilePath        = $DCCDisable
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
