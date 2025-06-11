<#
.SYNOPSIS
    Disables clipboard (text & image) and drive redirection in RDP sessions.

.DESCRIPTION
    Applies the following Group Policy–style registry settings under HKLM:
      • Prevent users from mapping their local drives into the remote session.
      • Prevent users from using clipboard copy/paste between local and remote
        (both client-side and session-host side).

    Finally forces a Group Policy update so the changes take effect immediately.

.NOTES
    • Must be run as Administrator.
    • Tested on Windows 10/11, Windows Server 2016+.
    • To re-enable redirection, delete these DWORDs or set them back to 0.
#>

#region Elevation Check
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as Administrator."
    exit 1
}
#endregion

Write-Host "Disabling RDP clipboard and drive redirection..." -ForegroundColor Cyan

# 1) Session-Host side policies
#    HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services
$sessionHostKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
New-Item -Path $sessionHostKey -Force | Out-Null

# 1a) Disable drive mapping (client drives)
Set-ItemProperty -Path $sessionHostKey -Name 'fDisableCdm' `
    -Type DWord -Value 1
Write-Host "  • fDisableCdm (drive redirection) = 1" -ForegroundColor Green

# 1b) Disable clipboard redirection (host side)
Set-ItemProperty -Path $sessionHostKey -Name 'fDisableClipboardRedirection' `
    -Type DWord -Value 1
Write-Host "  • fDisableClipboardRedirection (host) = 1" -ForegroundColor Green

# 2) Client-side policy (for Remote Desktop Connection Client)
#    HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client
$clientKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client'
New-Item -Path $clientKey -Force | Out-Null

# 2a) Disable clipboard redirection (client side)
Set-ItemProperty -Path $clientKey -Name 'fDisableClip' `
    -Type DWord -Value 1
Write-Host "  • fDisableClip (client) = 1" -ForegroundColor Green

# 3) Force a Group Policy update so settings apply immediately
Write-Host "`nForcing a Group Policy update..." -ForegroundColor Cyan
gpupdate.exe /force | Out-Null

Write-Host "`nDone. Drive mapping and all clipboard (text & images) redirection are now disabled for new RDP sessions." -ForegroundColor Cyan
