# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# TITLE: VM Automation
# DESCRIPTION: Deploys a Hyper-V host and then give the option to deploy a web host as a virtual machine on the Hyper-V host. 
# AUTHOR NAME: Kole Armstrong
# -----------------------------------------------------------------------------
# REVISION HISTORY
# 2020-9-23: Alpha
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -----------------------------------------------------------------------------
# FUNCTION NAME: N/A
# DESCRIPTION: N/A
# -----------------------------------------------------------------------------

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MAIN SCRIPT BODY
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#This command allows you to execute any of the commands that are needed in this script.
Set-ExecutionPolicy Unrestricted

#This command installs the Hyper-V features. The second one and third ensure all the tools and PS module get installed.
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
Add-WindowsFeature Hyper-V-Tools
Add-WindowsFeature Hyper-V-PowerShell

#This command first renames the external switch then it creates a new internal virtual switch, names it and assigns it a location
Rename-VMSwitch "Ethernet0" -NewName "DMZ"
New-VMSwitch -Name Management -SwitchType Internal -Notes ‘We in bois’

#This command grabs the appropriate switch for the VM you are creating
Get-VMSwitch  * | Format-Table Name  

#Create a Hyper-V VM using PowerShell
New-VM -Name Testmachine1 -path C:\vm-machine1 -MemoryStartupBytes 2GB

#This command will change our memory to Dynamic and also set our maximum RAM to 8GB so we should have no issues running this.
Set-VM -DynamicMemory -Name Testmachine1 -MemoryMinimumBytes 500MB -MemoryMaximumBytes 8GB

#This command creates a new virtual hard disk
New-VHD -Path c:\vm-Machine1\Testmachine\Testmachine.vhdx -SizeBytes 25GB -Dynamic

#This command attachs our new VHD to the VM
Add-VMHardDiskDrive -VMName Testmachine1 -path C:\vm-machine1\Testmachine\Testmachine1.vhdx

#This command is used to map an ISO image to the VM CD/DVD
Set-VMDvdDrive Testmachine1 -ControllerNumber 1 -Path C:\Users\Administrator\Downloads\Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO

#This command starts the new VM.
Start-VM -Name Testmachine1

#This command will create both NIC's for you.
Add-VMNetworkAdapter -ManagementOS -SwitchName Management -Name VMNIC1
Add-VMNetworkAdapter -ManagementOS -SwitchName DMZ -Name VMNIC2

#This command is used to list your VM's then you are able to remotely connnect to it and send commands through PS.
Get-VM
Enter-PSSession -VMName Testmachine1

#This command is used to install the Web Server also known as IIS.
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
Import-Module WebAdministration

#This command is used to overwite the default IISstart page with a Hello World one.
Set-Content C:\inetpub\wwwroot\iisstart.htm '<html>Hello World</html>'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~