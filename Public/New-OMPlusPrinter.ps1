function New-OMPlusPrinter {
    <#
    .SYNOPSIS
        Creates printers for OMPlus
    .DESCRIPTION
        Takes a set of parameters and generates a command line string for the OMPlus utility lpadmin.exe
    .EXAMPLE
        PS C:\> $PrintSplat = @{
            IsTesting 				= $true
            PrinterName 			= 'TestPrinter'
            IPAddress 				= '10.0.4.112'
            Port					= 9100
            Comment 				= 'Beaker'
            HasInternalWebServer 	= $true
            ForceWebServer 			= $true
            PurgeTime 				= 45
            PageLimit 				= 5
            Notes 					= 'Test Notes'
            SupportNotes 			= 'Support Notes'
            WriteTimeout 			= 60
            DriverType 				= 'HPUPD5'
            Mode 					= 'termserv'
            FormType 				= 'Letter'
            PCAPPath 				= 'c:\temp\test.pcap'
            CPSMetering 			= 5000
            Banner 					= $true
            FileBreak 				= $true
            CopyBreak 				= $true
            DoNotValidate 			= $true
            LFtoCRLF 				= $true
            InsertMissingFF 		= $true
        }
        PS C:\> New-OMPLusPrinter @PrintSplat
        D:\Plustech\OMPlus\Server\\bin\lpadmin.exe -pTESTPRINTER -v10.0.4.112!9100 -omode="termserv" -opurgetime=45
        -ourl="http://10.0.4.112" -ometering=5000 -oPcap="c:\temp\test.pcap" -opagelimit=5 -onoteinfo="Test Notes" -z
        -owritetime=60 -ocmnt="Beaker" -obanner -oform="Letter" -olfc -onocopybreak -osupport="Support Notes"
        -omode="termserv" -ofilesometimes -onofilebreak -oPTHPUPD5

        This example inputs many different parameters and outputs the intended command line (because we are using
        the IsTesting parameter)
    .INPUTS
        [string]
        [IPAddress]
        [int]
        [switch]
        [bool]
    .OUTPUTS
        [string]
    .NOTES
        This command assembles the command line string for the lpadmin.exe utility.  This is a very complex
        utility with numerous options.  This script simplifies the typing and allows for an easier
        bulk creation of printers.

        It creates the mandatory parameters in a collection, and then it adds the other subsequent parameters
        as supplied by the user.   The string is then output and the lpadmin.exe command line is either displayed
        or executed.

        This script was built referencing the OMPlus Delivery Manager PDF from PlusTechnologies
    .PARAMETER PrinterName
        This is the name of the printer to create
    .PARAMETER IPAddress
        This is the ip address of the printer that will be created.  The script was built around IPv4, but
        there is nothing in the script to prevent it from using IPv6 (if lpadmin.exe supports it)
    .PARAMETER Port
        This is the TCP Port to use for printing on the newly created printer.
        It defaults to standard TCP/IP printing on port 9100
    .PARAMETER LPRPort
        This is the queue name used for LPR/LPD printers
    .PARAMETER Comment
        This is the optional comment for the printer.  This version of the script is configured for
        standard comments for Harris Health Systems.
    .PARAMETER HasInternalWebServer
        This is used to flag the printer as having a supporting web page.
        If a CustomURL is not supplied, the script will test for port 80 (http://<ipaddress>) and if that fails,
        it will attempt port 443 (https://<ipaddress>), and if that fails, a warning is written and nothing is added for it.
        However, if ForceWebServer is specified, it will add it as http even though the port is not
        responding when the script is run.
    .PARAMETER CustomURL
        If the HasInternalWebServer switch is used, and this parameter is provided, this will be inserted as
        the URL to use for accessing the print server.  No validation is done against this CustomURL
    .PARAMETER ForceWebServer
        If the HasInternalWebServer switch is used and the print server is down/not responding, and this switch
        is used, the printer will be configured with a URL of http://<ipaddress> despite failing validation.
    .PARAMETER PurgeTime
        This is the length of time a document is held before being purged.
        This is specified in seconds.
    .PARAMETER PageLimit
        Specified the maximum number of pages that will be printed in a single job
    .PARAMETER Notes
        Adds text notes to the printer in the supported Notes field. If the value supplied to this parameter contains
        double quotes ("), they are stripped out automatically to prevent command line issues.
    .PARAMETER SupportNotes
        Adds text notes to the printer in the supported SupportNotes field. If the value supplied to this parameter contains
        double quotes ("), they are stripped out automatically to prevent command line issues.
    .PARAMETER WriteTimeout
        Sets the amount of time that a print job must complete in before it is terminated
    .PARAMETER TranslationTable
        Sets a different translation table for the print jobs
    .PARAMETER DriverType
        Selects the correct type of driver for the printer.  The list of drivers can be obtained using the
        Get-OMPlusDriverNames function.  This script was written for Powershell 4.  Future versions will
        use ArgumentCompleters to pre-supply the available driver names.
    .PARAMETER Mode
        Selects the correct print mode for the printer. Most printers use the default value of 'termserv'
        The complete list is:
        'pipe','windows','termserv','netprint','ipp','telnet','alttelnet',
        'ftp','web','pager','fax','email','system','omplus','lpplus','directory',
        'reptdist','ecivprinter','Virtual','scsi','parallel','serial'
    .PARAMETER FormType
        Sets the printer to use a specific pre-defined form type.
    .PARAMETER PCAPPath
        If this is used, it defines the path where the PCAP capture will be outputted.
        This is primarily a troubleshooting function.
    .PARAMETER UserFilterPath
        Provides a path to a user-defined filter
    .PARAMETER Filter2
        Provides a path to a second user-defined filter
    .PARAMETER Filter3
        Provides a path to a third user-defined filter
    .PARAMETER CPSMetering
        Sets the maximum number of characters per second the printer will accept.
        Primarily for dot-matrix and band printers
    .PARAMETER Banner
        If this parameter is used with $true, a banner page is inserted
        If this parameter is used with $false, banner pages are turned off
    .PARAMETER DoNotValidate
        Turns on the -z switch so that OMPlus does not try to validate the existence of the printer
        before creating it.
        This is primarily for use with bulk creation of printers.
    .PARAMETER LFtoCRLF
        If this parameter is used with $true, LineFeeds are converted to Carriage Return/LineFeed characters
        If this parameter is used with $false, the conversion of LineFeed to Carriage Return/LineFeed is explicitly turned off
    .PARAMETER CopyBreak
        If this parameter is used with $true, a form feed is output between copies of a print job
        If this parameter is used with $false, form feeds between copies of a print job are explicitly turned off
    .PARAMETER FileBreak
        If this parameter is used with $true, a form feed is output between print jobs
        If this parameter is used with $false, form feeds between print jobs are explicitly turned off
    .PARAMETER InsertMissingFF
        Inserts a form feed at the end of a file if there is not one there already
    .PARAMETER IsTesting
        Used to test the output of the script.  It will generate the command line and output it, but not
        actually execute it.
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$PrinterName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [IPAddress]$IPAddress,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(0,65535)]
        [int]$TCPPort = 9100,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$LPRPort,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Comment,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$HasInternalWebServer,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$CustomURL,

        [parameter(ValueFromPipelineByPropertyName)]
        [switch]$ForceWebServer,

        [parameter(ValueFromPipelineByPropertyName)]
        [int]$PurgeTime,

        [parameter(ValueFromPipelineByPropertyName)]
        [int]$PageLimit,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Notes,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$SupportNotes,

        [parameter(ValueFromPipelineByPropertyName)]
        [int]$WriteTimeout,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$TranslationTable,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('DellOPDPCL5','HPUPD5','HPUPD6','LexUPDv2','LexUPDv2PS3','LexUPDv2XL','RICOHPCL6','XeroxUPDPCL6','XeroxUPDPS')]
        [string]$DriverType,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('pipe','windows','termserv','netprint','ipp','telnet','alttelnet',
                     'ftp','web','pager','fax','email','system','omplus','lpplus','directory',
                     'reptdist','ecivprinter','Virtual','scsi','parallel','serial')]
        [string]$Mode = 'termserv',

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$FormType,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$PCAPPath,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -path $_ })]
        [string]$UserFilterPath,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -path $_ })]
        [string]$Filter2,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -path $_ })]
        [string]$Filter3,

        [parameter(ValueFromPipelineByPropertyName)]
        [int]$CPSMetering,

        [parameter(ValueFromPipelineByPropertyName)]
        [bool]$Banner,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('z')]
        [switch]$DoNotValidate,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('lfc')]
        [bool]$LFtoCRLF,

        [parameter(ValueFromPipelineByPropertyName)]
        [bool]$CopyBreak,

        [parameter(ValueFromPipelineByPropertyName)]
        [bool]$FileBreak,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('filesometimes')]
        [switch]$InsertMissingFF,

        [parameter()]
        [switch]$IsTesting,

        [parameter()]
        [switch]$IsFullTesting
    )

    Begin {
        if ($IsFullTesting) { $PSBoundParameters }

        $PrinterName = $PrinterName.ToUpper().Replace(' ', '-')
        $ValidTypes = Get-OMPLusDriverNames

        if ($DriverType) {
            if ($DriverType -in $ValidTypes) {
                $Message = 'DriverType "{0}" is a valid type' -f $DriverType
                Write-Verbose -Message $Message
            }
            else {
                $Message = 'DriverType "{0}" is not a valid type.{1}ValidTypes are:{2}' -f $DriverType, $CRLF,($ValidTypes -join $CRLF)
                throw $Message
            }
        }

        if ($Notes) {
            if ($Notes.Contains('"')) {
                $Notes = $Notes.Replace('"', ",")
                Write-Warning -Message 'The Notes parameter contains a double-quote, replacing it with a single quote'
            }
        }
        if ($SupportNotes) {
            if ($SupportNotes.Contains('"')) {
                $SupportNotes = $SupportNotes.Replace('"', ",")
                Write-Warning -Message 'The SupportNotes parameter contains a double-quote, replacing it with a single quote'
            }
        }
        if ($Comment) {
            if ($Comment.Contains('"')) {
                $Comment = $Comment.Replace('"', ",")
                Write-Warning -Message 'The Comment parameter contains a double-quote, replacing it with a single quote'
            }
        }
        if ($PCAPPath) {
            if ($PCAPPath.Contains('"')) {
                $PCAPPath = $PCAPPath.Replace('"', '')
                Write-Warning -Message 'The PCAPPath parameter contains a double-quote, stripping it out so that we do not have two sets of double quotes'
            }
        }
    }

    process {

        Write-Verbose -Message 'Begin building command line string for lpadmin'
        $ArgString = New-Object -TypeName System.Collections.Generic.List[string]
        $null = $ArgString.Add( ('-p{0}' -f $PrinterName) )
        if ($PSBoundParameters -Contains 'LPRPort') {
            $null = $ArgString.Add( ('-v{0}!{1}' -f $ipaddress, $Port) )
        }
        else {
            $null = $ArgString.Add( ('-v{0}!{1}' -f $IPAddress, $LPRPort))
        }

        $null = $ArgString.Add( ('-omode="{0}"' -f $Mode))

        foreach ($Parameter in $PSBoundParameters.Keys) {
            switch ($Parameter) {
                'Comment'           { $null = $ArgString.Add( ('-ocmnt="{0}"' -f $Comment) );                   break}
                'Notes'             { $null = $ArgString.Add( ('-onoteinfo="{0}"' -f $Notes));                  break}
                'DoNotValidate'     { $null = $ArgString.Add(  '-z') ;                                          break}
                'PurgeTime'         { $null = $ArgString.Add( ('-opurgetime={0}' -f $PurgeTime.ToString()));    break}
                'PageLimit'         { $null = $ArgString.add( ('-opagelimit={0}' -f $PageLimit.ToString()));    break}
                'SupportNotes'      { $null = $ArgString.Add( ('-osupport="{0}"' -f $SupportNotes));            break}
                'WriteTimeout'      { $null = $ArgString.add( ('-owritetime={0}' -f $WriteTimeout.ToString())); break}
                'TranslationTable'  { $null = $ArgString.Add( ('-otrantable="{0}"' -f $TranslationTable));      break}
                'DriverType'        { $null = $ArgString.Add(  '-oPT{0}' -f $DriverType);                       break}
                'PCAPPath'          { $null = $ArgString.Add( ('-oPcap="{0}"' -f $PCAPPath));                   break}
                'UserFilterPath'    { $null = $ArgString.Add( ('-ousrfilter="{0}"' -f $UserFilterPath));        break}
                'Filter2'           { $null = $ArgString.add( ('-ofilter2="{0}"' -f $Filter2));                 break}
                'Filter3'           { $null = $ArgString.add( ('-ofilter3="{0}"' -f $Filter3));                 break}
                'CPSMetering'       { $null = $ArgString.Add( ('-ometering={0}' -f $CPSMetering.ToString()));   break}
                'InsertMissingFF'   { $null = $ArgString.add(  '-ofilesometimes');                              break}
                'FormType'          { $null = $ArgString.add( ('-oform="{0}"' -f $FormType));                   break}
                'LFtoCRLF'          {
                    switch ($LFtoCRLF) {
                        $true   { $null = $ArgString.Add('-olfc')}
                        $false  { $null = $ArgString.Add('-nolfc')}
                    }
                    break
                }
                'CopyBreak'         {
                    switch ($CopyBreak) {
                        $true   { $null = $ArgString.Add('-onocopybreak') }
                        $false  { $null = $ArgString.Add('-ocopybreak')}
                    }
                    break
                }
                'FileBreak'         {
                    switch ($FileBreak) {
                        $true   { $null = $ArgString.Add('-onofilebreak') }
                        $false  { $null = $ArgString.Add('-ofilebreak')}
                    }
                    break
                }
                'Banner'     {
                    switch ($Banner) {
                        $true   { $null = $ArgString.Add('-obanner')}
                        $false  { $null = $ArgString.Add('-onobanner')}
                    }
                    break
                }
                'HasInternalWebServer'  {
                    if ($CustomURL) {
                        $null = $ArgString.Add( '-ourl="{0}"' -f $CustomURL)
                    }
                    elseif ($DoNotValidate) {
                        $Message = 'Adding a http URL address for the webserver, since DoNotValidate was set'
                        Write-Warning -Message $Message
                        $null = $ArgString.Add( ('-ourl="http://{1}"' -f $ipaddress) )
                    }
                    else {
                        if (Test-Port -ComputerName $ipaddress -TCPPort 80 -TimeoutInMs 1000) {
                            Write-Verbose -Message 'Found http port, adding URL'
                            $null = $ArgString.Add( ('-ourl="http://{0}"' -f $ipaddress) )
                        }
                        elseif (Test-Port -ComputerName $ipaddress -TCPPort 443 -TimeoutInMs 1000) {
                            Write-Verbose -Message 'Found https port, adding URL'
                            $null = $ArgString.Add( ('-ourl="https://{1}"' -f $ipaddress) )
                        }
                        elseif ($ForceWebServer) {
                            $Message = 'Forcing a http URL address for the webserver, currently it appears to be offline'
                            Write-Warning -Message $Message
                            $null = $ArgString.Add( ('-ourl="http://{1}"' -f $ipaddress) )
                        }
                        else {
                            $Message = 'Unable to locate a webserver on port 80 or 443 for {0}, not setting this parameter' -f $PrinterName
                            Write-Warning -Message $Message
                        }
                    }
                    break
                }
            }
        }
    }

    end {
        $LPAdmin = [system.io.path]::combine( (Get-ItemProperty -Path HKLM:\SOFTWARE\PlusTechnologies\OMPlusServer -Name omhomepath).omhomepath, 'bin','lpadmin.exe' )
        if ($IsTesting -or $IsFullTesting) {
            '{0} {1}' -f $LPAdmin, ($ArgString -join ' ')
        }
        else {
            $ProcSplat = @{
                FilePath        = $LPAdmin
                ArgumentList    = $ArgString -join ' '
                Wait            = $true
                WindowStyle     = 'Hidden'
            }
            Write-Verbose -Message ('Creating printer: {0}' -f $PrinterName)
            Start-Process @ProcSplat -Verb RunAs
        }
    }
}

