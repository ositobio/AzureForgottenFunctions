<#
.SYNOPSIS
    Reset-AzActiveActiveVirtualNetworkGateway.ps1 resets both instances of the VPN in an active-active VPN
    
.DESCRIPTION
    When clicking Reset in Azure portal in an Active-Active VPN, due to some technical gaps, it will only reboot IN_0, making impossible to restart IN_1. this scripts automates the workaround to do it. It will reset both Instances, waiting for IN_0 to come up before resetting IN_1 to avoid downtime. 
    
    Reset-AzActiveActiveVirtualNetworkGateway.ps1 -GatewayName <String> -ResourceGroup <String>
    
    -GatewayName <"Name of the VPN Gateway"> (Mandatory)
        VPN that is going to be reset
    
    -ResourceGroup <"ResourceGroup"> (Mandatory)
        Resource group where the connection is
    
    
.EXAMPLE
    
    Reset-AzActiveActiveVPN.ps1 -GatewayName "MyActiveActiveVPN" -ResourceGroup "VPN_Resouce_Group"     
        
        Resets VPN named "MyActiveActiveVPN" from the resource group "VPN_Resouce_Group", first the IN_0 and then IN_1
#>


## Parameters
param(
    [Parameter(mandatory = $true)][ValidateNotNullOrEmpty()][string] $GatewayName,
    [Parameter(mandatory = $true)][ValidateNotNullOrEmpty()][string] $ResourceGroup
)

cls

# Get the VPN Gateway
Write-Host "Gathering initial information..."



$Gateway = Get-AzVirtualNetworkGateway -Name $GatewayName -ResourceGroup $ResourceGroup

# Retrieve list of IP Pairs: BGPIP,PublicIP
$BGPAddresses = $Gateway.BgpSettings.BgpPeeringAddresses 
$Pairs = @()

Write-Host " `n `n `n `n `n `n `n `nInternal and public IP information and assignments" -ForegroundColor Green
Write-Host "================================================== `n" -ForegroundColor Green

foreach ($IP in $BGPAddresses)
{
    Write-Host "Internal (BGP) Address" $IP.DefaultBgpIpAddresses[0] " is associated to"  $IP.TunnelIpAddresses[0]

    $Pairs += @(
        [pscustomobject]@{BGPIP = $IP.DefaultBgpIpAddresses[0]; PublicIP = $IP.TunnelIpAddresses[0]}
    )
}

Write-Host " `n `nStarting RESET process" -ForegroundColor Green
Write-Host "====================== `n" -ForegroundColor Green

foreach ($Instance in $Pairs)
{
    # Reset the instance
    Write-Host "Resetting" $Instance.BGPIP "and" $Instance.PublicIP -ForegroundColor Red
    $temp = Reset-AzVirtualNetworkGateway -VirtualNetworkGateway $Gateway -GatewayVip $Instance.PublicIP -AsJob
    Write-Host "VPN Gateway Status: Waiting for the new status to be populated (60~120 seconds)" 
    Start-Sleep -Seconds 60
    Write-Host "Reset in process. Waiting for the status to become Succeeded again. This process can take up to 30 minutes"
    Write-Host "Progress shown above... (Refreshed every 15 seconds)" 
    
    # Get the new status of the Gateway
    $Gateway = Get-AzVirtualNetworkGateway -Name $GatewayName -ResourceGroup $ResourceGroup

    # Wait for reset to complete
    $Timer = 120
    While (($Gateway.ProvisioningState -ne "Succeeded") -and ($Timer -ne 0))
    {
        $Gateway = Get-AzVirtualNetworkGateway -Name $GatewayName -ResourceGroup $ResourceGroup
        Write-Progress -Activity "VPN Gateway Status:" -Status $Gateway.ProvisioningState
        Start-Sleep -Seconds 15
        $Timer--
    }

    # Finished with Instance up
    If ($Gateway.ProvisioningState -eq "Succeeded")
    {
        Write-host $Instance.BGPIP "and" $Instance.PublicIP "successfully reset!!  `n" -foregroundColor Green
    }
    
    # Finished with timeout
    If ($Timer -eq 0)
    {
        Write-host $Instance.BGPIP "and" $Instance.PublicIP "didn't come back in 30 minutes  `n" -foregroundColor Red
    }
}



