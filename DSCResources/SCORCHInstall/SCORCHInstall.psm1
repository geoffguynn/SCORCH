
Import-Module $PSScriptRoot\..\..\xPDT.psm1

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Description,

        [parameter(Mandatory = $true)]
        [System.String]
        $ProductKey,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $ServiceUserCredential,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential,

        [parameter(Mandatory = $true)]
        [ValidateSet("ManagementServer","RunbookServer","WebComponents","All")]
        [System.String]
        $Components,

        [parameter(Mandatory = $true)]
        [System.String]
        $DatabaseServer,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $DatabaseUserCredential,

        [parameter(Mandatory = $true)]
        [System.String]
        $SourceFolder
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."


    <#
    $returnValue = @{
    Description = [System.String]
    Ensure = [System.String]
    ProductKey = [System.String]
    ServiceUserCredential = [System.Management.Automation.PSCredential]
    Components = [System.String]
    InstallDirectory = [System.String]
    DatabaseServer = [System.String]
    DatabaseName = [System.String]
    DatabaseUserCredential = [System.Management.Automation.PSCredential]
    WebConsolePort = [System.String]
    WebServicePort = [System.String]
    OrchestratorUserGroupSID = [System.String]
    RemoteAccess = [System.Boolean]
    UseMicrosoftUpdate = [System.Boolean]
    EnableTelemetryReporting = [System.Boolean]
    EnableErrorReporting = [System.Boolean]
    SourceFolder = [System.String]
    }

    $returnValue
    #>
    return 'getthisordie'
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Description,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $ProductKey,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $ServiceUserCredential,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential,

        [parameter(Mandatory = $true)]
        [ValidateSet("ManagementServer","RunbookServer","WebComponents","All")]
        [System.String]
        $Components,

        [System.String]
        $InstallDirectory,

        [parameter(Mandatory = $true)]
        [System.String]
        $DatabaseServer,

        [System.String]
        $DatabaseName = 'Orchestrator',

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $DatabaseUserCredential,

        [System.String]
        $WebConsolePort = '82',

        [System.String]
        $WebServicePort = '81',

        [System.String]
        $OrchestratorUserGroupSID,

        [System.Boolean]
        $RemoteAccess,

        [System.Boolean]
        $UseMicrosoftUpdate,

        [System.Boolean]
        $EnableTelemetryReporting,

        [ValidateSet("always", "queued", "never")]        
        [System.String]
        $ErrorReporting = "always",

        [parameter(Mandatory = $true)]
        [System.String]
        $SourceFolder
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

    #Include this line if the resource requires a system reboot.
    #$global:DSCMachineStatus = 1

    $PathToSetup = Join-Path $SourceFolder -ChildPath 'Setup\Setup.exe'
    $Installer = ResolvePath $PathToSetup

    if ($Ensure -eq 'Present')
    {
        $InstallString = [System.Collections.ArrayList]::new()

        $null = $InstallString.Add('/Silent') 
        $null = $InstallString.Add("/Key:$ProductKey")
        $null = $InstallString.Add("/ServiceUserName:$($ServiceUserCredential.UserName)")
        $null = $InstallString.Add("/ServicePassword:$($ServiceUserCredential.GetNetworkCredential().Password)")
        $null = $InstallString.Add("/Components:$Components")
        $null = $InstallString.Add("/DbServer:$DatabaseServer")
        # $null = $InstallString.Add("/DbUser:$($DatabaseUserCredential.UserName)")
        # $null = $InstallString.Add("/DbPassword:$($DatabaseUserCredential.GetNetworkCredential().Password)")
        $null = $InstallString.Add("/DbNameNew:$DatabaseName")
        $null = $InstallString.Add("/WebServicePort:$WebServicePort")
        $null = $InstallString.Add("/WebConsolePort:$WebConsolePort")
        $null = $InstallString.Add("/EnableErrorReporting:$ErrorReporting")

        if ($InstallDirectory)
        {
            $null = $InstallString.Add("/InstallDir:$InstallDirectory")            
        }

        if ($OrchestratorUserGroupSID)
        {
            $null = $InstallString.Add("/OrchestratorUsersGroup:$OrchestratorUserGroupSID")
        }

        if ($RemoteAccess)
        {
            $null = $InstallString.Add("/OrchestratorRemote")
        }

        if ($UseMicrosoftUpdate)
        {
            $null = $InstallString.Add("/UseMicrosoftUpdate:1")
        }
        else
        {
            $null = $InstallString.Add("/UseMicrosoftUpdate:0")
        }

        if ($EnableTelemetryReporting)
        {
            $null = $InstallString.Add("/SendCEIPReports:0")
        }
        else
        {
            $null = $InstallString.Add("/SendCEIPReports:1")
        }

        $FinalInstallString = $InstallString -join ' '
        Write-Verbose "Install is $Installer"
        Write-Verbose "Installing with the install string: $FinalInstallString"
        if ($PsDscContext.RunAsUser) 
        {
            Write-Verbose "User: $($PsDscContext.RunAsUser)"
            $PsDscContext
        }

        $Process = StartWin32Process -Path $Installer -Arguments $FinalInstallString -Credential $SetupCredential -AsTask
        Write-Verbose $Process
        WaitForWin32ProcessEnd -Path $Installer -Arguments $FinalInstallString -Credential $SetupCredential

    }
    elseif ($Ensure -eq 'Absent')
    {
        $Arguments = "/Silent /Uninstall"
        $Process = StartWin32Process -Path $Installer -Arguments $Arguments -Credential $SetupCredential -AsTask
        Write-Verbose $Process
        WaitForWin32ProcessEnd -Path $Installer -Arguments $Arguments -Credential $SetupCredential
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Description,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $ProductKey,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $ServiceUserCredential,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential,

        [parameter(Mandatory = $true)]
        [ValidateSet("ManagementServer","RunbookServer","WebComponents","All")]
        [System.String]
        $Components,

        [System.String]
        $InstallDirectory,

        [parameter(Mandatory = $true)]
        [System.String]
        $DatabaseServer,

        [System.String]
        $DatabaseName,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $DatabaseUserCredential,

        [System.String]
        $WebConsolePort,

        [System.String]
        $WebServicePort,

        [System.String]
        $OrchestratorUserGroupSID,

        [System.Boolean]
        $RemoteAccess,

        [System.Boolean]
        $UseMicrosoftUpdate,

        [System.Boolean]
        $EnableTelemetryReporting,

        [ValidateSet("always", "queued", "never")]        
        [System.String]
        $ErrorReporting = 'always',

        [parameter(Mandatory = $true)]
        [System.String]
        $SourceFolder
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."


    <#
    $result = [System.Boolean]
    
    $result
    #>
    $false
}

Export-ModuleMember -Function *-TargetResource

