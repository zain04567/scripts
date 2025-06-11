<#
.SYNOPSIS
    Disables all webcam and virtual camera devices on the system.

.DESCRIPTION
    This script finds all devices in the "Camera" device class that are currently enabled,
    and disables them without prompting. Useful for locking down webcams (physical or virtual)
    in VM environments.

.NOTES
    - Must be run as Administrator.
    - Tested on Windows 10/11 and Windows Server 2016+.
    - To re-enable, change 'Disable-PnpDevice' to 'Enable-PnpDevice' below.

.EXAMPLE
    PS> .\Block-Webcams.ps1
#>

# Ensure script is running elevated
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You must run this script as Administrator."
    Exit 1
}

# Fetch all camera-class devices that are currently enabled (Status "OK" or "Error")
$cameraDevices = Get-PnpDevice -Class Camera | Where-Object { $_.Status -eq "OK" -or $_.Status -eq "Error" }

if ($cameraDevices.Count -eq 0) {
    Write-Host "No camera or virtual camera devices found."
    Exit 0
}

Write-Host "Found $($cameraDevices.Count) camera device(s). Disabling..." -ForegroundColor Cyan

foreach ($dev in $cameraDevices) {
    try {
        # Disable without confirmation
        Disable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false -ErrorAction Stop
        Write-Host "Disabled: $($dev.FriendlyName)" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to disable $($dev.FriendlyName): $_"
    }
}

Write-Host "All available camera devices have been targeted." -ForegroundColor Cyan
