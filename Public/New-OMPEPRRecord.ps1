if ($IsOMPLusPrimaryMPS) {
    if ($PSVersionTable.PSVersion.Major -ge 5) {
        Function New-OMPEPRRecord {
            <#
            .SYNOPSIS
                This will generate an OMPlus EPR record for the eps_map file
            .DESCRIPTION
                <work in progress>
            .EXAMPLE
                PS C:\> $EPRSplat = @{
                    ServerName = 'server01.domain.local'
                    EPRQueueName    = 'PRINTER01'
                    OMPlusQueueName = 'PRINTER01'
                    DriverName      = 'DellOPDPCL5'
                    TrayName        = 'Tray 1'
                    DuplexOption    = 'Horizontal'
                    PaperSize       = 'Letter'
                    IsRX            = 'n'
                    MediaType       = 'Bond'
                }
                PS C:\> New-OMPlusEPRRecordLite @EPRSplat
                server01.domain.local|PRINTER01|PRINTER01|DellOPDPCL5|!259|Horizontal|!1|n|!259

            .PARAMETER ServerName
                This is the fully qualified domain name of the server which will have the
                generated EPR record.

            .PARAMETER EPRQueueName
                The name of the EPR Queue in OMPlus

            .PARAMETER OMPLusQueueName
                The name of the OMPlus Queue name (this is the destination queue name).

            .PARAMETER DriverName
                This is the name of the print driver in OMPlus to use for the EPR Record.
                The name must match one of the types listed in the Types menu in OMPlus Control Panel.

            .PARAMETER TrayName
                This is the display name of the Tray.  It must match exactly one entry for the Driver
                in the types.conf file.  When the EPR record is generated, the name here is replaced with
                the correct ID number from trays.conf.
                If no TrayName is provided, the generated EPR record will contain an empty field.

            .PARAMETER DuplexOption
                This is the option Duplexing parameter for the EPR Record.
                It can be set to None, Simplex, Horizontal, or Vertical.
                None implies that the field in the generated EPR record will be empty.
                In the GUI, Horizontal appears as 'Short Edge', and
                Vertical appears as 'Long Edge'.  However, 'Horizontal' and 'Vertical' are
                the terms actually used in the eps_map file.

            .PARAMETER PaperSize
                This is the displayname of the paper size to be chosen.
                If no PaperSize is provided, the generated EPR record will contain an empty field.

            .PARAMETER IsRX
                Determines if the RX field is present in the generated EPR record.  It defaults to 'n'
                which is unchecked in the GUI.  The other option is to put in 'y' which marks the checkbox
                in the GUI.
            .PARAMETER MediaType
                This is the displayname of the media type used in the EPR Record.
                If no MediaType is provided, the generated EPR record will contain an empty field.

            .PARAMETER Append
                This switch tells the script to automatically append the record to the eps_map.

            .INPUTS
                [string]
            .OUTPUTS
                [string]
            .NOTES
                For the TrayName, PaperSize, and MediaType fields, the supplied names are matched against the
                available names in the types.conf file, and if more than one match is found, or if no matches
                are found, the record is not generated, and a warning is thrown. The text supplied is escaped
                to make sure the RegEx pattern is valid for the RegEx engine.


            #>
            [cmdletbinding(SupportsShouldProcess)]
            param(
                [parameter(ValueFromPipelineByPropertyName)]
                [ValidateScript({
                    if ($_ -match '^(\w+\.){1,}\w+\.\w+$') {
                        Write-Verbose -Message ('{0} appears to be a valid FQDN' -f $_)
                    }
                    else {
                        throw ('{0} appears to be an invalid FQDN; please verify your records when complete' -f $_)
                    }
                    $true
                })]
                [string]$ServerName = ([system.net.dns]::GetHostByName($env:computername).hostname),

                [parameter(Mandatory)]
                [string]$EPRQueueName,

                [parameter(Mandatory, ValueFromPipelineByPropertyName)]
                [string]$OMPLusQueueName,

                [parameter(Mandatory, ValueFromPipelineByPropertyName)]
                [ArgumentCompleter({
                    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                        Get-OMPlusDriverNames | Select-object -ExpandProperty 'Driver' |
                        Where-Object { $_ -like "$WordToComplete*"} |
                        Sort-Object |
                        Foreach-Object {
                            [System.Management.Automation.CompletionResult]::new(
                                $_,
                                $_,
                                [System.Management.Automation.CompletionResultType]::ParameterValue,
                                ('Driver Type: {0}' -f $_ )
                            )
                        }
                })]
                [string]$DriverName,

                [parameter(ValueFromPipelineByPropertyName)]
                [ArgumentCompleter({
                    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                        Get-OMPlusTypeTable -DriverType $DriverName -DisplayType Trays   | Select-object -ExpandProperty 'TrayRef' |
                        Where-Object { $_ -like "$WordToComplete*"} |
                        Sort-Object |
                        Foreach-Object {
                            [System.Management.Automation.CompletionResult]::new(
                                $_,
                                $_,
                                [System.Management.Automation.CompletionResultType]::ParameterValue,
                                ('Tray Type: {0}' -f $_ )
                            )
                        }
                })]
                [string]$TrayName = 'None',

                [parameter(ValueFromPipelineByPropertyName)]
                [ValidateSet('None', 'Simplex', 'Horizontal', 'Vertical')]
                [string]$DuplexOption = 'None',

                [parameter(ValueFromPipelineByPropertyName)]
                [ArgumentCompleter({
                    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                        Get-OMPlusTypeTable -DriverType $DriverName -DisplayType PaperSizes   | Select-object -ExpandProperty 'PaperSizeRef' |
                        Where-Object { $_ -like "$WordToComplete*"} |
                        Sort-Object |
                        Foreach-Object {
                            [System.Management.Automation.CompletionResult]::new(
                                $_,
                                $_,
                                [System.Management.Automation.CompletionResultType]::ParameterValue,
                                ('Tray Type: {0}' -f $_ )
                            )
                        }
                })]
                [string]$PaperSize = 'None',

                [parameter(ValueFromPipelineByPropertyName)]
                [ValidateSet('n','y')]
                [string]$IsRX = 'n',

                [parameter(ValueFromPipelineByPropertyName)]
                [ArgumentCompleter({
                    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                        Get-OMPlusTypeTable -DriverType $DriverName -DisplayType MediaType   | Select-object -ExpandProperty 'MediaTypeRef' |
                        Where-Object { $_ -like "$WordToComplete*"} |
                        Sort-Object |
                        Foreach-Object {
                            [System.Management.Automation.CompletionResult]::new(
                                $_,
                                $_,
                                [System.Management.Automation.CompletionResultType]::ParameterValue,
                                ('Tray Type: {0}' -f $_ )
                            )
                        }
                })]
                [string]$MediaType = 'None',

                [parameter(ValueFromPipelineByPropertyName)]
                [switch]$Append
            )

            begin {
                if ($Append) {
                    $pingMsgPath = [system.io.path]::Combine($OMPlusBinPath, 'pingmsg.exe')
                    $EPSMapPath = [system.io.path]::Combine($OMPlusSystemPath, 'eps_map')
                }
                $TrayDictionary         = Get-OMPlusTypeTable -DriverType $DriverName -DisplayType Trays
                $PaperSizeDictionary    = Get-OMPlusTypeTable -DriverType $DriverName -DisplayType PaperSizes
                $MediaTypeDictionary    = Get-OMPlusTypeTable -DriverType $DriverName -DisplayType MediaTypes
            }

            process {
                $thisRecord = New-Object -TypeName System.Collections.Generic.List[string]
                $thisRecord.Add($ServerName)
                $thisRecord.Add($EPRQueueName)
                $thisRecord.Add($OMPLusQueueName)
                $thisRecord.Add($DriverName)


                if ($TrayName -eq 'None') {
                    $thisRecord.Add('DELETEME')
                }
                else {
                    $thisMatch = $TrayDictionary | Where-Object { $_.TrayRef -match ('^{0}$' -f [RegEx]::Escape($TrayName) ) } |
                        Measure-Object | Select-Object -Property Count
                    switch ($thisMatch.Count) {
                        0 {
                            $thisRecord.Add('DELETEME')
                            $Message = 'No tray names match {0}, putting in an empty field' -f $TrayName
                            Write-Verbose -Message $Message
                        }
                        1 {
                            $thisRecord.Add( ('!{0}' -f ($TrayDictionary |
                                Where-Object { $_.TrayRef -Match [regex]::escape($TrayName) } |
                                Select-Object -ExpandProperty TrayID))
                            )
                        }
                        default {
                            $Message = 'TrayName ({0}) matches too many items, please narrow the list and try again' -f $TrayName
                            Write-Warning -Message $Message
                            return
                        }
                    }
                    Remove-Variable -Name thisMatch
                }

                if ($DuplexOption -eq 'None') {
                    $thisRecord.Add('DELETEME')
                }
                else {
                    $thisRecord.Add($DuplexOption)
                }

                if ($PaperSize -eq 'None') {
                    $thisRecord.Add('DELETEME')
                }
                else {
                    $thisMatch = $PaperSizeDictionary | Where-Object { $_.PaperSizeRef -match ('^{0}$' -f [RegEx]::Escape( $PaperSize)) } |
                        Measure-Object | Select-Object -Property Count


                    switch ($thisMatch.Count) {
                        0 {
                            $thisRecord.Add('DELETEME')
                            $Message = 'No PaperSize names match {0}, putting in an empty field' -f $PaperSize
                            Write-Verbose -Message $Message
                        }
                        1 {
                            $thisRecord.Add( ('!{0}' -f ($PaperSizeDictionary |
                                Where-Object { $_.PaperSizeRef -Match [regex]::escape($PaperSize) } |
                                Select-Object -ExpandProperty PaperSizeID))
                            )
                        }
                        default {
                            $Message = 'PaperSize ({0}) matches too many items, please narrow the list and try again' -f $PaperSize
                            Write-Warning -Message $Message
                            return
                        }
                    }
                    Remove-Variable -Name thisMatch
                }

                $thisRecord.Add($IsRX)

                if ($MediaType -eq 'None') {
                    $thisRecord.Add('DELETEME')
                }
                else {
                    $thisMatch = $MediaTypeDictionary | Where-Object { $_.MediaTypeRef -match ('^{0}$' -f [RegEx]::Escape( $MediaType) ) } |
                        Measure-Object | Select-Object -Property Count

                    switch ($thisMatch.Count) {
                        0 {
                            $thisRecord.Add('DELETEME')
                            $Message = 'No MediaType names match {0}, putting in an empty field' -f $MediaType
                            Write-Verbose -Message $Message
                        }
                        1 {
                            $thisRecord.Add( ('!{0}' -f ($MediaTypeDictionary |
                                Where-Object { $_.MediaTypeRef -Match [regex]::escape($MediaType) } |
                                Select-Object -ExpandProperty MediaTypeID))
                            )
                        }
                        default {
                            $Message = 'MediaType ({0}) matches too many items, please narrow the list and try again' -f $MediaType
                            Write-Warning -Message $Message
                            return
                        }
                    }
                    Remove-Variable -Name thisMatch
                }
                $thisRecord = $thisRecord -join '|' -replace 'DELETEME'
            }

            end {
                if ($Append -and $PSCmdlet.ShouldProcess('Updating eps_map file', '', '')) {
                    $AddSplat = @{
                        Path  = $EPSMapPath
                        Value = $thisRecord
                    }
                    Add-Content @AddSplat
                    Update-OMPlusTransformServer
                }
                else {
                    $thisRecord
                }
            }
        }
    }
    else {
        Function New-OMPEPRRecord {
            <#
            .SYNOPSIS
                This will generate an OMPlus EPR record for the eps_map file
            .DESCRIPTION
                <work in progress>
            .EXAMPLE
                PS C:\> New-OMPlusEPRRecordLite
            .PARAMETER ServerName
                This is the fully qualified domain name of the server which will have the
                generated EPR record.

            .PARAMETER EPRQueueName
                The name of the EPR Queue in OMPlus

            .PARAMETER OMPLusQueueName
                The name of the OMPlus Queue name (this is the destination queue name).

            .PARAMETER DriverName
                This is the name of the print driver in OMPlus to use for the EPR Record.
                The name must match one of the types listed in the Types menu in OMPlus Control Panel.

            .PARAMETER TrayName
                This is the display name of the Tray.  It must match exactly one entry for the Driver
                in the types.conf file.  When the EPR record is generated, the name here is replaced with
                the correct ID number from trays.conf.
                If no TrayName is provided, the generated EPR record will contain an empty field.

            .PARAMETER DuplexOption
                This is the option Duplexing parameter for the EPR Record.
                It can be set to None, Simplex, Horizontal, or Vertical.
                None implies that the field in the generated EPR record will be empty.
                In the GUI, Horizontal appears as 'Short Edge', and
                Vertical appears as 'Long Edge'.  However, 'Horizontal' and 'Vertical' are
                the terms actually used in the eps_map file.

            .PARAMETER PaperSize
                This is the displayname of the paper size to be chosen.
                If no PaperSize is provided, the generated EPR record will contain an empty field.

            .PARAMETER IsRX
                Determines if the RX field is present in the generated EPR record.  It defaults to 'n'
                which is unchecked in the GUI.  The other option is to put in 'y' which marks the checkbox
                in the GUI.
            .PARAMETER MediaType
                This is the displayname of the media type used in the EPR Record.
                If no MediaType is provided, the generated EPR record will contain an empty field.

            .PARAMETER Append
                This switch tells the script to automatically append the record to the eps_map.

            .INPUTS
                [string]
            .OUTPUTS
                [string]
            .NOTES
                For the TrayName, PaperSize, and MediaType fields, the supplied names are matched against the
                available names in the types.conf file, and if more than one match is found, or if no matches
                are found, the record is not generated, and a warning is thrown. The text supplied is escaped
                to make sure the RegEx pattern is valid for the RegEx engine.

                This function is not available on the secondary Master Print Server.
            #>
            [cmdletbinding(SupportsShouldProcess)]
            param(
                [parameter(ValueFromPipelineByPropertyName)]
                [ValidateScript({
                    if ($_ -match '^(\w+\.){1,}\w+\.\w+$') {
                        Write-Verbose -Message ('{0} appears to be a valid FQDN' -f $_)
                    }
                    else {
                        throw ('{0} appears to be an invalid FQDN; please verify your records when complete' -f $_)
                    }
                    $true
                })]
                [string]$ServerName = ([system.net.dns]::GetHostByName($env:computername).hostname),

                [parameter(Mandatory)]
                [string]$EPRQueueName,

                [parameter(Mandatory, ValueFromPipelineByPropertyName)]
                [string]$OMPLusQueueName,

                [parameter(Mandatory, ValueFromPipelineByPropertyName)]
                [string]$DriverName,

                [parameter(ValueFromPipelineByPropertyName)]
                [string]$TrayName = 'None',

                [parameter(ValueFromPipelineByPropertyName)]
                [ValidateSet('None', 'Simplex', 'Horizontal', 'Vertical')]
                [string]$DuplexOption = 'None',

                [parameter(ValueFromPipelineByPropertyName)]
                [string]$PaperSize = 'None',

                [parameter(ValueFromPipelineByPropertyName)]
                [ValidateSet('n','y')]
                [string]$IsRX = 'n',

                [parameter(ValueFromPipelineByPropertyName)]
                [string]$MediaType = 'None',

                [parameter(ValueFromPipelineByPropertyName)]
                [switch]$Append
            )

            begin {
                if ($Append) {
                    $TransformHostPath  = [System.IO.Path]::Combine($OMPlusSystemPath, 'sendHosts')
                    $TransformHosts     = Get-Content -Path $TransformHostPath
                    Remove-Variable -Name TransformHostPath

                    $pingMsgPath = [system.io.path]::Combine($OMPlusBinPath, 'pingmsg.exe')
                    $EPSMapPath = [system.io.path]::Combine($OMPlusSystemPath, 'eps_map')
                }

                $TrayDictionary         = Get-OMPlusTypeTable -DriverType $DriverName -DisplayType Trays
                $PaperSizeDictionary    = Get-OMPlusTypeTable -DriverType $DriverName -DisplayType PaperSizes
                $MediaTypeDictionary    = Get-OMPlusTypeTable -DriverType $DriverName -DisplayType MediaTypes
            }

            process {

                $thisRecord = New-Object -TypeName System.Collections.Generic.List[string]
                $thisRecord.Add($ServerName)
                $thisRecord.Add($EPRQueueName)
                $thisRecord.Add($OMPLusQueueName)
                $thisRecord.Add($DriverName)


                if ($TrayName -eq 'None') {
                    $thisRecord.Add('DELETEME')
                }
                else {
                    $thisMatch = $TrayDictionary | Where-Object { $_.TrayRef -match ('^{0}$' -f [RegEx]::Escape($TrayName) ) } |
                        Measure-Object | Select-Object -Property Count
                    switch ($thisMatch.Count) {
                        0 {
                            $thisRecord.Add('DELETEME')
                            $Message = 'No tray names match {0}, putting in an empty field' -f $TrayName
                            Write-Verbose -Message $Message
                        }
                        1 {
                            $thisRecord.Add( ('!{0}' -f ($TrayDictionary |
                                Where-Object { $_.TrayRef -Match [regex]::escape($TrayName) } |
                                Select-Object -ExpandProperty TrayID))
                            )
                        }
                        default {
                            $Message = 'TrayName ({0}) matches too many items, please narrow the list and try again' -f $TrayName
                            Write-Warning -Message $Message
                            return
                        }
                    }
                    Remove-Variable -Name thisMatch
                }

                if ($DuplexOption -eq 'None') {
                    $thisRecord.Add('DELETEME')
                }
                else {
                    $thisRecord.Add($DuplexOption)
                }

                if ($PaperSize -eq 'None') {
                    $thisRecord.Add('DELETEME')
                }
                else {
                    $thisMatch = $PaperSizeDictionary | Where-Object { $_.PaperSizeRef -match ('^{0}$' -f [RegEx]::Escape( $PaperSize)) } |
                        Measure-Object | Select-Object -Property Count


                    switch ($thisMatch.Count) {
                        0 {
                            $thisRecord.Add('DELETEME')
                            $Message = 'No PaperSize names match {0}, putting in an empty field' -f $PaperSize
                            Write-Verbose -Message $Message
                        }
                        1 {
                            $thisRecord.Add( ('!{0}' -f ($PaperSizeDictionary |
                                Where-Object { $_.PaperSizeRef -Match [regex]::escape($PaperSize) } |
                                Select-Object -ExpandProperty PaperSizeID))
                            )
                        }
                        default {
                            $Message = 'PaperSize ({0}) matches too many items, please narrow the list and try again' -f $PaperSize
                            Write-Warning -Message $Message
                            return
                        }
                    }
                    Remove-Variable -Name thisMatch
                }

                $thisRecord.Add($IsRX)

                if ($MediaType -eq 'None') {
                    $thisRecord.Add('DELETEME')
                }
                else {
                    $thisMatch = $MediaTypeDictionary | Where-Object { $_.MediaTypeRef -match ('^{0}$' -f [RegEx]::Escape( $MediaType) ) } |
                        Measure-Object | Select-Object -Property Count

                    switch ($thisMatch.Count) {
                        0 {
                            $thisRecord.Add('DELETEME')
                            $Message = 'No MediaType names match {0}, putting in an empty field' -f $MediaType
                            Write-Verbose -Message $Message
                        }
                        1 {
                            $thisRecord.Add( ('!{0}' -f ($MediaTypeDictionary |
                                Where-Object { $_.MediaTypeRef -Match [regex]::escape($MediaType) } |
                                Select-Object -ExpandProperty MediaTypeID))
                            )
                        }
                        default {
                            $Message = 'MediaType ({0}) matches too many items, please narrow the list and try again' -f $MediaType
                            Write-Warning -Message $Message
                            return
                        }
                    }
                    Remove-Variable -Name thisMatch
                }
                $thisRecord = $thisRecord -join '|' -replace 'DELETEME'
            }

            end {
                if ($Append -and $PSCmdlet.ShouldProcess('Updating eps_map file', '', '')) {
                    $AddSplat = @{
                        Path  = $EPSMapPath
                        Value = $thisRecord
                    }
                    Add-Content @AddSplat
                    Update-OMPlusTransformServer
                }
                else {
                    $thisRecord
                }
            }
        }
    }
}
