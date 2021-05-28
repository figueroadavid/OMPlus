function Set-OMPrinterRedirection {
    <#
        .SYNOPSIS
            Sets a printer to send print jobs to a different printer, or resets it back to default
        .DESCRIPTION
            Uses the dccswitch.exe command to redirect the printer to another destination.
            It can also turn off the redirection that was previously done.
        .PARAMETER PrinterName
            The name of the printer to redirect (or reset)
        .PARAMETER AltPrinter
            The name of the target printer to send jobs to
        .PARAMETER Reset
            This switch is used to turn off the redirection, and send the jobs back to the original printer
        .EXAMPLE
            PS C:\> Set-OMPrinterAltDestination -PrinterName Printer01 -AltPrinter Printer02

            This redirects any print jobs sent to Printer01 and sends those jobs to Printer02
        .EXAMPLE
            PS C:\> Set-OMPrinterAltDestination -PrinterName Printer01 -Reset

            This undoes the redirection in the previous example, and the jobs sent to Printer01
            will again flow to Printer01
        .INPUTS
            [system.string]
        .OUTPUTS
            [none]
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$PrinterName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'switch')]
        [string]$AltPrinter,

        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'reset')]
        [switch]$Reset,

        [parameter(ValueFromPipelineByPropertyName, DontShow)]
        [switch]$PrintDebugInfo

    )

    switch ($PSCmdlet.ParameterSetName) {
        'reset' {
            $ArgString                              = '{0} none' -f $PrinterName
            $PSCmdMessage                           = 'Resetting the destination for {0}' -f $PrinterName
        }
        'switch' {
            $ArgString                              = '{0} {1}' -f $PrinterName, $AltPrinter
            $PSCmdMessage                           = 'Redirecting print jobs sent to {0} to {1} instead' -f $PrinterName, $AltPrinter
        }
    }

    if ($PSCmdlet.ShouldProcess($PSCmdMessage,'','')) {
        $ProcessStartInfo                           = [System.Diagnostics.ProcessStartInfo]::new()
        $ProcessStartInfo.FileName                  = [system.io.path]::Combine($OMVariables.Bin, 'dccswitch.exe')
        $ProcessStartInfo.WorkingDirectory          = $OMVariables.System
        $ProcessStartInfo.CreateNoWindow            = $true
        $ProcessStartInfo.RedirectStandardError     = $true
        $ProcessStartInfo.RedirectStandardOutput    = $true
        $ProcessStartInfo.UseShellExecute           = $false
        $ProcessStartInfo.Arguments                 = $ArgString

        $Process                                    = New-Object -TypeName System.Diagnostics.Process
        $Process.StartInfo                          = $ProcessStartInfo
        $Process.Start()
        $Process.WaitForExit()
        $Process.StandardError.ReadToEnd()
        $Process.StandardOutput.ReadToEnd()
    }

    if ($PrintDebugInfo) {
        $message = New-Object -TypeName System.Text.StringBuilder
        [void]$message.AppendLine('')
        [void]$message.AppendLine('Debugging information:')
        [void]$message.AppendLine(('DCCSwitchPath = {0}' -f [system.io.path]::Combine($OMVariables.Bin, 'dccswitch.exe')))
        [void]$message.AppendLine(('OMSystemPath = {0}' -f $OMVariables.System))
        [void]$message.AppendLine(('ParameterSetName = {0}' -f $PSCmdlet.ParameterSetName))
        [void]$message.AppendLine(('PrinterName = {0}' -f $PrinterName))
        switch ($PSCmdlet.ParameterSetName) {
            'reset' {
                [void]$message.AppendLine('Reset switch specified')
            }
            'switch' {
                [void]$message.AppendLine(('AltPrinter = {0}' -f $AltPrinter) )
            }
        }
        [void]$message.AppendLine(('ArgString = "{0}"' -f $ArgString))
        Write-Verbose -Message $message.ToString() -Verbose
    }
}
