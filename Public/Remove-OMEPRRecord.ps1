Function Remove-OMEPRRecord {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('EPR Record', 'Queue', 'EPS Base', 'Tray', 'Simplex/Duplex', 'Paper Size', 'RX', 'Media Type')]
        [string]$MatchField,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Simple', 'RegEx')]
        [String]$MatchType = 'Simple',

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$MatchPattern,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$ReallyDoIt,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(0,100)]
        [int]$ThresholdPercent = 1,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$OverrideThreshold
    )

    begin {
        Read-Host -Prompt 'Function in Development, NOT for production use'
        $EPSPath    = [system.io.path]::Combine($OMVariables.System, 'eps_map')
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
            Copy-Item -Path $EPSPath -Destination $BackupPath
        }
        catch {
            throw 'Could not make a backup of the eps_map file; not continuing'
            return
        }

        Write-Verbose -Message ('Importing the eps_map into a usable format; this will take a few seconds')
        $TopSection = [System.Text.StringBuilder]::new()
        $Delimiter = '|'
        $Stream = [System.IO.StreamReader]::new($EPSPath)
        $CSVCollection = [System.Collections.Generic.List[pscustomobject]]::new()

        do {
            $line = $Stream.ReadLine()
            if ($line -match '^#') {
                [void]$TopSection.AppendLine($line)
                [void]($header = ($line -replace '^#(\s+)?').Split($Delimiter))
            }
            else {
                $CSVCollection.Add( ($Line | ConvertFrom-Csv -Header $header -Delimiter $Delimiter) )
            }
        } until ($Stream.EndOfStream)
        $stream.Close()

        Write-Verbose -Message 'Creating temporary file'
        $TempCSV = New-TemporaryFile

        Write-Verbose -Message 'Exporting EPR Records to temporary CSV file'
        $CSVCollection | Export-CSV -Path $TempCSV -NoTypeInformation -ErrorAction SilentlyContinue

        Write-Verbose -Message 'Importing EPR CSV'
        $thisCSV = Import-CSV -Path $TempCSV

        Write-Verbose -Message ('Import Complete')

        $WhatIfPreference = $OriginalWhatIf
    }

    process {
        if ($PSCmdlet.ShouldProcess( ('Preparing to remove records based on {0}' -f $MatchField), '', '')) {
            switch ($MatchType) {
                'Simple' {
                    $removalCSV = $thisCSV | Where-Object $MatchField -Like $MatchPattern
                    $newCSV     = $thisCSV | Where-Object $MatchField -NotLike $MatchPattern
                }
                'RegEx' {
                    $removalCSV = $thisCSV | Where-Object $MatchField -Match $MatchPattern
                    $newCSV     = $thisCSV | Where-Object $MatchField -NotMatch $MatchPattern

                }
            }

            $Message = 'The new eps_map will contain {0} records; the old eps_map contains {1} records' -f $newCSV.Count, $thisCSV.Count
            Write-Warning -Message $Message


            $RecordsToRemove = ($removalCSV | ConvertTo-Csv -Delimiter $Delimiter -NoTypeInformation  | Out-String ).Replace( '"', '')
            $Message = 'These records are being removed:{0}{1}' -f $CRLF, $RecordsToRemove
            Write-Verbose -Message $Message -Verbose

            if ($ReallyDoIt) {
                $WarningThreshold = [math]::Round( $removalCSV.Count/$thisCSV.Count * 100, [System.MidpointRounding]::AwayFromZero)
                if ($WarningThreshold -gt $ThresholdPercent) {

                    $Message = 'This action will remove more than {0}% of the records from eps_map' -f $ThresholdPercent
                    Write-Warning -Message $Message

                    if ($OverrideThreshold) {
                        $ProceedWithUpdate = $true
                    }
                    else {
                        $ProceedWithUpdate = $false
                        $Message = 'The {0} threshold would be exceeded, and OverrideThreshold switch not specified; not updating the file' -f $ThresholdPercent
                        Write-Warning -Message $Message
                    }
                }
                else {
                    $ProceedWithUpdate = $true
                }

                if ($ProceedWithUpdate) {
                    Write-Warning -Message 'eps_map being updated'

                    for ($i = 0; $i -le $newCSV.Count; $i++) {
                        [void]($AppendMe = $newCSV[$i].PSObject.Properties.value -join '|')
                        [void]$TopSection.AppendLine($AppendMe)
                    }

                    Set-Content -Path $EPSPath -Value ($TopSection -join $CRLF)

                    Update-OMTransformServer
                }
            }
            else {
                $Message = 'ReallyDoIt switch not specified, not updating the file'
                Write-Warning -Message $Message
            }
        }
    }
}
