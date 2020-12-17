function Get-OMPlusPrinterConfiguration {
    [cmdletbinding()]
    param(
        [string[]]$PrinterName = '*',

        [string[]]$Property = '*'
    )
    $PrinterHome = [system.io.path]::Combine( $Global:OMHOMEPATH, 'printers')
    $PrinterList = Get-ChildItem -Path $PrinterHome -Filter $PrinterName

    foreach ($PrinterDirectory in $PrinterList) {
        $ConfigPath = Join-Path -Path $PrinterDirectory -ChildPath 'configuration'
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
