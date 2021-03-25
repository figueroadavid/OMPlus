# OMPlus Delivery Manager

![OMPlusLogo](https://www.plustechnologies.com/wp-content/uploads/2015/01/logo-plustechnologies.png)

Wrapper module for [OMPlus for Windows](https://www.plustechnologies.com)

The module is written to provide a powershell friendly wrapper for the various binary utilities for OMplus on Windows.
Here are the base functions provided

<table class="nobordertable">
    <tr>
        <td> <a href="#connect-omprinterurl">Connect-OMPrinterURL</a> </td>
        <td> <a href="#new-OMbulkimport">New-OMBulkImport</a> </td>
        <td> <a href="#remove-OMprintjob">Remove-OMPrintJob</a> </td>
    </tr>
    <tr>
        <td> <a href="#disable-OMprinter">Disable-OMPrinter</a> </td>
        <td> <a href="#new-OMEPRRecord">New-OMEPRRecord</a> </td>
        <td> <a href="#remove-omsecondaryeprrecord">Remove-OMSecondaryMPSPrinter</a> </td>
    </tr>
    <tr>
        <td>  <a href="#enable-OMprinter">Enable-OMPrinter</a> </td>
        <td> <a href="#new-OMprinter">New-OMPrinter</a> </td>
        <td> <a href="#Set-OMPrinter">Set-OMPrinter</a> </td>
    </tr>
    <tr>
        <td> <a href="#get-OMdrivernames">Get-OMDriverNames</a> </td>
        <td> <a href="#new-OMsamplebulkimportfile">New-OMSampleBulkImportFile</a> </td>
        <td> <a href="#sync-omsecondaryprinters">Sync-OMSecondaryPrinters</a> </td>
    </tr>
    <tr>
        <td> <a href="#get-omjobcountbystatus">Get-OMJobCountByStatus</a> </td>
        <td> <a href="#remove-omeperrecord">Remove-OMEPRRecord</a> </td>
        <td> <a href="#test-port">Test-Port</a> </td>
    </tr>
    <tr>
        <td> <a href="#get-OMprinterconfiguration">Get-OMPrinterConfiguration</a> </td>
        <td> <a href="#Remove-OMPrinter">Remove-OMPrinter</a> </td>
        <td> <a href="#update-omtransformserver">Update-OMTransformServer</a> </td>
    </tr>
    <tr>
        <td><a href="#get-OMprinterlist">Get-OMPrinterList</a> </td>
        <td></td>
        <td></td>
    <td>
</table>

## Functions

### `Connect-OMPrinterURL`

Reads in the printer configuration, and if possible, launches the default browser to connect to the defined status URL for the printers
##### _Parameters_


| Parameter Name                | Description   |
| :-------------                | :-----------  |
| `PrinterName`  			    | This is the list of printers from which the system will open their status web pages |
| `DelayBetweenPrintersInMS `  | This is the amount of delay between launching the printer web pages.  This gives the browser some time to establish the connection, without becoming overwhelmed |
| `SafetyThreshold`	        | This is the maximum number of pages the function will attempt to open.  This is a safety measure to prevent the browser and the system from being overwhelmed with requests to open web pages. |

[Jump to Top :arrow_up:](#)

___


### `Disable-OMPrinter`

Disables a printer in OMPlus

##### _Parameters_

| Parameter Name | Description |
| :-------------- | :---------- |
| `PrinterName`| Accepts 1 or more printer names to disnable; if a printer does not exist, then a warning is written, and the printer is skipped |
| `ShowProgress`| Writes a progress bar to show the progress of the cmdlet; this is useful when enabling a large number of printers |

##### _Example_

```powershell
PS C:> Disable-OMPrinter -PrinterName Printer01,Printer02,Printer03
WARNING: Printer: Printer03 is not a valid printer for this system; skipping
```
[Jump to Top :arrow_up:](#)

___

### `Enable-OMPrinter`

Enables a previously disabled printer in OMPlus.

##### _Parameters_

| Parameter Name | Description |
| :-------------- | :---------- |
| `PrinterName`| Accepts 1 or more printer names to enable; if a printer does not exist, then a warning is written, and the printer is skipped |
| `ShowProgress`| Writes a progress bar to show the progress of the cmdlet; this is useful when enabling a large number of printers |



##### _Example_

```powershell
PS C:\> Enable-OMPrinter -PrinterName PRINTER01, PRINTER02, PRINTER03
WARNING: Printer: PRINTER03 is not a valid printer for this system; skipping
```

[Jump to Top :arrow_up:](#)

___

### `Get-OMDriverNames`

Reads and returns the list of driver names from the `types.conf` file in OMPlus

##### _Example_

```powershell
PS C:\> Get-OMDriverNames
Driver                             Display
------                             -------
ZDesignerAM400                     ZDesigner ZM400 200 dpi (ZPL)
HPUPD6                             HP Universal Printing PCL 6
LexUPDv2                           Lexmark Universal v2
DellOPDPCL5                        Dell Open Print Driver (PCL 5)
RICOHPCL6                          RICOH PCL6 UniversalDriver V4.14
HPUPD5                             HP Universal Printing PCL 5
Zebra2.5x4                         ZDesigner ZM400 200 dpi (ZPL)
LexUPDv2PS3                        Lexmark Universal v2 PS3
LexUPDv2XL                         Lexmark Universal v2 XL
XeroxUPDPS                         Xerox Global Print Driver PS
XeroxUPDPCL6                       Xerox Global Print Driver PCL6
```

[Jump to Top :arrow_up:](#)

___

### `Get-OMJobCountByStatus`

Retrieves the count of jobs in a given status; the statuses are returned in a hashtable format

##### _Parameters_

| Parameter Name | Description |
| :-------------- | :---------- |
| `PrinterName`| Accepts 1 or more printer names from which to retrieve the configuration |
| `Property`| Accepts a list of 1 or more property names to return in the PSCustomObject |

##### _Example_

```powershell
PS C:\> help Get-OMJobCountByStatus -ShowWindow

PS C:\> Get-OMJobCountByStatus -Status all

Name                           Value
----                           -----
2dumb                          0
malid                          0
xfer                           0
susp                           0
cmplt                          0
partl                          0
spool                          0
proc                           0
prntd                          102
can                            0
fpend                          0
2big                           0
Change Password                0
intrd                          0
ready                          14
faild                          0
held                           0
sent                           0
faxed                          0
timed                          0
active                         0

PS C:\> Get-OMJobCountByStatus -Status prntd,ready
Name                           Value
----                           -----
ready                          17
prntd                          133
```

[Jump to Top :arrow_up:](#)

___


### `Get-OMPrinterConfiguration`

Reads the configuration of a printer in OMPlus and returns the contents of the configuration file as a PSCustomObject

##### _Parameters_

| Parameter Name | Description |
| :-------------- | :---------- |
| `PrinterName`| Accepts 1 or more printer names from which to retrieve the configuration |
| `Property`| Accepts a list of 1 or more property names to return in the PSCustomObject |

##### _Example_

```powershell
PS C:\> Get-OMPrinterConfiguration -PrinterName Printer01
Printer          : Printer01
Mode             : termserv
Device           : 10.0.0.1!9100
Stty             : none
Filter           : dcctmserv
User_Filter      : none
Def_form         : stock
Form             : stock
Accept           : y
Accepttime       : 001443446160
Acceptreason     : New Printer
Enable           : y
Enabletime       : 001445452018
Enablereason     : Unknown
Metering         : 0
Model            : omstandard.js
Filebreak        : n
Copybreak        : n
Banner           : n
Lf_crlf          : y
Close_delay      : 10
Writetime        : 5399
Opentime         : 180
Purgetime        : 100
Draintime        : 5399
Terminfo         : dumb
Pcap             : none
URL              : http://10.0.0.1
CMD1             : none
Comments         : none
Support          : none
Xtable           : standard
Notify_flag      : 0
Notify_info      : none
Two_way_protocol : none
Two_way_address  : none
Alt_dest         : none
Sw_dest          : none
Page_limit       : 0
Data_types       : all
FO               : n
HD               : n
PG               : y
LG               : 0
DC               : default
CP               : y
RT               : 30
EM               : none
PT               : none
PD               : n
```

[Jump to Top :arrow_up:](#)

___


### `Get-OMPrinterList`

Gets and returns the list of printers in OMPlus

##### _Example_

| Parameter Name  | Description |
| :-------------- | :---------- |
| `Filter`| This is passed to Get-ChildItem as a _filter_; this follows the old `DOS` conventions for wildcards |

##### _Example_

```powershell
PS C:\> Get-OMPrinterList
Printer01
Printer02
Printer03
Printer04
MyPrint01
MyPrint02
MyPrint03
MyPrint04

PS C:\> Get-OMPrinterList -Filter My*
MyPrint01
MyPrint02
MyPrint03
MyPrint04

```

[Jump to Top :arrow_up:](#)

___


### `New-OMBulkImport`

Reads in a CSV file of printers and feeds them into the New-OMPrinter function to create new OMPlus printers
##### _Parameters_

| Parameter Name  | Description |
| :-------------- | :---------- |
| `FilePath`| The path to the CSV file to read in |
| `Delimter`| The character used to separate the fields, it defaults to a commma |

##### _Example_

```powershell
PS C:\> New-OMBulkImport -FilePath c:\temp\omplusimport.csv -delimiter '|'
```

[Jump to Top :arrow_up:](#)

___


### `New-OMEPRRecord`

This creates a correctly formatted Epic Print Record for the `eps_map` file.
Depending on the version of Powershell used (> 5), the parameter names will provide tab-completion assistance.

##### _Parameters_

| Parameter Name | Description |
| :-------------- | :---------- |
| `ServerName` | The name of the server that will host the EPR Record; defaults to the current machine; Having the correct servername isn't *critical* per-se; the OMPlus system will automatically update the record |
| `EPRQueueName` | The name of the EPR Queue Name for the Record; there can be multiple EPRQueueNames per OMPlusQueueName |
| `OMQueueName` | The queue/destination name in OMPlus |
| `DriverName` | The name of the driver used in the system; this name _is **case-sensitive**_; this name comes from the _Types_ list in the OMPlus Administration tool |
| `TrayName` | This is the name of the tray to use.  It must match the trays available in the `types.conf`. |
| `DuplexOption` | This is the Duplex option setting in the _Epic Print Record_ tool; it comes from the `types.conf` file; it can be _None_ (which is blank), _Simplex_, _Horizontal_ (Short Edge), or _Vertical_ (Long Edge) |
| `PaperSize` | This is the size of the paper; it also comes from the `types.conf` file |
| `IsRx` | Sets the flag if the EPR is designated for prescriptions, it defaults to 'n'; which is unchecked in the EPR tool |
| `MediaType` | Determines which media type the printer is using.  It defaults to 'none' |
| `Append` | This tells the function to end the EPR record to the end of the `eps_map` file and calls the `Update-OMTransformServer` function to notify the Transform servers of the change(s) |

##### _Example_

```powershell
PS C:\> $EPRSplat = @{
    ServerName      = 'vprtmps01a.hchd.local'
    EPRQueueName    = 'FP-251-251'
    OMPLusQueueName = 'FP-251-251'
    DriverName      = 'DellOPDPCL5'
    TrayName        = 'Tray 1'
    DuplexOption    = 'Horizontal'
    PaperSize       = 'Letter'
    IsRX            = 'y'
}
PS C:\> New-OMEPRRecord @EPRSplat
vprtmps01a.hchd.local|FP-251-251|FP-251-251|DellOPDPCL5|!259|Horizontal|!1|y|

PS C:\> New-OMEPRRecord @EPRSplat -Append
```

[Jump to Top :arrow_up:](#)

___


### `New-OMPrinter`

Creates a new OMPlus printer

##### _Parameters_

| Parameter Name | Description |
| :-------------- | :---------- |
|`-PrinterName` | The name of the printer to create|
|`-IPAddress` | The IP address of the printer; `lpadmin.exe` does not require an IP address depending on the printer type, but the vast majority of printers managed by OMPlus are on the network and do need IP Addresses.  The script validates the number is in the range of `0-65535`|
|`-TCPPort` | The TCP port used for the printer; it defaults to `9100`|
|`-LPRPort` | The name of the LPD/LPR queue; if this is used the script will replace the TCPPort with the LPRPort queue name|
|`-Comment` | This supplies the comment (`-ocmt`) parameter;|
|`-HasInternalWebServer` | This sets the _`Has Internal Web Server`_ flag for the printer; if _`CustomURL`_ is not supplied, the script tests for a web page on port `80`(`http`), and then on port `443`(`https`) if `80` does not respond; (`-ourl`)|
|`-CustomURL` | This is used with the _HasInternalWebServer_ to set the -ourl parameter, and must be used if the web page is not accessed by the IP address on a standard `http`(`80`) or `https`(`443`) port|
|`-ForceWebServer` | Used in combination with _HasInternalWebServer_ to set the `-ourl` port without verifying that the URL responds (http, https, custom)|
|`-PurgeTime` | Overrides the default purge time from the system for the printer; this value is in seconds (`-opurgetime`)|
|`-PageLimit` | Overrides the default page limit from the system for the printer (`-opagelimit`)|
|`-Notes` | This supplies the the Notes field (`-onoteinfo`)|
|`-SupportNotes` | Supplies the Support Notes field (`-osupport`)|
|`-WriteTimeout` | Overrides the default timeout value for print jobs for this printer (`-owritetimeout`)|
|`-TranslationTable` | Overrides the default translation table for the system for this printer (`-otrantrable`)|
|`-DriverType` | Sets the correct driver type; this script was written for Powershell 4; the administrator needs to first get the correct driver types to set the list for `[ValidateSet()]`; however, future versions will automatically prepopulate this list with ArgumentCompleters (`-oPT`)|
|`-Mode = 'termserv'` | Defaults to `termserv`; `LPRPort` is also supplied, this is changed to 'netprint' (`-omode`)|
|`-FormType` | Overrides the default form type for the printer (`-oform`)|
|`-PCAPPath` | Enables the PCAP capture for the printer, and sets the file path for the capture file (`-oPcap`)|
|`-UserFilterPath` | Sets a user defined filter script for print jobs (`-ousrfilter`); the file must exist on the system|
|`-Filter2` | Sets a secondary user defined filter script for print jobs (`-ofilter2`); the file must exist on the system|
|`-Filter3` | Sets a secondary user defined filter script for print jobs (`-ofilter3`); the file must exist on the system|
|`-CPSMetering` | Overrides the default characters per second metering for printer (`-ometering`)|
|`-Banner` | If used, and set to \$true, then `-obanner` is used and banner pages are injected between print jobs, if set to $false, then `-onobanner` is used|
|`-DoNotValidate` | Sets the -z flag so that lpadmin does not try to verify the printer's existence|
|`-LFtoCRLF` | If used, and set to \$true, then `-olfc` is used and LF characters are converted to CRLF characters, if set to $false, then `-onolfc` is used|
|`-CopyBreak` | If used, and set to \$true, then `-ocopybreak` is used and page breaks are inserted between print jobs, and if set to $false `-onocopybreak` is used, and page breaks are removed from between print jobs|
|`-FileBreak` | If used, and set to \$true, then `-ofilebreak` is used and page breaks are inserted between files submitted, and if set to $false, then `-onofilebreak` is used and page breaks between files are removed|
|`-InsertMissingFF` | If used, then if form feeds are missing between jobs, then they are inserted (`-ofilesometimes`)|
|`-IsTesting` | if used, displays the generated command line without actually creating the printer|
|`-IsFullTesting` | if used, displays all the supplied parameters, and then displays the generated command line|
|`-IsForEpic` | if used, it _sanitizes_ the record to match Epic standards - letters are converted to upper case, and spaces are replaced with hypens|

##### _Example_

```powershell
PS C:\> $PrintSplat = @{
        IsTesting 		= $true
        PrinterName 		= 'TestPrinter'
        IPAddress 		= '10.0.4.112'
        Port			= 9100
        Comment 		= 'Beaker'
        HasInternalWebServer 	= $true
        ForceWebServer 		= $true
        PurgeTime 		= 45
        PageLimit 		= 5
        Notes 			= 'Test Notes'
        SupportNotes 		= 'Support Notes'
        WriteTimeout 		= 60
        DriverType 		= 'HPUPD5'
        Mode 			= 'termserv'
        FormType 		= 'Letter'
        PCAPPath 		= 'c:\temp\test.pcap'
        CPSMetering 		= 5000
        Banner 			= $true
        FileBreak 		= $true
        CopyBreak 		= $true
        DoNotValidate 		= $true
        LFtoCRLF 		= $true
        InsertMissingFF 	= $true
}
PS C:\> New-OMPrinter @PrintSplat -IsTesting
C:\Plustech\OMPlus\Server\bin\lpadmin.exe -pTESTPRINTER -v10.0.4.112!9100 -omode="termserv" -opurgetime=45
-ourl="http://10.0.4.112" -ometering=5000 -oPcap="c:\temp\test.pcap" -opagelimit=5 -onoteinfo="Test Notes" -z
-owritetime=60 -ocmnt="Beaker" -obanner -oform="Letter" -olfc -onocopybreak -osupport="Support Notes"
-omode="termserv" -ofilesometimes -onofilebreak -oPTHPUPD5

PS C:\> New-OMPrinter @PrintSplat -Verbose
Creating printer: TESTPRINTER

```

[Jump to Top :arrow_up:](#)

___


### `New-OMSampleBulkImportFile`

This creates a sample csv file that is appropriate to import into `New-OMBulkImport`

##### _Parameters_

| Parameter Name| Description |
| :-- | :-- |
| `FilePath` | The output path for the sample file |
| `Delimiter` | A single character delimiter for the output file; it defaults to a comma (`,`) |
| `PortType` | Defaults to `TCPPort`, the other option is `LPRPort` |
| `IncludeComments` | This adds a series of comments for the optional _Parameters_ giving explanations to those _Parameters_ |
| `OptionalParameter` | A list of the available optional_Parameters_ to include in the output file; |

| Options                |                  |                   |                    |
| :------                | ----             | ----              | ----               |
| `HasInternalWebServer` | `Comment`        | `PCAPpath`        | `FileBreak`        |
| `CustomURL`            | `Notes`          | `CPSMetering`     | `Banner`           |
| `ForceWebServer`       | `SupportNotes`   | `InsertMissingFF` | `WriteTimeout`     |
| `DriverType`           | `UserFilterPath` | `FormType`        | `TranslationTable` |
| `DoNotValidate`        | `Filter2`        | `LFtoCRLF`        | `PageLimit`        |
| `PurgeTime`            | `Filter3`        | `CopyBreak`       | `IsTesting`        |

##### _Example_

```powershell
PS C:\> @SampleSplat = @{
       FilePath             = 'c:\temp\OmplusSample.csv'
       PortType             = 'TCPPort'
       OptionalParameter    = 'HasInternalWebServer','ForceWebServer','DriverType','DoNotValidate','Comment','IsTesting'
       IncludeComments      = $true
}
PS C:\> New-OMSampleBulkImportFile @SampleSplat

#Contents of the file
"PrinterName","IPAddress","TCPPort","HasInternalWebServer","ForceWebServer","DriverType","DoNotValidate","Comment","IsTesting"
"Mandatory parameter; Name used to create the actual printer; spaces are not allowed","Mandatory parameter; IP address for the printer, or LPR/LPD print server","Mandatory parameter: The TCP port used for network communication, between 0 and 65535; the default is 9100","Optional parameter; Indicates that the printer has a built in web server; if a CustomURL is not supplied it will attempt to create a URL from http://<ipaddress> or https://<ipaddress> ","Optional parameter; Indicates that te default web server URL needs to be set even if neither http://<ipaddress> nor https://<ipaddress> respond ","Optional parameter; The DriverType for the printer; must be one of the supported ones from the system","Optional parameter; Tells lpadmin not to verify the printer before creating it (-z)","Optional parameter; Comment for the printer","Optional parameter; Causes the script to return the generated command line rather than execute it"

PS C:\> @SampleSplat = @{
       FilePath             = 'c:\temp\OmplusSample.csv'
       PortType             = 'TCPPort'
       OptionalParameter    = 'HasInternalWebServer','ForceWebServer','DriverType','DoNotValidate','Comment','IsTesting'
       IncludeComments      = $false
}

PS C:\> New-OMSampleBulkImportFile @SampleSplat

#Contents of the file
PrinterName,IPAddress,TCPPort,HasInternalWebServer,ForceWebServer,DriverType,DoNotValidate,Comment,IsTesting
```

[Jump to Top :arrow_up:](#)

___

### `Remove-OMEPRRecord`
This removes EPR Records from the `eps_map` file, and notifies the Transform servers of the record removal
This is an especially risky function, and has multiple built in safety precautions.
The first step it takes is to create a backup of the `eps_map` file, with a naming convention of: `eps_map_datetime.bkp`
The datetime syntax used is `yyMMdd_hhmmss`; so the current name as of this writing would be `eps_map_210322_111908.bkp`

##### _Parameters_

| Parameter Name              | Description |
| :-------------------------------------------              | :---------- |
| `MatchField`              | The name of the field used to determine which records to select for deleting. It is predefined as `EPR Record`, `Queue`, `EPS Base`, `Tray`, `Simplex/Duplex`, `Paper Size`, `RX`, `Media Type`|
| `MatchType`               | This determines if the match should be a _simple match_ or a _regular expressions_ match; it defaults to _simple_|
| `MatchPattern`            | This is the text string to define the matching pattern used by the `MatchType` |
| `ReallyDoIt`              | This tells the function that you really do intend to make this change; this is one of the important safety switches |
| `ThreshholdPercent`       | By default, this is set to 1 (percent), if the function will remove more than this percentage of the records, it will error out and not perform the function; this is another critical safety switch to this function |
| `OverrideThreshold`       | This switch tells the function to ignore the `ThreshholdPercent` switch; this is a very dangerous switch, and must be used with extreme caution |

##### _Example_

```powershell
PS C:\> $RemoveSplat = @{
    MatchField      = 'EPR Record'
    MatchType       = 'Simple'
    MatchPattern    = 'PRINTER-0*'
}
PS C:\> Remove-OMEPRRecord @RemoveSplat -Verbose
The new eps_map will contain 6399 records; the old eps_map contains 6395 records
These records will be removed:
PRINTER01
PRINTER02
PRINTER03
PRINTER04
ReallyDoIt switch not specified, not updating the file

PS C:\> Remove-OMEPRRecord @RemoveSplat -Verbose -ReallyDoIt
The new eps_map will contain 6399 records; the old eps_map contains 6395 records
These records will be removed:
PRINTER01
PRINTER02
PRINTER03
PRINTER04
WARNING: eps_map being updated

PS C:\> $RemoveSplat = @{
    MatchField      = 'EPR Record'
    MatchType       = 'Simple'
    MatchPattern    = '*PR*'
}
PS C:\> Remove-OMEPRRecord @RemoveSplat -ReallyDoIt -Verbose
The new eps_map will contain 2390 records; the old eps_map contains 6395 records
These records will be removed:
PRINTER01
PRINTER02
PRINTER03
PRINTER04
MYPRINTER01
....
ZZPRINTER50

This action will remove more than 1% of the records from eps_map

```

___

### `Remove-OMPrinter`

This uses `lpadmin.exe` to delete the given printers by name; when the printers are deleted the function throws up a warning to remind the administrator to remove the OMPlus EPR Record for the printer.

##### _Parameters_

| Parameter Name | Description |
| -- | -- |
| `PrinterName` | The list of printers to remove |

##### _Example_

```powershell
PS C:\> Get-OMPrinterList -Filter Office1Prt_* | ForEach-Object { Remove-OMPrinter -PrinterName $_ }
WARNING: Do not forget to Remove the EPR Record for Office1Prt_001
WARNING: Do not forget to Remove the EPR Record for Office1Prt_002
WARNING: Do not forget to Remove the EPR Record for Office1Prt_003
WARNING: Do not forget to Remove the EPR Record for Office1Prt_004
```

[Jump to Top :arrow_up:](#)

___

### `Remove-OMPrintJob`

This function deletes print jobs that exists in the system. It has 4 modes of operation:

1. By RID number: Deletes the job with the job number  (uses `dcccancel.exe`)
2. By Age: Deletes all print jobs older than the specified time in minutes (uses `dccgrp.exe`)
3. By Printer: Resets the printer, thereby deleting the print jobs going to that printer (uses `dccreset.exe`)
4. By Status: Cancels all jobs with the given status (uses `dccgrp.exe`)

##### _Parameters_

| Parameter Name | Description |
| :-- | :-- |
| `RIDNumber` | [by RID number] The RIDNumber(s) of the print jobs to delete |
| `ImmediatePurge` | [by RID number] adds the flag to automatically purges the jobs |
| `JobAgeInMinutes` | [by Job Age] Jobs older than this number of minutes in age are cancelled |
| `PrinterName` | [by the printer] This printer is reset, cancelling the jobs on this printer and disabling the printer |
| `ResetSNMP` | [by the printer] Adds the flag to reset the SNMP data |
| `ResetLock` | [by the printer] Adds the flag to reset the lock data |
| `ResetToInactive` | [by the printer] Adds the flag to reset the printer, and set it to disabled |
| `ResetActive` | [by the printer] Adds the flag to reset the printer, and set it back to enabled |
| `Status` | [by Job Status] The jobs with this status are cancelled |

##### _Examples_

```powershell
PS C:\> Remove-OMPrintJob -RIDNumber RID35332
PS C:\> Remove-OMPrintJob -JobAgeInMinutes 60
PS C:\> Remove-OMPrintJob -PrinterName Printer01
WARNING: Don't forget to re-enable this printer: Printer01
PS C:\> Remove-OMPrintJob -Status activ
```

[Jump to Top :arrow_up:](#)

___

### `Remove-OMSecondaryMPSPrinters`

When a printer is removed from the primary MPS server, the secondary server does not remove that same printer.
Each MPS server maintains its own licensing, so this can result in the secondary server exceeding its license.
This function will remove the printers that have not been removed from the secondary MPS server.  It has 3 modes of
operation.
1. ByDir  = The function directly compares the list of printer directories from the OMPlus installations to generate the list of printers to remove; this is the default mode of operation
2. ByFile = The function takes in 2 lists of printers, and uses that to generate the list of printers to remove
3. ByList = The function takes the list of printers from the primary MPS server, the list of printers from the secondary server, and generates the list of printers to remove

##### _Parameters_

| Parameter Name | Description |
| :-- | :-- |
| `PrimaryPrinterFile` | [byFile] The file containing the list of printers from the primary MPS server |
| `SecondaryPrinterFile` | [byFile] The file containing the list of printers from the secondary MPS server |
| `PrimaryMPSPrinterDirectory` | [byDir] The directory containing the printers from the primary MPS server; it uses the environment variables set by the module to locate the printers by default |
| `SecondaryMPSPrinterDirectory` | [byDir] The directory containing the printers from the secondary MPS server; it uses the environment variables set by the module to locate the printers by default |
| `PrimaryList` | [byList] The list of printers from the primary MPS server |
| `SecondaryList` | [byList] The list of printers from the secondary MPS server |

##### _Example_

```powershell
PS C:\> Remove-OMSecondaryMPSPrinters -SecondaryMPSIsTransform -WhatIf -Verbose
$SecondaryMPSIsTransform switch is present, not deleting transform printers
Removing this printer list from mpsserver02
MyPrinter05
MyPrinter06

PS C:\> Remove-OMSecondaryMPSPrinters -Verbose
$SecondaryMPSIsTransform switch is not present, any pt_transform printers will be deleted along with the rest
WARNING: Do not forget to Remove the EPR Record for MyPrinter05
WARNING: Do not forget to Remove the EPR Record for MyPrinter06
WARNING: Do not forget to Remove the EPR Record for pt_transform_01
WARNING: Do not forget to Remove the EPR Record for pt_transform_01


```


### `Set-OMPrinter`

This function is a duplicate of `New-OMPrinter` designed to update an existing printer rather than create a new printer.
If a printer is given a new name, then a new printer is created, rather than updating the existing printer (limitation of `lpadmin.exe`)
This function has not been heavily tested yet; it should be used with caution

[Jump to Top :arrow_up:](#)
___

### `Sync-OMSecondaryPrinters`

This function uses dmdestsync.exe to either push a printer from the primary MPS server, or pull it from the secondary (depending on where it is run from).
##### _Parameters_

| Parameter Name | Description |
| :-- | :-- |
| `PrinterName` | The specific printer(s) to pull/push; if it is set to 'All', it will sync all of the printers. With _All_ printers, it is a slow process.  |
| `ShowProgress` | This will display a progress bar showing the printers as they are synchronized. |

##### _Example_

```powershell
PS C:\Sync-OMSecondaryPrinters -PrinterName Printer01, Printer02

PS C:\Sync-OMSecondaryPrinters -PrinterName All
The PrinterName list contains "All", this will take some time
```

[Jump to Top :arrow_up:](#)

___

### `Test-Port`

This is a generic function to test the reponsiveness of a remote machine on a specific TCP port.

##### _Parameters_

| Parameter Name | Description |
| :-- | :-- |
| `ComputerName` | The resolvable name or ip address to test |
| `TCPPort` | The TCP port to test; it is defaulted to TCP/9100; other typical ports to test are 515 for LPR/LPD, 80/443 for web pages etc.|
| `TimeOutinMilliseconds` | The timeout that the script will wait for, before giving up and returning `$false`.  It is defaulted to 3000 (3 seconds). |

##### _Example_

```powershell
PS C:\> Test-Port -ComputerName 10.10.10.10 -TCPPort 9100
True
PS C:\> Test-Port -ComputerName 10.10.10.10 -TCPPort 515
True
PS C:\> Test-Port -ComputerName 10.10.10.10 -TCPPort 80
True
PS C:\> Test-Port -ComputerName 10.10.10.10 -TCPPort 443
False
```

[Jump to Top :arrow_up:](#)

___

### `Update-OMTransformServer`

This function triggers the automatic update of the `eps_map` and other files from the primary MPS server to the secondary MPS server.
It happens automatically when the Save button in the EPR Records dialog is clicked.  If the `eps_map` file is updated, and this function is not called, the Transform Servers are not aware of the new printers and updated EPR Records.
It reads the `sendHosts` file and uses `pingmessage.exe` against the hosts in that file.

##### _Parameters_

There are no parameters for this function

##### _Example_
```powershell
PS C:\> Update-OMTransformServer
```

[Jump to Top :arrow_up:](#)
