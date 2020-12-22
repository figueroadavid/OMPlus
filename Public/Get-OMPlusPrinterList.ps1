function Get-OMPlusPrinterName {
    [cmdletbinding()]
    param(
        [parameter()]
        [string]$MatchPattern
    )

    $BasePath = [System.IO.Path]::Combine($Global:OMHOMEPATH, 'printers')
    if ($MatchPattern) {
        Get-ChildItem -Path $BasePath -Directory | Where-Object basename -match $MatchPattern | Select-Object -ExpandProperty BaseName
    }
    else {
        Get-ChildItem -Path $OMPlusHome -Directory | Select-Object -ExpandProperty BaseName
    }
}
