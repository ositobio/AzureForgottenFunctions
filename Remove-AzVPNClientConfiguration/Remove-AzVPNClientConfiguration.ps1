<#
.SYNOPSIS
    Remove-AzVPNClientConfiguration 
    Removes the configuration for P2S in the VPN Gateway
    
.DESCRIPTION
    Removes the configuration for P2S in the VPN Gateway by setting it to $null, as there is no option to do it in Azure Portal or PowerShell commands
    
    Remove-AzVPNClientConfiguration -VirtualNetworkGateway <String> -ResourceGroup <String>

.PARAMETER VirtualNetworkGateway
    -VirtualNetworkGateway <"VPN Gateway"> (Mandatory)
        VPN Gateway

.PARAMETER ResourceGroup
    -ResourceGroup <"ResourceGroup"> (Mandatory)
        Resource group where the connection is
    
.EXAMPLE
    
    Remove-AzVPNClientConfiguration -VirtualNetworkGateway "VPN Gateway" -ResourceGroup "VPN_Resouce_Group"     
        
        Removes P2S configuration from the VPN gateway
#>


## Parameters
param(
    [Parameter(mandatory = $true)][ValidateNotNullOrEmpty()][string] $VirtualNetworkGateway,
    [Parameter(mandatory = $true)][ValidateNotNullOrEmpty()][string] $ResourceGroup
)

cls

Write-host "VPN $VirtualNetworkGateway P2S configuration will we deleted `n" -foregroundColor Red

## Get VPN config into a variable
$VPN = Get-AzVirtualNetworkGateway -Name $VirtualNetworkGateway -ResourceGroup $ResourceGroup

## Setting P2S to $null
$VPN.VpnClientConfiguration = $null

## Updating VPN
Write-host -NoNewLine "Updating VPN Gateway (might take few minutes)... " 
$tmp = Set-AzVirtualNetworkGateway -VirtualNetworkGateway $VPN
Write-host "updated!!" -foregroundColor Green
