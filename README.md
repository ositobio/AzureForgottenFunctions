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



- ### **Remove-AzVPNClientConfiguration** <a name="Remove-AzVPNClientConfiguration"></a>

Removes the configuration for P2S in the VPN Gateway by setting it to $null, as there is no option to do it in Azure Portal or PowerShell commands

**Remove-AzVPNClientConfiguration -VirtualNetworkGateway "VPN Gateway" -ResourceGroup "VPN_Resouce_Group"**

_VirtualNetworkGateway <"VPN Gateway">_: Mandatory, name of the VPN Gateway

_ResourceGroup <"ResourceGroup">_: Mandatory, resource group where the connection is




- ### **Reset-AzActiveActiveVirtualNetworkGateway** <a name="Reset-AzActiveActiveVirtualNetworkGateway"></a>

When clicking Reset in Azure portal in an Active-Active VPN, it will only reboot first instance, making impossible to restart the second one. This scripts automates it, resetting both instances, waiting for the first one to come up before resetting the second to avoid downtime. 

**Reset-AzActiveActiveVPN.ps1 -GatewayName "MyActiveActiveVPN" -ResourceGroup "VPN_Resouce_Group"**

_GatewayName <"Name of the VPN Gateway">_: Mandatory, VPN that is going to be reset

_ResourceGroup <"ResourceGroup">_: Mandatory, resource group where the connection is




- ### **Reset-AzVirtualNetworkGatewayConnection** <a name="Reset-AzVirtualNetworkGatewayConnection"></a>

As there is no possibility to reset only one connection and to avoid resetting the whole VNP, this script gets the connection configuration, deletes it and creates it again
    
**Reset-AzVirtualNetworkGatewayConnection.ps1 -ConnectionName "ConnectionToOnPrem" -ConnectionResourceGroup "VPN_Resouce_Group"**
    
_ConnectionName <"ConnectionInTheVPN">_: Mandatory, connection that is going to be reset

_ConnectionResourceGroup <"ResourceGroup">_: Mandatory, resource group where the connection is



## DISCLAIMER <a name="disclaimer"></a>
**This code is provided as-is, with no warranty or support, either from my side or from Microsoft** (apart from my spare time to work on possible issues). Everything has been tested in my environments and worked fine, but that doesn't mean it will be working flawlessly in yours. If you experience any bug, please, let me know and I will do my best to sort it out. I wont be customizing code or debuging problems in you environment, apart from possible logs or screenshots I could ask for and always at my discretion. **If you plan to use any script in production environment, test it before in a testing environment** to make sure that it works as expected and if it will have any downtime. 






