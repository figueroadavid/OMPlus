function Get-OMDisabledDestination {
    <#
        .SYNOPSIS
            Gathers a list of the disabled printers and either displays them, or emails them
        .DESCRIPTION
            The script looks at the Enabled value of the printer's configurations and returns the ones marked as disabled.
        .NOTES
            It uses the Get-OMPrinterList and Get-OMPrinterConfiguration cmdlets to look at all the configurations. 
            The configuration files are updated within seconds, so while it is a point-in-time snapshot, in most environments,
            it should be very accurate and match the GUI.
        .EXAMPLE
            PS C:\> Get-OMDisabledDestinations -Output Display
            PRINTER01
            PRINTER04
        .PARAMETER Output
            Allows the user to select if the list of disabled printers is displayed on the screen or is emailed 
            The allowable options are 'Display' or 'Email'
        .PARAMETER SMTPFrom
            The address that the email is sent from 
        .PARAMETER SMTPTo
            The address(es) that the mail is sent to.  If there are multiple email addresses, they must be supplied as an array 
        .PARAMETER SMTPSubject
            The subject line of the email 
        .PARAMETER SMTPServer
            The mail server for the email 
        .PARAMETER SMTPPort
            The SMTP Port used by the mail server 
        .PARAMETER SendEmailEvenIfNoDisabledPrinters
            Tells the system to send an email even if there are no disabled printers 
        .PARAMETER ShowProgress
            This switch will show a progress bar as the printers are enumerated and checked. 
            This is useful for systems with a large amount of printers. 
    #>
    
    
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Display', 'Email')]
        [string]$Output,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$SMTPFrom = ('DisabledMonitor_{0}@domain.tld' -f $env:COMPUTERNAME),

        [parameter(ValueFromPipelineByPropertyName)]
        [string[]]$SMTPTo = @('some.email@domain.tld'),

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$SMTPSubject = ('Disabled print queues on {0}' -f $env:COMPUTERNAME),

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$SMTPServer = 'mailserver.domain.tld',

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$SMTPPort = 25,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$SendEmailEvenIfNoDisabledPrinters,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$ShowProgress
    )

    $AllPrinters            = Get-OMPrinterList -Filter *

    if ($ShowProgress) {
        $CurrentCounter     = 0
    }

    $DisabledPrinters       = foreach ($Printer in $AllPrinters) {
        if ($ShowProgress) {
            $CurrentCounter ++
            if ($CurrentCounter % 10 -eq 0 ) {
                $ProgSplat  = @{
                    Activity            = 'Checking Printer Status'
                    CurrentOperation    = $Printer 
                    PercentComplete     = [math]::Round($CurrentCounter/$AllPrinters.Count * 100, 2)
                    Status              = '{0} of {1}' -f $CurrentCounter, $AllPrinters.Count 
                }
                Write-Progress @ProgSplat
            }
        }

        Get-OMPrinterConfiguration -PrinterName $Printer -Property Enable |
            Where-Object Enable -eq 'n' |
            Select-Object -ExpandProperty Printer
    }

    if ($DisabledPrinters.Count -gt 0 -or $SendEmailEvenIfNoDisabledPrinters) {
        if ($Output -eq 'Email') {
            $SMTPSplat = @{
                To          = $SMTPTo
                From        = $SMTPFrom
                Subject     = $SMTPSubject
                SMTPServer  = $SMTPServer
                Port        = $SMTPPort
            }

            $SMTPSplat['Body'] = @'
    Disabled Printer Count = {0}
    [Disabled Printer List]
    {1}
'@ -f $DisabledPrinters.Count, ($DisabledPrinters -join [System.Environment]::NewLine)
            Send-MailMessage @SMTPSplat
        }
    }
    else {
        Write-Verbose -Message 'No disabled printers found'
    }
}
