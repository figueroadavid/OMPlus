$script:DriverInfo = $null

function Get-OMPDriveInfo {
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$DriverName
    )

    end {
        if ($null -eq $script:DriverInfo -or $DriverName -ne $DriveInfo.DriverName) {
            return @{
                DriverName  = $DriverName
                Trays       = (Get-OMPlusTypeTable -DriverType $DriverName -DisplayType Trays       | Where-Object { $null -ne $_.TrayRef }).TrayRef.Trim()
                PaperSizes  = (Get-OMPlusTypeTable -DriverType $DriverName -DisplayType PaperSizes  | Where-Object { $null -ne $_.PaperSizeRef}).PaperSizeRef.Trim()
                MediaTypes  = (Get-OMPlusTypeTable -DriverType $DriverName -DisplayType MediaTypes  | Where-Object { $null -ne $_.MediaTypeRef}).MediaTypeRef.Trim()
            }
        }
    }
}

function New-OMPlusEPRRecord {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [string]$TypeSource = [system.io.path]::Combine($Global:OMPLusSystemPath, 'types.conf'),

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$ComputerName = [system.net.dns]::GetHostByName($env:COMPUTERNAME).hostname,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$EPRQueueName,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$OMPQueueName,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$DriverName,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Tray,

        [parameter(ValueFromPipelineByPropertyName)]
        [AllowEmptyString()]
        [AllowNull()]
        [ValidateSet('Simplex','Horizontal', 'Vertical')]
        [string]$DuplexOption,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$PaperSize,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('n','y')]
        [string]$IsRX = 'n',

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$MediaType
    )

    $TrayID  = Get-OMPlusTypeTable -DriverType $DriverName -DisplayType Trays |
        Where-Object {$_.TrayRef -match [regex]::escape($Tray)} |
        Select-Object -ExpandProperty TrayID

    $PaperID = Get-OMPlusTypeTable -DriverType $DriverName -DisplayType PaperSizes |
        Where-Object {$_.PaperSizeRef -match [regex]::escape($PaperSize)} |
        Select-Object -ExpandProperty PaperSizeID

    $MediaID = Get-OMPlusTypeTable -DriverType $DriverName -DisplayType MediaTypes |
        Where-Object { $_.MediaTypeRef -match [regex]::Escape($MediaType)} |
        Select-Object -ExpandProperty MediaTypeID
    #ServerName|EPR|Queue|Driver|Tray|Duplex|PaperSize|RX|Media
    return ('{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}|{8}' -f $ComputerName, $EPRQueueName, $OMPQueueName, $DriverName, $TrayID, $DuplexOption, $PaperID, $MediaID)
}

Register-ArgumentCompleter -CommandName New-OMPlusEPRRecord -ParameterName DriverName {
    param(
        $CommandName,
        $ParameterName,
        $wordToComplete,
        $CommandAST,
        $FakeBoundParameters
    )
    end {
        $global:ValidTypes -like "$wordToComplete"
    }
}

Register-ArgumentCompleter -CommandName New-OMPlusEPRRecord -ParameterName Tray {
    param(
        $CommandName,
        $ParameterName,
        $WordToComplete,
        $CommandAST,
        $FakeBoundParameters
    )
    end {
        $TrayInfo = Get-OMPDriveInfo -DriverName $fakeBoundParameters['DriverName']
        return $TrayInfo.TrayRef -like "$wordToComplete"
    }
}

Register-ArgumentCompleter -CommandName New-OMPlusEPRRecord -ParameterName PaperSize {
    param(
        $CommandName,
        $ParameterName,
        $wordToComplete,
        $commandAST,
        $fakeBoundParameters
    )
    end {
        $PaperSizeInfo = Get-OMPDriveInfo -DriverName $fakeBoundParameters['DriverName']
        return $PaperSizeInfo.PaperRef -like "$wordToComplete"
    }
}

Register-ArgumentCompleter -CommandName New-OMPlusEPRRecord -ParameterName MediaType {
    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAST,
        $fakeBoundParameters
    )
    end {
        $MediaTypeInfo = Get-OMPDriverInfo -DriverName $fakeBoundParameters['DriverName']
        return $MediaTypeInfo.MediaRef -like "$wordToComplete"
    }
}
