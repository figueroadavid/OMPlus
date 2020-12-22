function Get-OMPlusPrinterConfiguration {
    [cmdletbinding()]
    param(
        [string[]]$PrinterName = '*',

        [string[]]$Property = '*'
    )

    $PrinterList = Get-ChildItem -Path $GLobal:OMPlusPrinterPath -Filter $PrinterName

    foreach ($PrinterDirectory in $PrinterList) {
        $ConfigPath = [System.IO.Path]::Combine($PrinterDirectory.FullName, 'configuration')
        $Config = Get-Content -Path $ConfigPath
        $Output = @{
            Printer = $PrinterDirectory.BaseName
        }

        $Config | ForEach-Object {
            $_ -match '^(?<KeyName>\w+):\s(?<ValueName>.*)$'
            $Output.Add($Matches.KeyName, $Matches.ValueName)
        }
        $Output
    }
}
