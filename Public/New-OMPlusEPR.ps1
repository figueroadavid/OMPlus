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

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Tray,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('None','Simplex','Horizontal','Vertical','ShortEdge','LongEdge')]
        [string]$DuplexOption = 'None',

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$PaperSize,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('n','y')]
        [switch]$IsRX = 'n',

        [parameter(ValueFromPipelineByPropertyName)]
        [AllowEmptyString()]
        [string]$MediaType = ''
    )

    if ($DriverType -in $Global:ValidTypes) {
        if ($VerbosePreference -eq 'Continue') {
            $Message = 'DriverType ({0}) is valid, retrieving Type.conf information for it' -f $DriverType
            Write-Verbose -Message $Message -Verbose
        }
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

    $MatchingTrays = $TrayNameTable.TrayRef | ForEach-Object {
        if ($_ -match $Tray) { $_ }
    }
    switch ($MatchingTrays.Count) {
        0 {
            $Message = 'The supplied Tray ({0}) is not valid for Driver ({1}); defaulting to !1; this is usually Tray 1' -f $Tray, $DriverName
            Write-Warning -Message $Message
            $Tray = '!1'
        }
        1 {
            $Message = 'The supplied Tray is ({0}) valid for DriverName ({1})' -f $Tray, $DriverName
            Write-Verbose -Message $Message
            $Tray = '!{0}' -f ($TrayNameTable | Where-Object TrayRef -eq $MatchingTrays).TrayID
        }
        default {
            $Message = New-Object -Type System.Collections.Generic.List[string]
            $Message.Add(('The supplied Tray ({0}) matches multiple tray types, using the ID for the first matching type.' -f $Tray))
            $Message.Add('Here is the list of valid tray types, please replace the digits with the correct digit(s).')
            $Message.Add('You must keep the exclamation point (!)')
            $Message.Add(('Valid Tray Types:{0}' -f $CRLF))
            $Message.Add(($TrayNameTable | Where-Object { $_.TrayRef -in $MatchingTrays }))
            Write-Warning -Message ($Message -join $CRLF)
            $Tray = '!{0}' -f ($TrayNameTable | Where-Object TrayRef -eq $MatchingTrays[0]).TrayID
        }
    }

    $MatchingPaperSizes = $PaperSizeTable | ForEach-Object {
        if ($_ -match $PaperSize) { $_ }
    }
    switch ($MatchingPaperSizes.Count) {
        0 {
            $Message = 'The supplied PaperSize ({0}) is not valid for Driver ({1}); defaulting to !1; this is usually Letter sized' -f $PaperSize, $DriverName
            Write-Warning -Message $Message
            $PaperSize = '!1'
        }
        1 {
            $Message = 'The supplied PaperSize is ({0}) valid for DriverName ({1})' -f $PaperSize, $DriverName
            Write-Verbose -Message $Message
            $Tray = '!{0}' -f ($PaperSizeTable | Where-Object PaperSizeRef -eq $MatchingPaperSizes).PaperSizeID
        }
        default {
            $Message = New-Object -Type System.Collections.Generic.List[string]
            $Message.Add(('The supplied PaperSize ({0}) matches multiple PaperSizes, using the ID for the first matching size.' -f $PaperSize))
            $Message.Add('Here is the list of valid PaperSizes, please replace the digits with the correct digit(s).')
            $Message.Add('You must keep the exclamation point (!)')
            $Message.Add(('Valid PaperSizes:{0}' -f $CRLF))
            $Message.Add(($PaperSizeTable | Where-Object { $_.TrayRef -in $MatchingPaperSizes }))
            Write-Warning -Message ($Message -join $CRLF)
            $PaperSize = '!{0}' -f ($PaperSizeTable | Where-Object PaperSizeRef -eq $MatchingPaperSizes[0]).PaperSizeID
        }
    }

    $MatchingMediaTypes = $MediaTypeTable.MediaTypeRef | ForEach-Object {
        if ($_ -match $MediaType) { $_ }
    }
    switch ($MatchingMediaTypes.Count) {
        0 {
            $Message = 'No Media Type supplied; and it is not required' -f $MediaType, $DriverName
            Write-Verbose -Message $Message
            $MediaType = ''
        }
        1 {
            $Message = 'The supplied MediaType is ({0}) valid for DriverName ({1})' -f $MediaType, $DriverName
            Write-Verbose -Message $Message
            $MediaType = '!{0}' -f ($MediaTypeTable | Where-Object MediaTypeRef -eq $MatchingMediaTypes).MediaTypeID
        }
        default {
            $Message = New-Object -Type System.Collections.Generic.List[string]
            $Message.Add(('The supplied MediaType ({0}) matches multiple MediaTypes, using the ID for the first matching size.' -f $MediaType))
            $Message.Add('This is rarely the right type of media desired')
            $Message.Add('Here is the list of valid MediaTypes, please replace the digits with the correct digit(s).')
            $Message.Add('You must keep the exclamation point (!)')
            $Message.Add(('Valid MediaTypes:{0}' -f $CRLF))
            $Message.Add(($MediaTypeTable | Where-Object { $_.TrayRef -in $MatchingMediaTypes }))
            Write-Warning -Message ($Message -join $CRLF)
            $MediaType = '!{0}' -f ($MediaTypeTable | Where-Object MediaTypeRef -eq $MatchingMediaTypes[0]).MediaTypeID
        }
    }

    ([PSCustomObject]@{
        ServerName      = $ServerName
        EPRRecord       = $EPRName
        Queue           = $QueueName
        EPSBase         = $DriverType
        Tray            = $Tray
        Duplex          = $DuplexOption
        PaperSize       = $PaperSize
        RX              = $IsRX
        MediaType       = $MediaType
    }).PSObject.Properties.Value -join '|'

}
