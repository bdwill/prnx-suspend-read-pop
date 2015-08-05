Param ( 
    [Parameter(Mandatory=$true)][string]$VMName
    [Parameter(Mandatory=$true)][ValidateSet("ReadsOn", "ReadsOff")][string]$Mode
)

Function WriteLog
{
   Param ([string]$logstring)
   $logstring = "$(Get-Date -format s) - " + $logstring
   $logstring | out-file -Filepath $logfile -append
}

Add-PSSnapin VMware.VimAutomation.Core -ErrorAction Stop
Add-PSSnapin VeeamPSSnapIn -ErrorAction Stop

# Initialize variables
$logfilepath = "C:\temp"
$logfile = $logfilepath + "\fvp_$(get-date -f yyyy_MM_dd_HH_mm_ss).log"
$passwordfile = $logfilepath + "\fvp_enc_pass.txt"
$fvp_server = "localhost"
$vcenter = "vcenter.lan.local"
$username = "domain\user"
$vmname = "VMNAME"

WriteLog "Retrieving encrypted password from file $passwordfile"
Try { 
        $enc_pass = Get-Content $passwordfile | ConvertTo-SecureString
    }
Catch { 
        WriteLog "Error retrieving encrypted password"
        Exit 1
    }

Try { 
        $credential = New-Object System.Management.Automation.PsCredential($username, $enc_pass)
    }
Catch {
        WriteLog "Error creating credential object"
        Exit 1
    }

WriteLog "Connecting to PernixData Management Server: $fvp_server"

Try {
        import-module prnxcli -ea Stop
        $prnx = Connect-PrnxServer -NameOrIpAddress $fvp_server -credentials $credential -ea Stop > $null
    }
Catch {
        WriteLog "Error connecting to FVP Management Server: $($_.Exception.Message)"
        exit 1
    }

if ($Mode -eq "ReadsOn") {
    try {
        WriteLog "Resuming read cache population"
        Resume-PrnxReadDataPopulation -ObjectIdentifier $vmname
    }
    catch {
        WriteLog "Error resuming read cache population $($_.Exception.Message)"
        exit 1
    }
} elseif ($Mode -eq "ReadsOff") {
    try {
        WriteLog "Suspending read cache population"
        Suspend-PrnxReadDataPopulation -ObjectIdentifier $vmname
    }
    catch {
        WriteLog "Error suspending read cache population $($_.Exception.Message)"
        exit 1
    }
}

