if ($PSVersionTable.PSVersion.Major -ge 5 -and $IsOMPrimaryMPS) {
    Function Update-OMEPRRecord {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$EPRQueueName,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$ServerName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-OMPrinterList |
                Where-Object { $_ -like "$WordToComplete*"} |
                Sort-Object |
                Foreach-Object {
                    [System.Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        [System.Management.Automation.CompletionResultType]::ParameterValue,
                        ('Printer Name: {0}' -f $_ )
                    )
                }
        })]
        [string]$OMQueueName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-OMDriverNames | Select-object -ExpandProperty 'Driver' |
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
                Get-OMTypeTable -DriverType $DriverName -DisplayType Trays   | Select-object -ExpandProperty 'TrayRef' |
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
        [string]$TrayName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('None', 'Simplex', 'Horizontal', 'Vertical')]
        [string]$DuplexOption,

        [parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-OMTypeTable -DriverType $DriverName -DisplayType MediaType   | Select-object -ExpandProperty 'PaperSizeRef' |
                Where-Object { $_ -like "$WordToComplete*"} |
                Sort-Object |
                Foreach-Object {
                    [System.Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        [System.Management.Automation.CompletionResultType]::ParameterValue,
                        ('PaperType: {0}' -f $_ )
                    )
                }
        })]
        [string]$PaperSize,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('n','y')]
        [string]$IsRX = 'n',

        [parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                Get-OMTypeTable -DriverType $DriverName -DisplayType MediaType   | Select-object -ExpandProperty 'MediaTypeRef' |
                Where-Object { $_ -like "$WordToComplete*"} |
                Sort-Object |
                Foreach-Object {
                    [System.Management.Automation.CompletionResult]::new(
                        $_,
                        $_,
                        [System.Management.Automation.CompletionResultType]::ParameterValue,
                        ('MediaType: {0}' -f $_ )
                    )
                }
        })]
        [string]$MediaType
    )

        $EPSPath    = [system.io.path]::Combine($OMVariables.System, 'eps_map')
        $TopSection = [System.Text.StringBuilder]::new()
        $Delimiter  = '|'
        $Stream     = [System.IO.StreamReader]::new($EPSPath)
        $Header     = 'ServerName','EPRQueueName','OMPlusQueueName','DriveName','TrayName','DuplexOption','PaperSize','IsRX','MediaType'

        do {
            $line = $Stream.ReadLine()
            if ($line -match '^#') {
                [void]$TopSection.AppendLine($line)
                [void]($header = ($line -replace '^#(\s+)?').Split($Delimiter))
            }
            elseif ($line -match $EPRQueueName) {
                $MyRecord = ConvertFrom-Csv -InputObject $line -Header $header -Delimiter '|'
                foreach ($Param in $PSBoundParameters) {
                    switch ($Param) {
                        'OMPlusQueueName' {
                            $MyRecord['OMPlusQueueName'] = $OMQueueName
                        }
                        'DriverName' {
                            if ($ValidTypes -contains $DriverName) {
                                $MyRecord['DriverName'] = $DriverName
                            }
                            else {
                                $Message = '{0} is not a valid driver for this system; not updating the DriverName in the record' -f $DriverName
                                Write-Warning -Message $Message
                            }
                        }
                        'TrayName' {
                            if ($DriverName) {
                                if ($ValidTypes -contains $DriverName) {
                                    $Message = 'New Driver type ({0}) is valid' -f $DriverName
                                    Write-Verbose -Message $Message
                                    $thisDriver = $DriverName
                                    $ShouldProceed = $true
                                }
                                else {
                                    $Message = 'New drivername {0} is not a valid driver for this system; not updating the TrayName field' -f $DriverName
                                    Write-Warning -Message $Message
                                    $ShouldProceed = $false
                                }
                            }
                            else {
                                $ShouldProceed = $true
                                $thisDriver = $MyRecord['DriverName']
                            }

                            if ($ShouldProceed) {
                                $MyRecord.TrayName = '!{0}' -f (Get-OMTypeTable -DriverName $thisDriver -DisplayType Trays |
                                                        Where-Object TrayRef -match $TrayName |
                                                        Select-Object -ExpandProperty TrayID )
                            }

                        }
                        'DuplexOption' {
                            if ($DuplexOption -eq 'none') {
                                $MyRecord['DuplexOption'] = ''
                            }
                            else {
                                $MyRecord['DuplexOption'] = $DuplexOption
                            }
                        }

                        'PaperSize' {
                            if ($DriverName) {
                                if ($ValidTypes -contains $DriverName) {
                                    $Message        = 'New Driver type ({0}) is valid' -f $DriverName
                                    Write-Verbose -Message $Message
                                    $thisPaperSize  = $PaperSize
                                    $ShouldProceed  = $true
                                }
                                else {
                                    $Message = 'New drivername {0} is not a valid driver for this system; not updating the MediaType field' -f $DriverName
                                    Write-Warning -Message $Message
                                    $ShouldProceed = $false
                                }
                            }
                            else {
                                $ShouldProceed  = $true
                                $thisPaperSize  = $MyRecord['PaperSize']
                            }

                            if ($ShouldProceed) {
                                $MyRecord.PaperSize = '!{0}' -f (Get-OMTypeTable -DriverName $thisPaperSize -DisplayType PaperSizes |
                                                        Where-Object PaperSizeRef -match $thisPaperSize |
                                                        Select-Object -ExpandProperty PaperSizeID )
                            }

                        }

                        'IsRX' {
                            $MyRecord['IsRX'] = $IsRX
                        }
                        'MediaType' {
                            if ($DriverName) {
                                if ($ValidTypes -contains $DriverName) {
                                    $Message        = 'New Driver type ({0}) is valid' -f $DriverName
                                    Write-Verbose -Message $Message
                                    $thisMedia      = $MediaType
                                    $ShouldProceed  = $true
                                }
                                else {
                                    $Message = 'New drivername {0} is not a valid driver for this system; not updating the MediaType field' -f $DriverName
                                    Write-Warning -Message $Message
                                    $ShouldProceed = $false
                                }
                            }
                            else {
                                $ShouldProceed  = $true
                                $thisMedia      = $MyRecord['MediaType']
                            }

                            if ($ShouldProceed) {
                                $MyRecord.MediaType = '!{0}' -f (Get-OMTypeTable -DriverName $thisMedia -DisplayType MediaType |
                                                        Where-Object MediaTypeRef -match $thisMedia |
                                                        Select-Object -ExpandProperty MediaTypeID )
                            }

                        }
                    }
                }
                $TopSection.AppendLine( $($MyRecord -join '|') )
            }
            else {
                $TopSection.AppendLine($line)
            }
        } until ($Stream.EndOfStream)
        $stream.Close()

        $PSCmdMessage = 'Updating EPR Record for {0}' -f $EPRQueueName
        if ($PSCmdlet.ShouldProcess($PSCmdMessage, '', '')) {
            Try {
                $TopSection.ToString() | Out-File -FilePath $EPSPath -Force -ErrorAction Stop
                $ShouldUpdate = $true
            }
            catch {
                $Message = 'Unable to overwrite eps_map file, record NOT updated'
                $ShouldUpdate = $false
            }

            if ($ShouldUpdate) {
                Update-OMTransformServer
            }
        }
    }
}
elseif ($PSVersionTable.PSVersion.Major -lt 5 -and $IsOMPrimaryMPS) {

        Function Update-OMEPRRecord {
        [cmdletbinding(SupportsShouldProcess)]
        param(
            [parameter(Mandatory, ValueFromPipelineByPropertyName)]
            [string]$EPRQueueName,

            [parameter(ValueFromPipelineByPropertyName)]
            [string]$ServerName,

            [parameter(ValueFromPipelineByPropertyName)]
            [string]$OMPlusQueueName,

            [parameter(ValueFromPipelineByPropertyName)]
            [string]$DriverName,

            [parameter(ValueFromPipelineByPropertyName)]
            [string]$TrayName,

            [parameter(ValueFromPipelineByPropertyName)]
            [ValidateSet('None', 'Simplex', 'Horizontal', 'Vertical')]
            [string]$DuplexOption,

            [parameter(ValueFromPipelineByPropertyName)]
            [string]$PaperSize,

            [parameter(ValueFromPipelineByPropertyName)]
            [ValidateSet('n','y')]
            [string]$IsRX = 'n',

            [parameter(ValueFromPipelineByPropertyName)]
            [string]$MediaType
        )

        $EPSPath    = [system.io.path]::Combine($OMVariables.System, 'eps_map')
        $TopSection = [System.Text.StringBuilder]::new()
        $Delimiter  = '|'
        $Stream     = [System.IO.StreamReader]::new($EPSPath)
        $Header     = 'ServerName','EPRQueueName','OMPlusQueueName','DriveName','TrayName','DuplexOption','PaperSize','IsRX','MediaType'

        do {
            $line = $Stream.ReadLine()
            if ($line -match '^#') {
                [void]$TopSection.AppendLine($line)
                [void]($header = ($line -replace '^#(\s+)?').Split($Delimiter))
            }
            elseif ($line -match $EPRQueueName) {
                $MyRecord = ConvertFrom-Csv -InputObject $line -Header $header -Delimiter '|'
                foreach ($Param in $PSBoundParameters) {
                    switch ($Param) {
                        'OMPlusQueueName' {
                            $MyRecord['OMPlusQueueName'] = $OMQueueName
                        }
                        'DriverName' {
                            if ($ValidTypes -contains $DriverName) {
                                $MyRecord['DriverName'] = $DriverName
                            }
                            else {
                                $Message = '{0} is not a valid driver for this system; not updating the DriverName in the record' -f $DriverName
                                Write-Warning -Message $Message
                            }
                        }
                        'TrayName' {
                            if ($DriverName) {
                                if ($ValidTypes -contains $DriverName) {
                                    $Message = 'New Driver type ({0}) is valid' -f $DriverName
                                    Write-Verbose -Message $Message
                                    $thisDriver = $DriverName
                                    $ShouldProceed = $true
                                }
                                else {
                                    $Message = 'New drivername {0} is not a valid driver for this system; not updating the TrayName field' -f $DriverName
                                    Write-Warning -Message $Message
                                    $ShouldProceed = $false
                                }
                            }
                            else {
                                $ShouldProceed = $true
                                $thisDriver = $MyRecord['TrayName']
                            }

                            if ($ShouldProceed) {
                                $MyRecord.TrayName = '!{0}' -f (Get-OMTypeTable -DriverName $thisDriver -DisplayType Trays |
                                                        Where-Object TrayRef -match $TrayName |
                                                        Select-Object -ExpandProperty TrayID )
                            }

                        }
                        'DuplexOption' {
                            if ($DuplexOption -eq 'none') {
                                $MyRecord['DuplexOption'] = ''
                            }
                            else {
                                $MyRecord['DuplexOption'] = $DuplexOption
                            }
                        }

                        'PaperSize' {
                            if ($DriverName) {
                                if ($ValidTypes -contains $DriverName) {
                                    $Message        = 'New Driver type ({0}) is valid' -f $DriverName
                                    Write-Verbose -Message $Message
                                    $thisPaperSize  = $PaperSize
                                    $ShouldProceed  = $true
                                }
                                else {
                                    $Message = 'New drivername {0} is not a valid driver for this system; not updating the MediaType field' -f $DriverName
                                    Write-Warning -Message $Message
                                    $ShouldProceed = $false
                                }
                            }
                            else {
                                $ShouldProceed  = $true
                                $thisPaperSize  = $MyRecord['PaperSize']
                            }

                            if ($ShouldProceed) {
                                $MyRecord.PaperSize = '!{0}' -f (Get-OMTypeTable -DriverName $thisPaperSize -DisplayType PaperSizes |
                                                        Where-Object PaperSizeRef -match $thisPaperSize |
                                                        Select-Object -ExpandProperty PaperSizeID )
                            }

                        }

                        'IsRX' {
                            $MyRecord['IsRX'] = $IsRX
                        }
                        'MediaType' {
                            if ($DriverName) {
                                if ($ValidTypes -contains $DriverName) {
                                    $Message        = 'New Driver type ({0}) is valid' -f $DriverName
                                    Write-Verbose -Message $Message
                                    $thisMedia      = $MediaType
                                    $ShouldProceed  = $true
                                }
                                else {
                                    $Message = 'New drivername {0} is not a valid driver for this system; not updating the MediaType field' -f $DriverName
                                    Write-Warning -Message $Message
                                    $ShouldProceed = $false
                                }
                            }
                            else {
                                $ShouldProceed  = $true
                                $thisMedia      = $MyRecord['MediaType']
                            }

                            if ($ShouldProceed) {
                                $MyRecord.MediaType = '!{0}' -f (Get-OMTypeTable -DriverName $thisMedia -DisplayType MediaType |
                                                        Where-Object MediaTypeRef -match $thisMedia |
                                                        Select-Object -ExpandProperty MediaTypeID )
                            }

                        }
                    }
                }
                $argArray = @( $MyRecord.ServerName, $MyRecord.EPRQueueName,    $MyRecord.OMPlusQueueName,
                               $MyRecord.DriveName,  $MyRecord.TrayName,        $MyRecord.DuplexOption,
                               $MyRecord.PaperSize,  $MyRecord.IsRX,            $MyRecord.MediaType )
                $thisLine = '{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}|{8}' -f $argArray
                $TopSection.AppendLine( $($thisLine | ConvertFrom-CSV -join '|') )
            }
            else {
                $TopSection.AppendLine($line)
            }
        } until ($Stream.EndOfStream)
        $stream.Close()

        $PSCmdMessage = 'Updating EPR Record for {0}' -f $EPRQueueName
        if ($PSCmdlet.ShouldProcess($PSCmdMessage, '', '')) {
            Try {
                $TopSection.ToString() | Out-File -FilePath $EPSPath -Force -ErrorAction Stop
                $ShouldUpdate = $true
            }
            catch {
                $Message = 'Unable to overwrite eps_map file, record NOT updated'
                $ShouldUpdate = $false
            }

            if ($ShouldUpdate) {
                Update-OMTransformServer
            }
        }
    }
}
else {
    Write-Warning -Message 'Not on Primary MPS Server, Not loading Update-OMEPRRecord function'
}
