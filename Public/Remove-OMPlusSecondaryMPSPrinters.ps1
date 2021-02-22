function Remove-OMPlusSecondaryMPSPrinters {
    [cmdletbinding(SupportsShouldProcess, DefaultParameterSetName = 'byDir')]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'byFile')]
        [ValdidateScript( {Test-Path -Path $_ } )]
        [string]$PrimaryPrinterFile,

        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'byFile')]
        [ValidateScript( { Test-Path -Path $_ })]
        [string]$SecondaryPrinterFile,

        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'byDir')]
        [string]$PrimaryMPSPrinterDirectory = ({
            if ($Global:IsOMPLusPrimaryMPS) {
                $GLobal:OMPlusPrinterPath
            }
            else {
                $pingParmPath = [system.io.path]::combine($Global:OMPLusSystemPath, 'pingParms')
                $SecondaryServer = (Get-Content -Path $pingParmPath |
                    Where-Object { $_ -match '^Backup'}).Split('=')[1]
                '\\{0}\{1}' -f $SecondaryServer, $GLobal:OMPlusPrinterPath.Replace(':', '$')
            }
        }),

        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'byDir')]
        [string]$SecondaryMPSPrinterDirectory = ({
            if ($Global:IsOMPLusPrimaryMPS) {
                $pingParmPath = [system.io.path]::combine($Global:OMPLusSystemPath, 'pingParms')
                $SecondaryServer = (Get-Content -Path $pingParmPath |
                    Where-Object { $_ -match '^Backup'}).Split('=')[1]
                '\\{0}\{1}' -f $SecondaryServer, $GLobal:OMPlusPrinterPath.Replace(':', '$')
            }
            else {
                $GLobal:OMPlusPrinterPath
            }
        }),

        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'byList')]
        [string[]]$PrimaryList,

        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'byList')]
        [string[]]$SecondaryList
    )

    Begin {
        switch ($PSBoundParameters.ParameterSetName) {
            'byDir' {
                try {
                    $Primarylist   = Get-ChildItem -Path $PrimaryMPSPrinterDirectory | Select-Object -ExpandProperty BaseName -ErrorAction Stop
                    $SecondaryList = Get-ChildITem -Path $SecondaryMPSPrinterDirectory | Select-Object -ExpandProperty BaseNam
                }
                catch {
                    $pscmdlet.ThrowTerminatingError($_.exception.message)
                }
            }

            'byFile' {
                $PrimaryList = Get-Content -Path $PrimaryPrinterFile
                $SecondaryList = Get-Content -Path $SecondaryPrinterFile
            }
        }

        $PrintersToRemove = Compare-Object -ReferenceObject $PrimaryList -DifferenceObject $SecondaryList |
            Where-Object { $_.SideIndicator -eq '=>' -and $_.name -notmatch '\$_' } |
            Select-Object -ExpandProperty InputObject
    }

    process {
        if ($Global:IsOMPLusPrimaryMPS) {
            if (Test-WSMan -ComputerName )
            {
                $PSCmdMessage = 'Removing this printer list from {0}{1}{2}' -f $Global:OMPlusSecondaryMPS, $CRLF, ($PrintersToRemove -join ',')
                if ($pscmdlet.ShouldProcess($PSCmdMessage, '', '' )) {
                    Invoke-Command -ComputerName $Global:OMPlusSecondaryMPS -ScriptBlock {
                        Import-Module -Name OMPlus
                        Remove-OMPlusPrinter -PrinterName $Using:PrintersToRemove
                    }
                }

            }
            else {
                $PSCmdMessage = 'Removing this printer list from {0}{1}{2}' -f $env:COMPUTERNAME, $CRLF, ($PrintersToRemove -join ',')
                if ($pscmdlet.ShouldProcess($PSCmdMessage, '', '')) {
                    Remove-OMPlusPrinter -PrinterName $PrintersToRemove
                }
            }
        }
    }
}
