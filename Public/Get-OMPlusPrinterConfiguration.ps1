function Get-OMPlusPrinterConfiguration {
    [cmdletbinding()]
    param(
        [string[]]$PrinterName,

        [string[]]$Property = 'All'
    )

    if ($Property -contains 'All') {
        $AllProperties = $true
    }

    foreach ($Printer in $PrinterName) {
        $ConfigPath = [System.IO.Path]::Combine($GLobal:OMPlusPrinterPath, $Printer, 'configuration')
        $Config = Get-Content -Path $ConfigPath
        $Output = @{
            Printer = $Printer
        }

        $Config | ForEach-Object {
            $null = $_ -match '^(?<KeyName>\w+):\s(?<ValueName>.*)$'
            if ($Matches.KeyName -in $Property -or $AllProperties ) {
                $Output.Add($Matches.KeyName, $Matches.ValueName)
            }
        }
        $Output
    }
}
