function New-OMPlusSampleBulkImportFile {
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$FilePath,

        [parameter(ValueFromPipelineByPropertyName)]
        [char]$Delimiter = ',',

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('TCPPort','LPRPort')]
        [string[]]$PortType = 'TCPPort',

        [parameter()]
        [ValidateSet(
            'Comment',
            'Notes',
            'DoNotValidate',
            'PurgeTime',
            'PageLimit',
            'SupportNotes',
            'WriteTimeout',
            'TranslationTable',
            'DriverType',
            'PCAPPath',
            'UserFilterPath',
            'Filter2',
            'Filter3',
            'CPSMetering',
            'InsertMissingFF',
            'FormType',
            'LFtoCRLF',
            'CopyBreak',
            'FileBreak',
            'Banner',
            'HasInternalWebServer',
            'CustomURL',
            'ForceWebServer'
        )]
        [String[]]$OptionalParameter,

        [parameter()]
        [switch]$IncludeComments
    )

    $CommentsTable = @{
        'PrinterName'           = 'Mandatory parameter; this is used to create the actual printer; spaces are not allowed'
        'IPAddress'             = 'Mandatory parameter; the IP address for the printer, or LPR/LPD print server'
        'PortType'              = 'Mandatory parameter; this indicates if the connection is TCP/IP or LPR/LPD, the correct header column will be output either TCPPort or LPRPort'
        'Comment'               = 'Optional parameter; this is an comment for the printer'
        'Notes'                 = 'Optional parameter; this is a a string for the Notes field'
        'DoNotValidate'         = 'Optional parameter; this indicates the -z should be used so that lpadmin does not verify if the printer is actually up in order to create it'
        'PurgeTime'             = 'Optional parameter; this is the amount of time in seconds before a print job is purged after changing status to prntd or can'
        'PageLimit'             = 'Optional parameter; this is the maximum number of pages per job that can be printed out on this printer'
        'SupportNotes'          = 'Optional parameter; this is an optional parameter for the Support field'
        'WriteTimeout'          = 'Optional parameter; this indicates how long a print job can take to print before being cancelled in seconds'
        'TranslationTable'      = 'Optional parameter; this is for an alternate translation table that needs to be used'
        'DriverType'            = 'Optional parameter; this is supported DriverType for the printer'
        'PCAPPath'              = 'Optional parameter; if this is included, it indicates the file location for a network pcap to be taken for the printer, and that the pcap should be taken'
        'UserFilterPath'        = 'Optional parameter; this is used for a user supplied filter for the print jobs'
        'Filter2'               = 'Optional parameter; this is used for a secondary user supplied filter for the print jobs'
        'Filter3'               = 'Optional parameter; this is used for a tertiary user supplied filter for the print jobs'
        'CPSMetering'           = 'Optional parameter; this provides for a characters per second limit for the printer'
        'InsertMissingFF'       = 'Optional parameter; this inserts a form feed between jobs if it is not already present'
        'FormType'              = 'Optional parameter; this sets the form type for the printer'
        'LFtoCRLF'              = 'Optional parameter; this converts line feeds to Carriage Return/Line Feeds'
        'CopyBreak'             = 'Optional parameter; this inserts a form feed between each copy of a multi-copy print job'
        'FileBreak'             = 'Optional parameter; this inserts a form feed between print job files'
        'Banner'                = 'Optional parameter; this inserts a print banner for each print job'
        'HasInternalWebServer'  = 'Optional parameter; this indicates that the printer has a built in web server; if a CustomURL is not supplied it will attempt to create a URL from http://<ipaddress> or https://<ipaddress> '
        'CustomURL'             = "Optional parameter; this indicates that the printer's web server has a custom URL that needs to be used"
        'ForceWebServer'        = 'Optional parameter; this indicates that the default web server URL needs to be set even if neither http://<ipaddress> nor https://<ipaddress> respond '
    }
    $ParameterSet = New-Object -Type System.Collections.Generic.List[string]
    $ParameterSet.Add('PrinterName')
    $ParameterSet.Add('IPAddress')
    $ParameterSet.Add($PortType)
    if ($OptionalParameter) {
        switch ($OptionalParameter.Count) {
            0       { Write-Verbose -Message 'No optional parameters selected'}
            1       { $ParameterSet.Add($OptionalParameter)}
            default { $ParameterSet.AddRange($OptionalParameter)}
        }
    }

    if ($IncludeComments) {
        $FileOutput = New-Object -Type System.Collections.Specialized.OrderedDictionary
        foreach ($Parameter in $ParameterSet) {
            $FileOutput.Add($Parameter, $CommentsTable.$Parameter)
        }
        $FileOutput | Export-CSV -FilePath $FilePath -Delimiter $Delimiter
    }
    else {
        $ParameterSet -join $Delimiter | Out-File -FilePath $FilePath
    }
}