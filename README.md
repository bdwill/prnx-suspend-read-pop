# PernixData Suspend and Resume Read Cache Population

This script enables the ability to suspend and resume the read cache population operations for a particular VM as needed. This is most common during Oracle RMAN backups or other backup and copy operations to a VMDK that is attached to the VM being accelerated. This allows large sequential reads to not be cached into flash which typically evicts otherwise hot VM data and can affect VM performance after backup operations.

## Limitations

This script only works for suspending and resuming read cache population for one VM.

## To Do

* Implement read, write, or read/write capabilities
* Enable selection or listing of multiple VMs to use

## Prerequisites 

*The following must be installed on a VM in the management cluster or the PernixData management server (where it is installed by default):*

* PernixData PowerShell cmdlets

## Usage

* Download zip file or clone this repository.
* Open a PowerShell command prompt on the server and execute: Read-Host -AsSecureString -prompt "Enter password" | ConvertFrom-SecureString | Out-File fvp_enc_pass.txt 
* Enter the username and password for the service account or username that is being used for FVP management server.
* Edit PrnxReadPopulation.ps1 to include the username and IP address/FQDN used for the PernixData management server.
* Temporary files will be stored in c:\temp. Change this if necessary.
* Modify VNAME on line 22 to be the name of the VM that will have the read cache population suspended.
* Create a new Windows task and schedule it to run at the appropriate time.
* For pre-backup operations, the command that will be run is C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -Command C:\<FOLDER_WHERE_YOU_STORED_SCRIPT>\PrnxReadPopulation.ps1 -VMName 'VM Name Here' -Mode ReadsOff
* For post-backup operations, the command that will be run is C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -Command C:\<FOLDER_WHERE_YOU_STORED_SCRIPT>\PrnxReadPopulation.ps1 -VMName 'VM Name Here' -Mode ReadsOn