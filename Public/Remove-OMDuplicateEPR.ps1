function Remove-OMDuplicateEPR {
    <#
    .SYNOPSIS
        This switch causes the function to display a table of duplicate records
    .DESCRIPTION
        The script reads through the eps_map file and tracks the EPR records (the 2nd field of the record),
        and when a duplicate is found, that duplicate record is stored.  If the -ShowDuplicateRecords switch is used,
        the collection of duplicates is shown at the end for reference.
        The initial record is not tracked, only duplicates.
    .EXAMPLE
        PS C:\> Remove-OMDuplicateEPR -ShowDuplicateRecords
        Explanation of what the example does
    .INPUTS
        [none]
    .OUTPUTS
        [OrderedDictionary] (optional)
    .NOTES
        The script reads in the eps_map file and checks each line (record) for the EPR queue name, and stores it.
        if the list of EPR names contains the line's EPR, then a copy of the duplicate record is stored, and the line is skipped.
        If the list does not contain the EPR, then the line is written to a temporary file.
        The eps_map file is then backed up, and overwritten with the temporary file contents.

    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$ShowDuplicateRecords
    )

    begin {
        $EPRHeader = 'Server','EPR','Queue','Driver','Tray','Dpx','PaperSize','RX'
        $EPRList = New-Object -TypeName 'System.Collections.Generic.List[string]'
        $EPSMap = [system.io.path]::Combine($OMVariables.System , 'eps_map')

        $StreamReader = New-Object -TypeName System.IO.StreamReader -ArgumentList $EPSMap
        $TempOutput = New-TemporaryFile
        $StreamWriter = New-Object -TypeName System.IO.StreamWriter -ArgumentList $TempOutput

        $LineCounter = 0
        $DuplicateTracker = [ordered]@{}

        $Tab = "`t"

        Write-Verbose -Message 'Read through eps_map until we get past the comment lines '
        do {
            $LineCounter++
            $thisLine = $StreamReader.ReadLine()
            $StreamWriter.WriteLine($thisLine)
        } until ($thisLine -notmatch '^#')
    }

    process {
        do {
            $LineCounter++

            $thisLine = $StreamReader.ReadLine()

            $CSVHash = @{
                InputObject = $thisLine
                Delimiter   = '|'
                Header      = $EPRHeader
            }
            $thisRecord = ConvertFrom-Csv @CSVHash

            if ($EPRList -contains $thisRecord.EPR) {
                $RecordKey = '{0}_{1}' -f $thisRecord.EPR, $LineCounter.ToString()
                $null = $DuplicateTracker.Add( $RecordKey, $thisLine )
                if ($ShowDuplicateRecords) {
                    $Message = 'Duplicate record for {0} found at line {1}{2}{3}{3}{3}{3}{4}' -f $thisRecord.EPR, $i.ToString(), [environment]::NewLine, $tab, ($thisRecord -join '|')
                    Write-Verbose -Message $Message
                }
            }
            else {
                $EPRList.Add($thisRecord.EPR)
                $StreamWriter.WriteLine($thisLine)
            }

        } until ($StreamReader.EndOfStream)

        $StreamReader.Dispose()
        $StreamWriter.Dispose($True)
    }

    end {
        if ($ShowDuplicateRecords -and $DuplicateTracker.Count -gt 0) {
            $DuplicateTracker
        }
        else {
            $Message = 'No Duplicate records found; nothing is being changed'
        }

        if ($PSCmdlet.ShouldProcess('Creating backup and overwriting eps_map', '', '')) {
            if ($DuplicateTracker.Count -gt 0) {
                $BackupPath = [system.io.path]::Combine($OMVariables.System, ('eps_map_{0}.bkp' -f [datetime]::Now.ToString('yyyyMMdd_hhmmss')))

                $BackupFiles = Get-ChildItem -path $OMVariables.System -Filter "eps_map*.bkp"
                $BackupCount = $BackupFiles.Count
                if ($BackupCount -ge 10 ) {
                    $Message = 'There are {0} eps_map backup copies, deleting the oldest backups until the count is 10' -f $BackupCount.ToString()
                    Write-Verbose -Message $Message

                    $BackupThresholdCount = $BackupCount - 10

                    $BackupFiles = $BackupFiles | Sort-Object -Property LastWriteTime
                    for ($i = 0; $i -le $BackupThresholdCount; $i++) {
                        Write-Verbose -Message ('Removing item: {0}' -f $BackupFiles[$i].Name)
                        $BackupFiles[$i] | Remove-Item -Force
                    }
                }

                Write-Verbose -Message ('Creating backup of the eps_map ({0})' -f $BackupPath)
                try {
                    Copy-Item -Path $EPSMap -Destination $BackupPath -ErrorAction Stop
                }
                catch {
                    $_.Exception.Message
                    throw 'Could not make a backup of the eps_map file; not continuing'
                    return
                }

                try {
                    Copy-item -Path $TempOutput -Destination $EPSMap -ErrorAction Stop
                    $SuccessfulCopy = $true
                }
                catch {
                    $WarningMessage = @'
Unable to overwrite eps_map file!
The new file is located at {0}, it will not be deleted automatically.
'@ -f $TempOutput.FullName
                    Write-Warning -Message $WarningMessage
                }

                if ($SuccessfulCopy) {
                    Update-OMPTransformServer
                    try {
                        Remove-Item -Path $TempOutput -Force -ErrorAction Stop
                    }
                    catch {
                        $Message = 'Unable to remove temporary file: {0}' -f $TempOutput.FullName
                        Write-Warning -Message $Message
                    }
                }
            }
        }
    }
}
