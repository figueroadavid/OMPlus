# OMPlus Delivery Manager

![OMPlusLogo](https://www.plustechnologies.com/wp-content/uploads/2015/01/logo-plustechnologies.png)

Wrapper module for [OMPlus for Windows](https://www.plustechnologies.com)

The module is written to provide a powershell friendly wrapper for the various binary utilities for OMplus on Windows.
Here are the base functions provided

- #### [`Enable-OMPlusPrinter`](#enable-omplusprinter)

- #### [`Disable-OMPlusPrinter`](#disable-omplusprinter)

- #### [`Get-OMPlusDriverNames`](#get-omplusdrivernames)

- #### [`Get-OMPlusPrinterConfiguration`](#get-omplusprinterconfiguration)

- #### [`Get-OMPlusPrinterList`](#get-omplusprinterlist)

- #### [`New-OMPlusBulkImport`](#new-omplusbulkimport)

- #### [`New-OMPlusEPRRecordLite`](#new-ompluseprrecordlite)

- #### [`New-OMPlusPrinter`](#new-omplusprinter)

- #### [`New-OMPlusSampleBulkImportFile`](#new-omplussamplebulkimportfile)

- #### [`Remove-OMPlusPrinter`](#remove-omplusprinter)

- #### [`Remove-OMPlusPrintJob`](#remove-omplusprintjob)

- #### [`Set-OMPlusPrinter`](#set-omplusprinter)

---

## Functions

### `Enable-OMPlusPrinter`

Enables a previously disabled printer in OMPlus.

##### _Parameters_
<div class="col2table">

| Parameter Name  | Description |
| --------------- | ----------- |
| `-PrinterName`  | Accepts 1 or more printer names to enable; if a printer does not exist, then a warning is written, and the printer is skipped |
| `-ShowProgress` | Writes a progress bar to show the progress of the cmdlet; this is useful when enabling a large number of printers |

</div>

##### _Example_

```powershell
PS C:\> Enable-OMPlusPrinter -PrinterName PRINTER01, PRINTER02, PRINTER03
WARNING: Printer: PRINTER03 is not a valid printer for this system; skipping
```

### `Disable-OMPlusPrinter`

Disables a printer in OMPlus

##### _Parameters_

<div class="col2table">

| Parameter Name  | Description |
| --------------- | ----------- |
| `-PrinterName` | Accepts 1 or more printer names to disable; if a printer does not exist, then a warning is written, and the printer is skipped |
| `-ShowProgress` | Writes a progress bar to show the progress of the cmdlet; this is useful when disabling a large number of printers |

</div>

##### _Example_

```powershell
PS C:\> Enable-OMPlusPrinter -PrinterName PRINTER01, PRINTER02, PRINTER03
WARNING: Printer: PRINTER03 is not a valid printer for this system; skipping
```

### `Get-OMPlusDriverNames`

Reads and returns the list of driver names from the `types.conf` file in OMPlus

##### _Example_

```powershell
PS C:\> Get-OMPlusDriverNames
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

### `Get-OMPlusPrinterConfiguration`

Reads the configuration of a printer in OMPlus and returns the contents of the configuration file as a PSCustomObject

##### _Parameters_

<div class="col2table">

| Parameter Name  | Description |
| --------------- | ----------- |
| `-PrinterName` | Accepts 1 or more printer names from which to retrieve the configuration |
| `-Property` | Accepts a list of 1 or more property names to return in the PSCustomObject |

</div>
##### _Example_
```powershell
PS C:\> Get-OMPlusPrinterConfiguration -PrinterName Printer01
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

### `Get-OMPlusPrinterList`

Gets and returns the list of printers in OMPlus

##### _Example_

```powershell
PS C:\> Get-OMPlusPrinterList
Printer01
Printer02
Printer03
Printer04
MyPrint01
MyPrint02
MyPrint03
MyPrint04
```

### `New-OMPlusBulkImport`

Reads in a CSV file of printers and feeds them into the New-OMPlusPrinter function to create new OMPlus printers
##### _Parameters_

<div class="col2table">

| Parameter Name  | Description |
| --------------- | ----------- |
| `-FilePath` | The path to the CSV file to read in |
| `-Delimter` | The character used to separate the fields, it defaults to a commma |

</div>

##### _Example_

```powershell
PS C:\> New-OMPlusBulkImport -FilePath c:\temp\omplusimport.csv -delimiter '|'
```

### `New-OMPlusEPRRecordLite`

This is a work in progress.  It is designed to create a correctly formatted Epic Print Record for the `eps_map` file.

##### _Parameters_

<div class="col2table">

| Parameter Name  | Description |
| --------------- | ----------- |
| `-ServerName` | The name of the server that will host the EPR Record; defaults to the current machine; Having the correct servername isn't *critical* per-se; the OMPlus system will automatically update the record |
| `-EPRQueueName`| The name of the EPR Queue Name for the Record; there can be multiple EPRQueueNames per OMPlusQueueName |
| `-OMPLusQueueName`| the queue/destination name in OMPlus |
| `-DriverName`| the name of the driver used in the system; this name _is_ case|sensitive; this name comes from the _Types_ list in the OMPlus Administration tool |
| `-TrayName`| this is the name of the tray to use.  It must match the trays available in the `types.conf`. |
| `-DuplexOption`| this is the Duplex option setting in the _Epic Print Record_ tool; it comes from the `types.conf` file; it can be _None_ (which is blank), _Simplex_, _Horizontal_ (Short Edge), or _Vertical_ (Long Edge) |
| `-PaperSize`| this is the size of the paper; it also comes from the `types.conf` file |
| `-IsRx`| sets the flag if the EPR is designated for prescriptions, it defaults to 'n'; which is unchecked in the EPR tool |
| `-MediaType`| determines which media type the printer is using.  It defaults to 'none' |

</div>

 ### `New-OMPlusPrinter`

Creates a new OMPlus printer

##### _Parameters_

<div class="col2table">

| Parameter Name  | Description |
| --------------- | ----------- |
| `-PrinterName`| The name of the printer to create|
| `-IPAddress`| The IP address of the printer; `lpadmin.exe` does not require an IP address depending on the printer type, but the vast majority of printers managed by OMPlus are on the network and do need IP Addresses.  The script validates the number is in the range of `0-65535`|
| `-TCPPort`| The TCP port used for the printer; it defaults to `9100`|
| `-LPRPort`| The name of the LPD/LPR queue; if this is used the script will replace the TCPPort with the LPRPort queue name|
| `-Comment`| This supplies the comment (`-ocmt`) parameter;|
| `-HasInternalWebServer`| This sets the _`Has Internal Web Server`_ flag for the printer; if _`CustomURL`_ is not supplied, the script tests for a web page on port `80`(`http`), and then on port `443`(`https`) if `80` does not respond; (`-ourl`)|
| `-CustomURL`| This is used with the _HasInternalWebServer_ to set the -ourl parameter, and must be used if the web page is not accessed by the IP address on a standard `http`(`80`) or `https`(`443`) port|
| `-ForceWebServer`| Used in combination with _HasInternalWebServer_ to set the `-ourl` port without verifying that the URL responds (http, https, custom)|
| `-PurgeTime`| Overrides the default purge time from the system for the printer; this value is in seconds (`-opurgetime`)|
| `-PageLimit`| Overrides the default page limit from the system for the printer (`-opagelimit`)|
| `-Notes`| This supplies the the Notes field (`-onoteinfo`)|
| `-SupportNotes`| Supplies the Support Notes field (`-osupport`)|
| `-WriteTimeout`| Overrides the default timeout value for print jobs for this printer (`-owritetimeout`)|
| `-TranslationTable`| Overrides the default translation table for the system for this printer (`-otrantrable`)|
| `-DriverType`| Sets the correct driver type; this script was written for Powershell 4; the administrator needs to first get the correct driver types to set the list for `[ValidateSet()]`; however, future versions will automatically prepopulate this list with ArgumentCompleters (`-oPT`)|
| `-Mode = 'termserv'`| Defaults to `termserv`; `LPRPort` is also supplied, this is changed to 'netprint' (`-omode`)|
| `-FormType`| Overrides the default form type for the printer (`-oform`)|
| `-PCAPPath`| Enables the PCAP capture for the printer, and sets the file path for the capture file (`-oPcap`)|
| `-UserFilterPath`| Sets a user defined filter script for print jobs (`-ousrfilter`); the file must exist on the system|
| `-Filter2`| Sets a secondary user defined filter script for print jobs (`-ofilter2`); the file must exist on the system|
| `-Filter3`| Sets a secondary user defined filter script for print jobs (`-ofilter3`); the file must exist on the system|
| `-CPSMetering`| Overrides the default characters per second metering for printer (`-ometering`)|
| `-Banner`| If used, and set to \$true, then `-obanner` is used and banner pages are injected between print jobs, if set to $false, then `-onobanner` is used|
| `-DoNotValidate`| Sets the -z flag so that lpadmin does not try to verify the printer's existence|
| `-LFtoCRLF`| If used, and set to \$true, then `-olfc` is used and LF characters are converted to CRLF characters, if set to $false, then `-onolfc` is used|
| `-CopyBreak`| If used, and set to \$true, then `-ocopybreak` is used and page breaks are inserted between print jobs, and if set to $false `-onocopybreak` is used, and page breaks are removed from between print jobs|
| `-FileBreak`| If used, and set to \$true, then `-ofilebreak` is used and page breaks are inserted between files submitted, and if set to $false, then `-onofilebreak` is used and page breaks between files are removed|
| `-InsertMissingFF`| If used, then if form feeds are missing between jobs, then they are inserted (`-ofilesometimes`)|
| `-IsTesting`| if used, displays the generated command line without actually creating the printer|
| `-IsFullTesting`| if used, displays all the supplied parameters, and then displays the generated command line|

</div>

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
PS C:\> New-OMPLusPrinter @PrintSplat
C:\Plustech\OMPlus\Server\bin\lpadmin.exe -pTESTPRINTER -v10.0.4.112!9100 -omode="termserv" -opurgetime=45
-ourl="http://10.0.4.112" -ometering=5000 -oPcap="c:\temp\test.pcap" -opagelimit=5 -onoteinfo="Test Notes" -z
-owritetime=60 -ocmnt="Beaker" -obanner -oform="Letter" -olfc -onocopybreak -osupport="Support Notes"
-omode="termserv" -ofilesometimes -onofilebreak -oPTHPUPD5
```

### `New-OMPlusSampleBulkImportFile`

This creates a sample csv file that is appropriate to import into `New-OMPlusBulkImport`

##### _Parameters_

<div class="col2table">

| Parameter Name | Description |
| -- | -- |
| `-FilePath` | The output path for the sample file |
| `-Delimiter` | A single character delimiter for the output file; it defaults to a comma (`,`) |
| `-PortType` | Defaults to `TCPPort`, the other option is `LPRPort` |
| `-IncludeComments` | This adds a series of comments for the optional _Parameters_ giving explanations to those _Parameters_ |
| `-OptionalParameter` | A list of the available optional_Parameters_ to include in the output file; |

</div>
<div class="col4table">

| Options                |                  |                   |                    |
| :------                | ----             | ----              | ----               |
| `HasInternalWebServer` | `Comment`        | `PCAPpath`        | `FileBreak`        |
| `CustomURL`            | `Notes`          | `CPSMetering`     | `Banner`           |
| `ForceWebServer`       | `SupportNotes`   | `InsertMissingFF` | `WriteTimeout`     |
| `DriverType`           | `UserFilterPath` | `FormType`        | `TranslationTable` |
| `DoNotValidate`        | `Filter2`        | `LFtoCRLF`        | `PageLimit`        |
| `PurgeTime`            | `Filter3`        | `CopyBreak`       | `IsTesting`        |

</div>

##### _Example_

```powershell
PS C:\> @SampleSplat = @{
       FilePath             = 'c:\temp\OmplusSample.csv'
       PortType             = 'TCPPort'
       OptionalParameter    = 'HasInternalWebServer','ForceWebServer','DriverType','DoNotValidate','Comment','IsTesting'
       IncludeComments      = $true
}
PS C:\> New-OMPlusSampleBulkImportFile @SampleSplat

#Contents of the file
"PrinterName","IPAddress","TCPPort","HasInternalWebServer","ForceWebServer","DriverType","DoNotValidate","Comment","IsTesting"
"Mandatory parameter; Name used to create the actual printer; spaces are not allowed","Mandatory parameter; IP address for the printer, or LPR/LPD print server","Mandatory parameter: The TCP port used for network communication, between 0 and 65535; the default is 9100","Optional parameter; Indicates that the printer has a built in web server; if a CustomURL is not supplied it will attempt to create a URL from http://<ipaddress> or https://<ipaddress> ","Optional parameter; Indicates that te default web server URL needs to be set even if neither http://<ipaddress> nor https://<ipaddress> respond ","Optional parameter; The DriverType for the printer; must be one of the supported ones from the system","Optional parameter; Tells lpadmin not to verify the printer before creating it (-z)","Optional parameter; Comment for the printer","Optional parameter; Causes the script to return the generated command line rather than execute it"

PS C:\> @SampleSplat = @{
       FilePath             = 'c:\temp\OmplusSample.csv'
       PortType             = 'TCPPort'
       OptionalParameter    = 'HasInternalWebServer','ForceWebServer','DriverType','DoNotValidate','Comment','IsTesting'
       IncludeComments      = $false
}

PS C:\> New-OMPlusSampleBulkImportFile @SampleSplat

#Contents of the file
PrinterName,IPAddress,TCPPort,HasInternalWebServer,ForceWebServer,DriverType,DoNotValidate,Comment,IsTesting
```

### `Remove-OMPlusPrinter`

This uses `lpadmin.exe` to delete the given printers by name; when the printers are deleted the function throws up a warning to remind the administrator to remove the OMPlus EPR Record for the printer.

##### _Parameters_

<div class="col2table">

| Parameter Name | Description |
| -- | -- |
| `-PrinterName` | The list of printers to remove |

</div>

##### _Example_

```powershell
PS C:\> Get-OMPlusPrinterList -Filter Office1Prt_* | ForEach-Object { Remove-OMPlusPrinter -PrinterName $_ }
WARNING: Do not forget to Remove the EPR Record for Office1Prt_001
WARNING: Do not forget to Remove the EPR Record for Office1Prt_002
WARNING: Do not forget to Remove the EPR Record for Office1Prt_003
WARNING: Do not forget to Remove the EPR Record for Office1Prt_004
```

### `Remove-OMPlusPrintJob`

This function deletes print jobs that exists in the system. It has 3 modes of operation:

1. By RID number: Deletes the job with the job number  (uses `dcccancel.exe`)
2. By Age: Deletes all print jobs older than the specified time in minutes (uses `dccgrp.exe`)
3. By Printer: Resets the printer, thereby deleting the print jobs going to that printer (uses `dccreset.exe`)
4. By Status: Cancels all jobs with the given status (uses `dccgrp.exe`)

##### _Parameters_

<div class="col2table">

| Parameter Name | Description |
| -- | -- |
|  `-RIDNumber` | [by RID number] The RIDNumber(s) of the print jobs to delete |
|  `-ImmediatePurge` | [by RID number] adds the flag to automatically purges the jobs |
|  `-JobAgeInMinutes` | [by Job Age] Jobs older than this number of minutes in age are cancelled |
|  `-PrinterName` | [by the printer] This printer is reset, cancelling the jobs on this printer and disabling the printer |
|  `-ResetSNMP` | [by the printer] Adds the flag to reset the SNMP data |
|  `-ResetLock` | [by the printer] Adds the flag to reset the lock data |
|  `-ResetToInactive` | [by the printer] Adds the flag to reset the printer, and set it to disabled |
|  `-ResetActive` | [by the printer] Adds the flag to reset the printer, and set it back to enabled |
|  `-Status` | [by Job Status] The jobs with this status are cancelled |

</div>

##### _Examples_

```powershell
PS C:\> Remove-OMPlusPrintJob -RIDNumber RID35332
PS C:\> Remove-OMPlusPrintJob -JobAgeInMinutes 60
PS C:\> Remove-OMPlusPrintJob -PrinterName Printer01
WARNING: Don't forget to re-enable this printer: Printer01
PS C:\> Remove-OMPlusPrintJob -Status activ
```

### `Set-OMPlusPrinter`

This function is a duplicate of `New-OMPlusPrinter` designed to update an existing printer rather than create a new printer.
If a printer is given a new name, then a new printer is created, rather than updating the existing printer (limitation of `lpadmin.exe`)
This function has not been heavily tested yet; it should be used with caution
