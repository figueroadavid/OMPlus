function Remove-OMPlusPrintJob {
    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'byGrp')]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [parameter(ParameterSetName = 'byRID')]
        [parameter(ParameterSetName = 'byStatus')]
        [string]$ComputerName = $env:COMPUTERNAME,

        [parameter(Mandatory, ParameterSetName = 'byRID')]
        [string[]]$RIDNumber,

        [parameter(ParameterSetName = 'byGrp')]
        [int]$JobAgeInMinutes = 60,

        [parameter(Mandatory, ParameterSetName = 'byPrinter')]
        [string]$PrinterName,

        [parameter(Mandatory, ParameterSetName = 'byStatus')]
        [ValidateSet('can','intrd','activ')]
        [string]$Status
    )

    begin {
        $RootPath       = (Get-ItemProperty -Path 'HKLM:\Software\PlusTechnologies\OMPlusServer' -Name OMHOMEPath).OMHOMEPath
        $BinPath        = [System.IO.Path]::Combine($RootPath, 'bin')
        $dccResetPath   = [system.io.path]::Combine($BinPath, 'dccreset.exe')
        $dccCancelPath  = [system.io.path]::Combine($BinPath, 'dcccancel.exe')
        $dccGrpPath     = [system.io.path]::Combine($BinPath, 'dccgrp.exe')
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'byRID' {
                foreach ($Job in $RIDNumber) {
                    if ($Job -match '^\d{5}$' -or $Job -cmatch '^RID\d{5}$') {
                        if ($Job -match '^\d{5}$') {
                            $thisJob = 'RID{0}' -f $Job
                        }
                        else {
                            $thisJob = $Job
                        }
                        if ($PSCmdlet.ShouldProcess('Cancel job {0}' -f $Job), '', '') {
                            $ProcSplat = @{
                                FilePath        = $dccCancelPath
                                ArgumentList    = '-i {0}' -f $thisJob
                                WindowStyle     = 'Hidden'
                                Wait            = $true
                            }
                            if ($ComputerName -eq $env:COMPUTERNAME) {
                                Start-Process @ProcSplat -verb RunAs
                            }
                            else {
                                Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                                    param([System.Collections.IDictionary]$Hash)
                                    Start-Process @Hash
                                } -ArgumentList $ProcSplat
                            }
                        }
                    }
                    else {
                        $Message = 'The supplied job name ({0}) is does not match the correct format of 5 digits, or RIDxxxxx; skipping this job' -f $Job
                        Write-Warning -Message $Message
                    }
                }
                break
            }

            'byGrp' {
                if ($PSCmdlet.ShouldProcess(('Cancel jobs older than {0} minutes' -f $JobAgeInMinutes), '', '')) {
                    $ProcSplat = @{
                        FilePath        = $dccGrpPath
                        ArgumentList    = 'cancel time={0}m' -f $JobAgeInMinutes
                        WindowStyle     = 'Hidden'
                        Verb            = 'RunAs'
                        Wait            = $true
                    }
                    Start-Process @ProcSplat
                }
            }

            'byPrinter' {
                if ($PSCmdlet.ShouldProcess(('Resetting printer {0}' -f $PrinterName), '', '')) {
                    $ProcSplat = @{
                        FilePath        = $dccResetPath
                        ArgumentList    = '-d {0}' -f $PrinterName
                        WindowStyle     = 'Hidden'
                        Verb            = 'RunAs'
                        Wait            = $true
                    }
                }
            }

            'byStatus' {
                if ($PSCmdlet.ShouldProcess('Cancel job by status: {0}' -f $Status), '', '') {
                    $ProcSplat = @{
                        FilePath        = $dccGrpPath
                        ArgumentList    = 'cancel status={0}' -f $Status
                        WindowStyle     = 'Hidden'
                        Wait            = $true
                    }
                    if ($ComputerName -eq $env:COMPUTERNAME) {
                        Start-Process @ProcSplat -verb RunAs
                    }
                    else {
                        Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                            param([System.Collections.IDictionary]$Hash)
                            Start-Process @Hash
                        } -ArgumentList $ProcSplat
                    }
                }
            }
        }
    }
}
