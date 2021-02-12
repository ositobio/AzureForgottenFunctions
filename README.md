# Azure Forgotten Functions

## Table of Contents

[Description of the project](#description)

**[Functions and scripts](#functions_and_scripts)**

- [Remove-AzVPNClientConfiguration](#Remove-AzVPNClientConfiguration)

- [Reset-AzActiveActiveVirtualNetworkGateway](#Reset-AzActiveActiveVirtualNetworkGateway)

- [Reset-AzVirtualNetworkGatewayConnection](#Reset-AzVirtualNetworkGatewayConnection)

**[DISCLAIMER](#disclaimer)**


## Description of the project <a name="description"></a>
Scripts to automate Azure tasks that are not available in Portal, are time consuming or simply helps to troubleshoot better and easier. 

Based on my experience with Azure, I miss some functionalities and automations to make my life easier and to perform some common troubleshooting steps without needing to spend a lot of time going through different portal options. 

I will keep on including scripts in time as I create them. There is a standalone script for every functionality or automation I create plus a PowerShell module called AzForgottenFunctions.psm1 with all of them, so be loaded directly in the PowerShell console. 

All files can be uploaded annd executed from Cloud Shell as well as from local PowerShell console. Due to the architecture and nature of Cloud Shell, module cannot be executed there. In both scriptor module version, the menu is available with "get-help _modulename_", including information of the script, of every parameter and examples. 




## Functions and scripts <a name="functions_and_scripts"></a>



- ### **[Remove-AzVPNClientConfiguration](https://github.com/ositobio/AzureForgottenFunctions/blob/master/Remove-AzVPNClientConfiguration.ps1)** <a name="Remove-AzVPNClientConfiguration"></a>

Azure VPN provides the functionality of configuring Point 2 Site (P2S) VPN connections. However, once you enable it, there is no way to rol it back and remove the configuration. This is particularly problematic when a certificate get's stuck or when troubleshooting problems with P2S connections. This scripts removes the configuration for P2S in the VPN Gateway by setting the JSON output to $null and then commiting a PUT operation. VPN is updated with "empty" confguration leaving it unconfigured and with no downtime.

**Remove-AzVPNClientConfiguration -VirtualNetworkGateway "VPN Gateway" -ResourceGroup "VPN_Resouce_Group"**

_VirtualNetworkGateway <"VPN Gateway">_: Mandatory, name of the VPN Gateway

_ResourceGroup <"ResourceGroup">_: Mandatory, resource group where the connection is




- ### **Reset-AzActiveActiveVirtualNetworkGateway** <a name="Reset-AzActiveActiveVirtualNetworkGateway"></a> (In progress...)

When clicking Reset in Azure portal in an Active-Active VPN, it will only reboot first instance, making impossible to restart the second one. This scripts automates it, resetting both instances, waiting for the first one to come up before resetting the second to avoid downtime. 

**Reset-AzActiveActiveVPN.ps1 -GatewayName "MyActiveActiveVPN" -ResourceGroup "VPN_Resouce_Group"**

_GatewayName <"Name of the VPN Gateway">_: Mandatory, VPN that is going to be reset

_ResourceGroup <"ResourceGroup">_: Mandatory, resource group where the connection is




- ### **[Reset-AzVirtualNetworkGatewayConnection](https://github.com/ositobio/AzureForgottenFunctions/blob/master/Reset-AzVirtualNetworkGatewayConnection.ps1)** <a name="Reset-AzVirtualNetworkGatewayConnection"></a>

When troubleshooting or changing some configuration in a connection or local network gateway (LNG), a "reset" of the VPN tunnel is needed applyu the new configuration. In Azure, it's only possible by resetting the whole VPN, that causes downtime and disruption in other tunnels, or by deleting the connection and creating it again, that implies administative effort. This script gets the connection configuration into a variable, deletes the connection and creates it again with the same name and configuration. Works for VNET to VNET Connections as well as normal tunnels with VPN to LNG bindings.
    
**Reset-AzVirtualNetworkGatewayConnection.ps1 -ConnectionName "ConnectionToOnPrem" -ConnectionResourceGroup "VPN_Resouce_Group"**
    
_ConnectionName <"ConnectionInTheVPN">_: Mandatory, connection that is going to be reset

_ConnectionResourceGroup <"ResourceGroup">_: Mandatory, resource group where the connection is



## DISCLAIMER <a name="disclaimer"></a>
**This code is provided as-is, with no warranty or support, either from my side or from Microsoft** (apart from my spare time to work on possible issues). Everything has been tested in my environments and worked fine, but that doesn't mean it will be working flawlessly in yours. If you experience any bug, please, let me know and I will do my best to sort it out. I wont be customizing code or debuging problems in you environment, apart from possible logs or screenshots I could ask for and always at my discretion. **If you plan to use any script in production environment, test it before in a testing environment** to make sure that it works as expected and if it will have any downtime. 






