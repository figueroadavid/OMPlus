if ($PSVersionTable.PSEdition -ne 'Core')
{
  # add the attribute [ArgumentCompletions()]:
  $code = @'
using System;
using System.Collections.Generic;
using System.Management.Automation;

    public class ArgumentCompletionsAttribute : ArgumentCompleterAttribute
    {

        private static ScriptBlock _createScriptBlock(params string[] completions)
        {
            string text = "\"" + string.Join("\",\"", completions) + "\"";
            string code = "param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams);@(" + text + ") -like \"*$WordToComplete*\" | Foreach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }";
            return ScriptBlock.Create(code);
        }

        public ArgumentCompletionsAttribute(params string[] completions) : base(_createScriptBlock(completions))
        {
        }
    }
'@

  $null = Add-Type -TypeDefinition $code *>&1
  Remove-Variable -Name code
  # This is from https://powershell.one/powershell-internals/attributes/auto-completion
}

Get-ChildItem -Path $PSScriptRoot\Private -File -Filter *.ps1 | Where-Object fullname -notmatch '`.tests`.ps1' |
    ForEach-Object {
        Write-Verbose -Message ('Importing script: {0}' -f $_.FullName ) -Verbose
        . $_.FullName }

Get-ChildItem -Path $PSScriptRoot\Public -File -Filter *.ps1 | Where-Object fullname -notmatch '`.tests`.ps1' |
    ForEach-Object {
        Write-Verbose -Message ('Importing script: {0}' -f $_.FullName ) -Verbose
        . $_.FullName
    }

$Global:OMHOMEPath          = (Get-ItemProperty -Path 'HKLM:\Software\PlusTechnologies\OMPlusServer' -Name OMHOMEPath).OMHOMEPath
$GLobal:OMPlusPrinterPath   = [System.IO.Path]::Combine($Global:OMHOMEPath, 'printers')
$Global:BinPath             = [System.IO.Path]::Combine($Global:OMHOMEPATH, 'bin')
$Global:OMPLusSystemPath    = [System.IO.Path]::Combine($Global:OMHOMEPath, 'system')
$Global:ValidTypes          = Get-OMPLusDriverNames
$Global:CRLF                = [Environment]::NewLine
$Global:OMPlusServerFQDN    = [system.net.dns]::GetHostByName($env:COMPUTERNAME).hostname
