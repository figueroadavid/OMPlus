function Get-OMPlusTypeTable {
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [string]$DriverType,

        [parameter(Mandatory)]
        [ValidateSet('Trays','PaperSizes','MediaTypes')]
        [string]$DisplayType,

        [parameter()]
        [ValidateSet('Type','ID')]
        [string]$SortBy = 'Type'
    )

    $TypesFile = [system.io.path]::Combine($Global:OMHOMEPATH, 'system', 'types.conf')
    $XML = New-Object -TypeName XML
    $XML.Load($TypesFile)

    $BaseDriverTypes = Select-XML -XML $XML -XPath '//PTYPE' | Select-Object -ExpandProperty node | Select-Object -ExpandProperty name
    if ($DriverType -in $BaseDriverTypes) {
        Write-Verbose -Message ('This DriverType ({0}) is supported on this system' -f $DriverType)
    }
    else {
        Write-Warning ('This DriverType ({0}) is not supported on this system.{1}' -f $DriverType, $CRLF)
        Write-Verbose -Message ('List of supported DriverTypes:{0}{1}' -f $CRLF, ($BaseDriverTypes -join $CRLF)) -Verbose
        return
    }

    switch ($DisplayType) {
        'Trays'      {
            switch ($SortBy) {
                'Type' { $SortType = 'TrayType' }
                'ID'   { $SortType = 'ID' }
            }
            $Trays = Select-XML -XML $XML -XPath ('//PTYPE[@name="{0}"]/TRAYS/TRAY' -f $DriverType)  | Select-Object -ExpandProperty Node
            $Trays | Select-Object -Property @{n='TrayType';e={$_.'#text'}},@{n='TrayID';e={$_.id}} | Sort-Object -Property $SortType
        }
        'PaperSizes' {
            switch ($SortBy) {
                'Type' { $SortType = 'PaperSize' }
                'ID'   { $SortType = 'ID' }
            }
            $Paper = Select-XML -XML $XML -XPath ('//PTYPE[@name="{0}"]/PSIZE/PAPER' -f $DriverType) | Select-Object -ExpandProperty Node
            $Paper | Select-Object -Property @{n='PaperSize';e={$_.'#text'}},@{n='PaperSizeID';e={$_.id}} | Sort-Object -Property $SortType
        }
        'MediaTypes' {
            switch ($SortBy) {
                'Type' { $SortType = 'MediaType' }
                'ID'   { $SortType = 'ID' }
            }
            $Media = Select-XML -XML $XML -XPath ('//PTYPE[@name="{0}"]/MTYPE/MEDIA' -f $DriverType) | Select-Object -ExpandProperty Node
            $Media | Select-Object -Property @{n='MediaType';e={$_.'#text'}},@{n='MediaTypeID';e={$_.id}} | Sort-Object -Property $SortType
        }
    }
}
