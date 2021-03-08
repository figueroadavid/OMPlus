if ($PSVersionTable.PSVersion.Major -ge 5) {
    Function Get-OMPPrinterConfiguration {
        <#
        .SYNOPSIS
            Retrieves the properties of one or more configurations in OMPlus
        .DESCRIPTION
            The utility reads the configuration file from the printer directory and converts the information
            into a PSCustomObject.
        .EXAMPLE
            PS C:\> Get-OMPlusPrinterConfiguration -PrinterName Printer01

            Printer          : Printer01
            Mode             : termserv
            Device           : 10.0.0.1!9100
            Stty             : none
            Filter           : dcctmserv
            User_Filter      : none
            Def_form         : stock
            Form             : stock
            Accept           : y
            Accepttime       : 001443446160
            Acceptreason     : New Printer
            Enable           : y
            Enabletime       : 001445452018
            Enablereason     : Unknown
            Metering         : 0
            Model            : omstandard.js
            Filebreak        : n
            Copybreak        : n
            Banner           : n
            Lf_crlf          : y
            Close_delay      : 10
            Writetime        : 5399
            Opentime         : 180
            Purgetime        : 100
            Draintime        : 5399
            Terminfo         : dumb
            Pcap             : none
            URL              : http://10.0.0.1
            CMD1             : none
            Comments         : none
            Support          : none
            Xtable           : standard
            Notify_flag      : 0
            Notify_info      : none
            Two_way_protocol : none
            Two_way_address  : none
            Alt_dest         : none
            Sw_dest          : none
            Page_limit       : 0
            Data_types       : all
            FO               : n
            HD               : n
            PG               : y
            LG               : 0
            DC               : default
            CP               : y
            RT               : 30
            EM               : none
            PT               : none
            PD               : n

        .EXAMPLE
            PS C:\>Get-OMPlusPrinterConfiguration -PrinterName Printer1, Printer2 -Property Printer,URL,Mode

            Printer                         Mode                        URL
            -------                         ----                        ---
            Printer1                        termserv                    http://10.0.0.1
            Printer2                        termserv                    http://10.0.0.2

        .PARAMETER PrinterName
            The name of the printer(s) to retrieve the configuration from

        .PARAMETER Property
            The list of properties to return from the printer objects queried

        .INPUTS
            [string]
        .OUTPUTS
            [pscustomobject]
        .NOTES
            The script reads in the properties to create a hashtable and the converts it a PSCustomObject.
            The printer configuration file does not provide the printers actual name, so the 'printer' property is
            automatically added containing the printer name.
        #>
        [cmdletbinding()]
        param(
            [parameter(Mandatory)]
            [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                    Get-OMPlusPrinterList |
                    Where-Object { $_ -like "$WordToComplete*"} |
                    Sort-Object |
                    Foreach-Object {
                        [System.Management.Automation.CompletionResult]::new(
                            $_,
                            $_,
                            [System.Management.Automation.CompletionResultType]::ParameterValue,
                            ('PrinterName: {0}' -f $_ )
                        )
                    }
            })]
            [string[]]$PrinterName,

            [string[]]$Property = 'All'
        )

        if ($Property -contains 'All') {
            $AllProperties = $true
        }

        foreach ($Printer in $PrinterName) {
            $ConfigPath = [System.IO.Path]::Combine($OMPlusPrinterPath, $Printer, 'configuration')
            Try {
                $Config = Get-Content -Path $ConfigPath -ErrorAction Stop
            }
            catch {
                Write-Warning -Message ('Printer ({0}) does not appear to exist, skipping' -f $Printer)
                Continue
            }

            $Output = [pscustomobject]@{
                Printer = $Printer
            }

            $Config | ForEach-Object {
                $null = $_ -match '^(?<KeyName>\w+):\s(?<ValueName>.*)$'
                if ($Matches.KeyName -in $Property -or $AllProperties ) {
                    Add-Member -InputObject $Output -MemberType NoteProperty -Name $Matches.KeyName -Value $Matches.ValueName
                }
            }
            $Output
        }
    }
}
else {
    Function Get-OMPPrinterConfiguration {
        <#
        .SYNOPSIS
            Retrieves the properties of one or more configurations in OMPlus
        .DESCRIPTION
            The utility reads the configuration file from the printer directory and converts the information
            into a PSCustomObject.
        .EXAMPLE
            PS C:\> Get-OMPlusPrinterConfiguration -PrinterName Printer01

            Printer          : Printer01
            Mode             : termserv
            Device           : 10.0.0.1!9100
            Stty             : none
            Filter           : dcctmserv
            User_Filter      : none
            Def_form         : stock
            Form             : stock
            Accept           : y
            Accepttime       : 001443446160
            Acceptreason     : New Printer
            Enable           : y
            Enabletime       : 001445452018
            Enablereason     : Unknown
            Metering         : 0
            Model            : omstandard.js
            Filebreak        : n
            Copybreak        : n
            Banner           : n
            Lf_crlf          : y
            Close_delay      : 10
            Writetime        : 5399
            Opentime         : 180
            Purgetime        : 100
            Draintime        : 5399
            Terminfo         : dumb
            Pcap             : none
            URL              : http://10.0.0.1
            CMD1             : none
            Comments         : none
            Support          : none
            Xtable           : standard
            Notify_flag      : 0
            Notify_info      : none
            Two_way_protocol : none
            Two_way_address  : none
            Alt_dest         : none
            Sw_dest          : none
            Page_limit       : 0
            Data_types       : all
            FO               : n
            HD               : n
            PG               : y
            LG               : 0
            DC               : default
            CP               : y
            RT               : 30
            EM               : none
            PT               : none
            PD               : n

        .EXAMPLE
            PS C:\>Get-OMPlusPrinterConfiguration -PrinterName Printer1, Printer2 -Property Printer,URL,Mode

            Printer                         Mode                        URL
            -------                         ----                        ---
            Printer1                        termserv                    http://10.0.0.1
            Printer2                        termserv                    http://10.0.0.2

        .PARAMETER PrinterName
            The name of the printer(s) to retrieve the configuration from

        .PARAMETER Property
            The list of properties to return from the printer objects queried

        .INPUTS
            [string]
        .OUTPUTS
            [pscustomobject]
        .NOTES
            The script reads in the properties to create a hashtable and the converts it a PSCustomObject.
            The printer configuration file does not provide the printers actual name, so the 'printer' property is
            automatically added containing the printer name.
        #>
        [cmdletbinding()]
        param(
            [parameter(Mandatory)]
            [string[]]$PrinterName,

            [string[]]$Property = 'All'
        )

        if ($Property -contains 'All') {
            $AllProperties = $true
        }

        foreach ($Printer in $PrinterName) {
            $ConfigPath = [System.IO.Path]::Combine($OMPlusPrinterPath, $Printer, 'configuration')
            Try {
                $Config = Get-Content -Path $ConfigPath -ErrorAction Stop
            }
            catch {
                Write-Warning -Message ('Printer ({0}) does not appear to exist, skipping' -f $Printer)
                Continue
            }

            $Output = [pscustomobject]@{
                Printer = $Printer
            }

            $Config | ForEach-Object {
                $null = $_ -match '^(?<KeyName>\w+):\s(?<ValueName>.*)$'
                if ($Matches.KeyName -in $Property -or $AllProperties ) {
                    Add-Member -InputObject $Output -MemberType NoteProperty -Name $Matches.KeyName -Value $Matches.ValueName
                }
            }
            $Output
        }
    }
}
