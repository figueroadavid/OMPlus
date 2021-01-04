function New-OMPlusEPRRecordLite {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({
            if ($_ -match '^\w+\.\w+\.\w+^') {
                Write-Verbose -Message ('{0} appears to be a valid FQDN' -f $_)
            }
            else {
                Write-Warning -Message ('{0} appears to be an invalid FQDN; please verify your records when complete' -f $_)
            }
            $true
        })]
        [string]$ServerName = ([system.net.dns]::GetHostByName($env:computername).hostname),

        [parameter(Mandatory)]
        [string[]]$EPRQueueName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$OMPLusQueueName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$DriverName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$TrayName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('None', 'Simplex', 'Horizontal', 'Vertical')]
        [string[]]$DuplexOption,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$PaperSize,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('n','y')]
        [string[]]$IsRX = 'n',

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$MediaType = 'None'
    )

    foreach ($Item in $EPRQueueName) {
        $TrayDictionary         = Get-OMPlusTypeTable -DriverType $DriverName -DisplayType Trays
        $PaperSizeDictionary    = Get-OMPlusTypeTable -DriverType $DriverName -DisplayType PaperSizes
        $MediaTypeDictionary    = Get-OMPlusTypeTable -DriverType $DriverName -DisplayType MediaTypes

        $RecordList = New-Object -TypeName System.Collections.Generic.List[string]
        $RecordList.Add($ServerName)
        $RecordList.Add($EPRQueueName)
        $RecordList.Add($OMPLusQueueName)
        $RecordList.Add($DriverName)
        $RecordList.Add( ($TrayDictionary | Where-Object TrayRef -match $Tray |
                            Select-Object -ExpandProperty TrayID).ToString() )
        if ($DuplexOption -eq 'None') {
            $RecordList.Add('')
        }
        else {
            $RecordList.Add($DuplexOption)
        }
        $RecordList.Add( ($PaperSizeDictionary | Where-Object PaperSizeRef -match $PaperSize |
                            Select-Object -ExpandProperty PaperSizeID).ToString() )
        $RecordList.Add($IsRX)
        if ($MediaType -eq 'None') {
            $RecordList.Add('')
        }
        else {
            $RecordList.Add( ($MediaTypeDictionary | Where-Object MediaTypeRef -match $MediaType |
            Select-Object -ExpandProperty MediaTypeID).ToString() )
        }
        $RecordList -join '|'
    }



}
