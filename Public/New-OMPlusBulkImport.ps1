function New-OMPlusBulkImport {
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript({Test-Path -Path $_})]
        [string]$FilePath,

        [Parameter()]
        [char]$Delimiter = ','
    )

    $CSV = Import-CSV -Path $FilePath -Delimiter $Delimiter
    $SuppliedProperties = $CSV | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

    foreach ($Record in $CSV) {
        $OMSplat = @{}
        foreach ($Property in $SuppliedProperties) {
            if ($Record.$Property -match 'TRUE|FALSE') {
                switch ($Record.$Property) {
                    'TRUE'  {$OMSplat[$Property] = $TRUE; break }
                    'FALSE' {$OMSplat[$Property] = $FALSE }
                }
            }
            else {
                $OMSplat[$Property] = $Record.$Property
            }
        }
        New-OMPlusPrinter @OMSplat
    }
}