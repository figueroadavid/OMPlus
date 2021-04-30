function Update-OMTransformServer {
    <#
    .SYNOPSIS
        It uses the pingmsg.exe utility to trigger updates on the Transform servers

    .DESCRIPTION
        It uses the sendHosts file which contains the FQDN's of all the transform servers to
        send the updates. The primary goal is to replicate the eps_map file from the .\system directory
        on the master print server to the .\constants folder on the transform servers.
    .EXAMPLE
        PS C:\> Update-OMlusTransformServer -Verbose
        Using pingmsg to update host: srvtran01
        Using pingmsg to update host: srvtran02
        Using pingmsg to update host: srvtran03
        Using pingmsg to update host: srvtran04
    .INPUTS
        [none]
    .OUTPUTS
        [none]
    .NOTES
        By default, external changes to the eps_map file do not get replicated, so this function
        is necessary to guarantee the changes made are replicated.
    #>

    [cmdletbinding()]
    param()
    $TransformHostPath  = [System.IO.Path]::Combine($OMSystemPath, 'sendHosts')
    $PingMsgPath        = [System.IO.Path]::Combine($OMBinPath, 'pingmsg.exe')

    Get-Content -Path $TransformHostPath | ForEach-Object {
        $thisHost = $_
        Write-Verbose -Message ('Using pingmsg to update host: {0}' -f $thisHost )
        $pingSplat = @{
            FilePath        = $PingMsgPath
            ArgumentList    = $thisHost
            Verb            = 'runas'
            Wait            = $true
            WindowStyle    = 'Hidden'
        }
        Write-Verbose -Message ('Triggering update for {0}' -f $thisHost)
        Start-Process @pingSplat
    }
}
