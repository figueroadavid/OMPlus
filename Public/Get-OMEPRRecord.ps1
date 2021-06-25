function Get-OMEPRRecord {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [string]$EPRQueue,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('Destination')]
        [string]$OMQueue
    )
    
    Begin {
        Write-Verbose -Message 'Loading Drivers and Driver Information'

        $Header = 'Server','EPR','Destination', 'Driver', 'Tray', 'DpxOption', 'PaperSize','RX','Media'
        $EPSMapPath = [system.io.path]::Combine($OMVariables.System, 'eps_map')
        $StreamReader = New-Object -TypeName System.IO.StreamReader -ArgumentList $EPSMapPath
    }

    Process {

    }
    
    While ($line -match '^#') {
        $line   = $StreamReader.ReadLine()
    } 

    do {
        $MyRecord = $StreamReader.ReadLine() | ConvertFrom-Csv -Header $Header -Delimiter '|'

    } until ($StreamReader.EndOfStream)
    $StreamReader.Close()

    
}