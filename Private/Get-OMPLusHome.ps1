Function Get-OMPHome {
    (Get-ItemProperty -Path 'HKLM:\Software\PlusTechnologies\OMPlusServer' -Name OMHOMEPath).OMHOMEPath
}
