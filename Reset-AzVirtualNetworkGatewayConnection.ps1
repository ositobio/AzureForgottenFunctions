<#
.SYNOPSIS
    Reset-AzVirtualNetworkGatewayConnection.ps1 resets the connection by deleting and creating it again
    
.DESCRIPTION
    As there is no possibility to reset only one connection and to avoid resetting the whole VNP, this script get the connection configuration, deletes it and creates it again
    
    Reset-AzVirtualNetworkGatewayConnection.ps1 -ConnectionName <String> -ConnectionResourceGroup <String>
    
    -ConnectionName <"ConnectionInTheVPN"> (Mandatory)
        Connection that is going to be reset
    
    -ConnectionResourceGroup <"ResourceGroup"> (Mandatory)
        Resource group where the connection is
    
    
.EXAMPLE
    
    Reset-AzVirtualNetworkGatewayConnection.ps1 -ConnectionName "ConnectionToCiscoASA" -ConnectionResourceGroup "VPN_Resouce_Group"     
        
        Deletes the connection named "ConnectionToCiscoASA" from the resource group "VPN_Resouce_Group" and creates it again
#>


## Parameters
param(
    [Parameter(mandatory = $true)][ValidateNotNullOrEmpty()][string] $ConnectionName,
    [Parameter(mandatory = $true)][ValidateNotNullOrEmpty()][string] $ConnectionResourceGroup
)

cls

## Internal variables
$Param2 = ""
$Value2 = ""
$Parameters = ""

Write-host "Connection $ConnectionName will be deleted and recreated `n" -foregroundColor Red

# Retrieve the connection configuration
Write-host -NoNewLine "Saving connection configuration... " 
$Connection = Get-AzVirtualNetworkGatewayConnection -Name $ConnectionName -ResourceGroupName $ConnectionResourceGroup
Write-host "Configuration saved" -foregroundColor Green

# Removes the connection
Write-host -NoNewLine "Deleting connection... " 
Remove-AzVirtualNetworkGatewayConnection -Name $Connection.Name -ResourceGroupName $Connection.ResourceGroupName -Force 
Write-host "Connection deleted" -foregroundColor Green

# Retrieves the VPN configuration that is associated to the connection
$VPNGw1 = Get-AzVirtualNetworkGateway -name $Connection.VirtualNetworkGateway1.id.Split("/")[-1] -ResourceGroupName $Connection.ResourceGroupName

# Logic to differentiate between connection linking two VPNs or one VNP and one Local Network Gateway
if ($Connection.VirtualNetworkGateway2) 
{
    Write-host "Connection is linked to another VPN gateway" 
    $Param2 = "VirtualNetworkGateway2"
    $Value2 = Get-AzVirtualNetworkGateway -name $Connection.VirtualNetworkGateway2.id.Split("/")[-1] -ResourceGroupName $Connection.ResourceGroupName
}

if ($Connection.LocalNetworkGateway2) 
{
    Write-host "Connection is linked to a local network gateway" 
    $Param2 = "LocalNetworkGateway2"
    $Value2 = Get-AzLocalNetworkGateway -name $Connection.LocalNetworkGateway2.id.Split("/")[-1] -ResourceGroupName $Connection.ResourceGroupName
}

# Populates the parameter and the value to be sent in the creation
$parameters = @{$param2 = $value2}

# Create the new connection
Write-host -NoNewLine "Recreating the connection... " 
$tmp = New-AzVirtualNetworkGatewayConnection -Name $Connection.Name -ResourceGroupName $Connection.ResourceGroupName -Location $Connection.Location -ConnectionType $Connection.ConnectionType -VirtualNetworkGateway1 $VPNGw1 @Parameters -Force 

# Push the old configuration in the new connection to replicate it
$tmp = Set-AzVirtualNetworkGatewayConnection -VirtualNetworkGatewayConnection $Connection -Force
Write-host "Connection recreated and configuration updated `n" -foregroundColor Green

# Check connectivity and wait for the connection to come up
Write-host "Checking connection status. Will timeout in 5 minutes if it's not transitioning to connected"
$NewConnection = Get-AzVirtualNetworkGatewayConnection -Name $ConnectionName -ResourceGroupName $ConnectionResourceGroup
$Timer = 60

While (($NewConnection.ConnectionStatus -ne "Connected") -and ($Timer -ne 0))
{
    $NewConnection = Get-AzVirtualNetworkGatewayConnection -Name $ConnectionName -ResourceGroupName $ConnectionResourceGroup
    Write-Progress -Activity "Connection Status:" -Status $NewConnection.ConnectionStatus
    Start-Sleep -Seconds 5
    $Timer--
}

If ($NewConnection.ConnectionStatus -eq "Connected")
{
    Write-host "Connection status is connected!!" -foregroundColor Green
}

If ($Timer -eq 0)
{
    Write-host "ERROR: Connection didn't reconnect in 5 minutes" -foregroundColor Red
}


