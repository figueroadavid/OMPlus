function Test-OpenPort {
    <#
    .SYNOPSIS
        Tests for open TCP ports on a remote computer
    .DESCRIPTION
        Tests for open TCP ports on a remote computer.  But unlike Test-Connection or
        Test-NetConnection, it provides for timeouts for a clean test.
        It also provides a simple True/False result
    .EXAMPLE
        PS C:\> Test-Port -ComputerName server1 -TCPPort 445 -TimeoutInMs 5000
        True

        It attempts to connect to server1 on the SMB port 445 with a timeout of 5 seconds
        and returns True because it was open and it did respond.

    .EXAMPLE
        PS C:\> Test-Port -ComputerName server2 -TCPPort 445 -TimeoutInMs 5000
        False

        It attempts to connect to server2 on the SMB port 445 with a timeout of 5 seconds
        and returns False becuase the port did not respond
    .PARAMETER ComputerName
        This is the resolvable name or IP address of the computer

    .PARAMETER TCPPort
        This is the number of the TCP port to test (1-65535)

    .PARAMETER TimeoutInMs
        This is the number of milliseconds to wait for a response before considering the port to be closed or blocked.
    .INPUTS
        [string]
        [int]
    .OUTPUTS
        [bool]
    .NOTES
        Uses a simple .net call to System.Net.Sockets.TcpClient and attempts to establish
        a connection, using a timeout.  Without this, the built-in functions have a default
        timeout of 30 seconds, which is generally too slow for most scripting purposes.
    #>
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(0,65535)]
        [int]$TCPPort,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(100,10000)]
        [int]$TimeoutInMs = 2000
    )

    Begin {
        $TCPConnector = New-Object -Type System.Net.Sockets.TcpClient
        $TCPConnector.SendTimeout = $TimeoutInMs
    }

    Process {
        foreach ($Computer in $ComputerName) {
            try {
                $TCPConnector.Connect($Computer, $TCPPort)
                $Result = $True
            }
            catch {
                $Result = $false
            }
            [pscustomobject]@{
                ComputerName = $Computer
                Port         = $TCPPort
                IsOpen       = $Result
            }
        }
    }

    End {
        $TCPConnector.Dispose()
    }
}
