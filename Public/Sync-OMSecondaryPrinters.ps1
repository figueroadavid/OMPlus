 function Sync-OMSecondaryPrinter {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [string[]]$PrinterName,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$ShowProgress
    )

    begin {
        $ProcessStartInfo                           = [System.Diagnostics.ProcessStartInfo]::new()
        $ProcessStartInfo.FileName                  = [system.io.path]::Combine($OMBinPath, 'dmdestsync.exe')
        $ProcessStartInfo.WorkingDirectory          = $OMSystemPath
        $ProcessStartInfo.CreateNoWindow            = $true
        $ProcessStartInfo.RedirectStandardError     = $true
        $ProcessStartInfo.RedirectStandardOutput    = $true
        $ProcessStartInfo.UseShellExecute           = $false

        if ($PrinterName -contains 'All') {
            Write-Warning -Message 'The PrinterName list contains "All", this will take some time'
        }
        $Process = [System.Diagnostics.Process]::new()
    }

    process {
        if ($PrinterName -contains 'All') {
            if ($IsOMPLusPrimaryMPS) {
                $ProcessStartInfo.Arguments     = '-d all'
            }
            else {
                $ProcessStartInfo.Arguments     = '-r all'
            }
            $Process.StartInfo                  = $ProcessStartInfo
            $Process.Start()
            $Process.WaitForExit()
            $Process.StandardError.ReadToEnd()
            $Process.StandardOutput.ReadToEnd()
        }
        else {
            if ($ShowProgress) {
                $CurrentCount = 0
                $ProgressSplat = @{
                    PercentComplete     = [int][math]::round($CurrentCount/$PrinterName.Count * 100, [System.MidpointRounding]::AwayFromZero)
                    CurrentOperation    = 'Start'
                    Status              = 'Starting'
                }
                if ($IsOMPLusPrimaryMPS) {
                    $ProgressSplat['Activity'] = 'Pushing printers from primary MPS to secondary MPS'
                }
                else {
                    $ProgressSplat['Activity'] = 'Pulling printers from primary MPS to secondary MPS'
                }
                Write-Progress @ProgressSplat
            }
            foreach ($Printer in $PrinterName) {
                if ($ShowProgress) {
                    $CurrentCount ++
                    $ProgressSplat = @{
                        PercentComplete     = [int][math]::round($CurrentCount/$PrinterName.Count * 100, [System.MidpointRounding]::AwayFromZero)
                        CurrentOperation    = $Printer
                        Status              = '{0} of {1}' -f $CurrentCount, $PrinterName.Count
                    }
                    if ($IsOMPLusPrimaryMPS) {
                        $ProgressSplat['Activity'] = 'Pushing printers from primary MPS to secondary MPS'
                    }
                    else {
                        $ProgressSplat['Activity'] = 'Pulling printers from primary MPS to secondary MPS'
                    }
                    Write-Progress @ProgressSplat
                }

                if ($IsOMPLusPrimaryMPS) {
                    $ProcessStartInfo.Arguments = '-d {0}' -f $Printer
                }
                else {
                    $ProcessStartInfo.Arguments = '-r {0}' -f $Printer
                }
                $Process.StartInfo = $ProcessStartInfo
                $Process.Start()
                $Process.WaitForExit()
                $Process.StandardError.ReadToEnd()
                $Process.StandardOutput.ReadToEnd()
            }
        }
    }

    end {
        $Process.Close()
    }
}
