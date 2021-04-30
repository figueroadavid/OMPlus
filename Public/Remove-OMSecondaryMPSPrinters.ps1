Function Remove-OMSecondaryMPSPrinters {
    [cmdletbinding(SupportsShouldProcess, DefaultParameterSetName = 'byDir')]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'byFile')]
        [ValidateScript( {Test-Path -Path $_ } )]
        [string]$PrimaryPrinterFile,

        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'byFile')]
        [ValidateScript( { Test-Path -Path $_ })]
        [string]$SecondaryPrinterFile,

        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'byDir')]
        [string]$PrimaryMPSPrinterDirectory = ( &({
            if ($IsOMPLusPrimaryMPS) {
                $OMPrinterPath
            }
            else {
                '\\{0}\{1}' -f $OMPrimaryMPS, $OMPrinterPath.Replace(':', '$')
            }
        })),

        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'byDir')]
        [string]$SecondaryMPSPrinterDirectory = (& ({
            if ($IsOMPLusPrimaryMPS) {
                '\\{0}\{1}' -f $OMSecondaryMPS, $OMPrinterPath.Replace(':', '$')
            }
            else {
                $OMPrinterPath
            }
        })),

        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'byList')]
        [string[]]$PrimaryList,

        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'byList')]
        [string[]]$SecondaryList,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$SecondaryMPSIsTransform
    )

    Begin {
        switch ($PSCmdlet.ParameterSetName) {
            'byDir' {
                try {
                    $Primarylist   = Get-ChildItem -Path $PrimaryMPSPrinterDirectory | Select-Object -ExpandProperty BaseName -ErrorAction Stop
                    $SecondaryList = Get-ChildITem -Path $SecondaryMPSPrinterDirectory | Select-Object -ExpandProperty BaseName
                }
                catch {
                    $pscmdlet.ThrowTerminatingError($_.exception.message)
                }
                break
            }

            'byFile' {
                $PrimaryList = Get-Content -Path $PrimaryPrinterFile
                $SecondaryList = Get-Content -Path $SecondaryPrinterFile
            }
        }

        if ($SecondaryMPSIsTransform) {
            $MatchPattern = '\$_|pt_transform'
            $Message = '$SecondaryMPSIsTransform switch is present, not deleting transform printers'
        }
        else {
            $MatchPattern = '\$_'
            $Message = '$SecondaryMPSIsTransform switch is not present, any pt_transform printers will be deleted along with the rest'
        }

        Write-Verbose -Message $Message
        $PrintersToRemove = Compare-Object -ReferenceObject $PrimaryList -DifferenceObject $SecondaryList |
            Where-Object { $_.SideIndicator -eq '=>' -and $_.name -notmatch $MatchPattern } |
            Select-Object -ExpandProperty InputObject
    }

    process {
        if ($IsOMPLusPrimaryMPS) {
            if (Test-WSMan -ComputerName $OMSecondaryMPS)
            {
                $PSCmdMessage = 'Removing this printer list from {0}{1}{2}' -f $OMSecondaryMPS, $CRLF, ($PrintersToRemove -join ',')
                if ($pscmdlet.ShouldProcess($PSCmdMessage, '', '' )) {
                    Invoke-Command -ComputerName $OMSecondaryMPS -ScriptBlock {
                        Import-Module -Name OMPlus
                        Remove-OMPrinter -PrinterName $Using:PrintersToRemove
                    }
                }

            }
            else {
                $PSCmdMessage = 'Unable to reach {0} through WSMan (PSRemoting); please rerun this command on that server' -f $OMSecondaryMPS
                Write-Warning -Message $PSCmdMessage
            }
        }
        else {
            $PSCmdMessage = 'Removing this printer list from {0}{1}{2}' -f $env:COMPUTERNAME, $CRLF, ($PrintersToRemove -join ',')
            if ($pscmdlet.ShouldProcess($PSCmdMessage, '', '')) {
                Remove-OMPrinter -PrinterName $PrintersToRemove
            }
        }
    }
}
