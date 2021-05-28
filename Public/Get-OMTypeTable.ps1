if ($PSVersionTable.PSVersion.Major -ge 5) {
    Function Get-OMTypeTable {
        [cmdletbinding()]
        param(
            [parameter(Mandatory)]
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
            [string]$DriverType,

            [parameter()]
            [ValidateSet('Trays','PaperSizes','MediaTypes')]
            [string]$DisplayType = 'Trays',

            [parameter()]
            [ValidateSet('Type','ID')]
            [string]$SortBy = 'Type'
        )

        $TypesFile = [system.io.path]::Combine($OMVariables.System, 'types.conf')
        $XML = [xml]::new()
        $XML.Load($TypesFile)

        switch ($DisplayType) {
            'Trays' {
                switch ($SortBy) {
                    'Type' { $SortType = 'TrayRef' }
                    'ID'   { $SortType = 'ID' }
                }
                $Trays = Select-XML -XML $XML -XPath ('//PTYPE[@name="{0}"]/TRAYS/TRAY' -f $DriverType)  | Select-Object -ExpandProperty Node
                $Trays | Select-Object -Property @{n=$SortType;e={($_.'#text').Trim()}},@{n='TrayID';e={$_.id}} |
                    Where-Object { $null -ne $_.TrayRef } | Sort-Object -Property $SortType
            }
            'PaperSizes' {
                switch ($SortBy) {
                    'Type' { $SortType = 'PaperSizeRef' }
                    'ID'   { $SortType = 'ID' }
                }
                $Paper = Select-XML -XML $XML -XPath ('//PTYPE[@name="{0}"]/PSIZE/PAPER' -f $DriverType) | Select-Object -ExpandProperty Node
                $Paper | Select-Object -Property @{n=$SortType;e={($_.'#text').Trim()}},@{n='PaperSizeID';e={$_.id}} |
                    Where-Object { $null -ne $_.PaperSizeRef } | Sort-Object -Property $SortType
            }
            'MediaTypes' {
                switch ($SortBy) {
                    'Type' { $SortType = 'MediaTypeRef' }
                    'ID'   { $SortType = 'ID' }
                }
                $Media = Select-XML -XML $XML -XPath ('//PTYPE[@name="{0}"]/MTYPE/MEDIA' -f $DriverType) | Select-Object -ExpandProperty Node
                $Media | Select-Object -Property @{n=$SortType;e={($_.'#text').Trim()}},@{n='MediaTypeID';e={$_.id}} |
                    Where-Object {$null -ne $_.MediaTypeRef} |Sort-Object -Property $SortType
            }
        }
    }
}
else {
    Function Get-OMTypeTable {
        [cmdletbinding()]
        param(
            [parameter(Mandatory)]
            [string]$DriverType,

            [parameter()]
            [ValidateSet('Trays','PaperSizes','MediaTypes')]
            [string]$DisplayType = 'Trays',

            [parameter()]
            [ValidateSet('Type','ID')]
            [string]$SortBy = 'Type'
        )

        if ($DriverType -in $ValidTypes) {
            Write-Verbose -Message 'Valid type, continuing'
        }
        else {
            throw ('DriverType ({0}) does not appear to be a valid driver type' -f $DriverType)
        }

        $TypesFile = [system.io.path]::Combine($OMVariables.System, 'types.conf')
        $XML = New-Object -TypeName XML
        $XML.Load($TypesFile)

        switch ($DisplayType) {
            'Trays' {
                switch ($SortBy) {
                    'Type' { $SortType = 'TrayRef' }
                    'ID'   { $SortType = 'ID' }
                }
                $Trays = Select-XML -XML $XML -XPath ('//PTYPE[@name="{0}"]/TRAYS/TRAY' -f $DriverType)  | Select-Object -ExpandProperty Node
                $Trays | Select-Object -Property @{n=$SortType;e={($_.'#text').Trim()}},@{n='TrayID';e={$_.id}} |
                    Where-Object { $null -ne $_.TrayRef } | Sort-Object -Property $SortType
            }
            'PaperSizes' {
                switch ($SortBy) {
                    'Type' { $SortType = 'PaperSizeRef' }
                    'ID'   { $SortType = 'ID' }
                }
                $Paper = Select-XML -XML $XML -XPath ('//PTYPE[@name="{0}"]/PSIZE/PAPER' -f $DriverType) | Select-Object -ExpandProperty Node
                $Paper | Select-Object -Property @{n=$SortType;e={($_.'#text').Trim()}},@{n='PaperSizeID';e={$_.id}} |
                    Where-Object { $null -ne $_.PaperSizeRef } | Sort-Object -Property $SortType
            }
            'MediaTypes' {
                switch ($SortBy) {
                    'Type' { $SortType = 'MediaTypeRef' }
                    'ID'   { $SortType = 'ID' }
                }
                $Media = Select-XML -XML $XML -XPath ('//PTYPE[@name="{0}"]/MTYPE/MEDIA' -f $DriverType) | Select-Object -ExpandProperty Node
                $Media | Select-Object -Property @{n=$SortType;e={($_.'#text').Trim()}},@{n='MediaTypeID';e={$_.id}} |
                    Where-Object {$null -ne $_.MediaTypeRef} |Sort-Object -Property $SortType
            }
        }
    }
}
