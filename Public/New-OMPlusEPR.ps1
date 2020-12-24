function New-OMPlusEPR {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [string]$ServerName = $Global:OMPlusServerFQDN,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$EPRName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$QueueName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$DriverName,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Tray,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('None','Simplex','Horizontal','Vertical','ShortEdge','LongEdge')]
        [string]$DuplexOption,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$PaperSize,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$IsRX,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$MediaType
    )

    if ($DriverType -in $Global:ValidTypes) {
        $TrayNameTable = Get-OMPlusTypeTable -DriverType $DriverType -DisplayType Trays
        $PaperSizeTable = Get-OMPlusTypeTable -DriverType $DriverType -DisplayType PaperSizes
        $MediaTypeTable = Get-OMPlusTypeTable -DriverType $DriverType -DisplayType MediaType
    }
    else {
        Write-Warning -Message ('{0} is not a supported driver on this system' -f $DriverType)
        return
    }

    if ($DuplexOption -eq 'None') {
        $DuplexOption = ''
    }
    elseif ($DuplexOption -eq 'ShortEdge') {
        $DuplexOption = 'Horizontal'
    }
    elseif ($DuplexOption -eq 'LongEdge') {
        $DuplexOption = 'Vertical'
    }

    if ($TrayType)

}
