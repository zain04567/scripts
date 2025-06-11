<#
.SYNOPSIS
    Flushes the DNS resolver cache.

.DESCRIPTION
    Clears the DNS client cache via PowerShell and ipconfig.
    Attempts to restart the DNS Client service; if that fails,
    the script will warn you but not abort (since some systems
    protect Dnscache from being stopped).

.NOTES
    - Must be run as Administrator.
    - Tested on Windows 10/11 and Windows Server 2016+.
#>

#region Elevation Check
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script must be run as Administrator."
    exit 1
}
#endregion

Write-Host "Flushing DNS client cache..." -ForegroundColor Cyan

# 1) Clear via PowerShell
try {
    Clear-DnsClientCache -ErrorAction Stop
    Write-Host "  • Cleared DNS client cache via Clear-DnsClientCache." -ForegroundColor Green
}
catch {
    Write-Warning "  • Could not run Clear-DnsClientCache: $_"
}

# 2) Fallback with ipconfig
try {
    ipconfig /flushdns | Out-Null
    Write-Host "  • Flushed DNS resolver cache via ipconfig /flushdns." -ForegroundColor Green
}
catch {
    Write-Warning "  • ipconfig /flushdns failed: $_"
}

# 3) Try to restart the DNS Client service, but don’t error out if it can’t be stopped
Write-Host "Attempting to restart the DNS Client service..." -ForegroundColor Cyan
try {
    Restart-Service -Name Dnscache -Force -ErrorAction Stop
    Write-Host "  • DNS Client service restarted." -ForegroundColor Green
}
catch {
    Write-Warning "  • Could not restart DNS Client service: $_"
    Write-Warning "    (This is expected on some systems where Dnscache is protected.)"
}

Write-Host "`nDone. Your DNS cache has been flushed." -ForegroundColor Cyan
