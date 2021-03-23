function Test-Port
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ComputerName,

        [parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0,65535)]
        [int]$TCPPort = 9100,

        [parameter(ValueFromPipelineByPropertyName = $true)]
        [int]$TimeOutInMilliseconds = 3000
    )

    $TCPClient = New-Object -TypeName System.Net.Sockets.TcpClient
    $Connection = $TCPClient.BeginConnect($ComputerName, $TCPPort, $null, $null)
    $ConnectionWait = $Connection.AsyncWaitHandle.WaitOne($TimeOutInMilliseconds, $false)
    if (!$ConnectionWait)
    {
        $TCPClient.Close()
        Write-Verbose -Message ('Connection Timeout to {0} on port {1}' -f $ComputerName, $TCPPort)
        $ValidConnection = $false
    }
    else 
    {
        $Error.Clear()
        try {
            $null = $TCPClient.EndConnect($Connection) 
            $ValidConnection = $true         
        }
        catch {
            Write-Verbose -Message ('Error detected:{0}' -f $Error[0])
            $ValidConnection = $false
        }
    
        $TCPClient.Close()
    }
    if ($VerbosePreference -eq 'Continue')
    {
        if ($ValidConnection)
        {
            Write-Verbose -Message ('TCP Port {0} is open on {1}' -f $TCPPort, $ComputerName)
        }
        else 
        {
            Write-Warning -Message ('TCP Port {0} is not open on {1}' -f $TCPPort, $ComputerName)    
        }
        
    }
    else 
    {
        Write-Output $ValidConnection
    }
}