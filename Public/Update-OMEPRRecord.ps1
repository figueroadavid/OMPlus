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
        [string]$OMPlusQueueName,

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
                        ('Tray Type: {0}' -f $_ )
                    )
                }
        })]
        [string]$MediaType
    )

        $EPSPath    = [system.io.path]::Combine($OMPlusSystemPath, 'eps_map')
        $TopSection = [System.Text.StringBuilder]::new()
        $Delimiter  = '|'
        $Stream = [System.IO.StreamReader]::new($EPSPath)

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
                            $MyRecord['OMPlusQueueName'] = $OMPlusQueueName
                        }
                        'DriverName' {
                            $DriverNames = Get-OMDriverNames | Select-Object -ExpandProperty Driver
                            if ($DriverNames -contains $DriverName) {
                                $MyRecord['DriverName'] = $DriverName
                            }
                            else {
                                $Message = '{0} is not a valid driver for this system; not updating this field in the record' -f $DriverName
                                Write-Warning -Message $Message
                            }
                        }
                        'TrayName' {
                            $TrayLookup = Get-OMTypeTable -
                            $MyRecord['TrayName'] =
                        }
                        'DuplexOption' {

                        }
                        'IsRX' {

                        }
                        'MediaType' {

                        }
                    }
                }

            }
            else {
                $TopSection.AppendLine($line)
            }
        } until ($Stream.EndOfStream)
        $stream.Close()

        Write-Verbose -Message 'Creating temporary file'
        $TempCSV = New-TemporaryFile

        Write-Verbose -Message 'Exporting EPR Records to temporary CSV file'
        $CSVCollection | Export-CSV -Path $TempCSV -NoTypeInformation -ErrorAction SilentlyContinue

        Write-Verbose -Message 'Importing EPR CSV'
        $thisCSV = Import-CSV -Path $TempCSV

        Write-Verbose -Message ('Import Complete')

        $WhatIfPreference = $OriginalWhatIf

        Update-OMTransformServer

}
