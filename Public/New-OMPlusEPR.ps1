function New-OMPlusEPR {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$DestinationName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$QueueName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$DriverName,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Tray,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$DuplexOption,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$PaperSize,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$IsRX,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$MediaType
    )

    Begin {
        $DriverNames =
    }

    Begin {
        $HostName = [system.net.dns]::GetHostByName($env:COMPUTERNAME).hostname
    }
}
