<#
.SYNOPSIS
    Blocks FTP (21), SSH/SFTP (22) and SMB (445) by firewall rule—both inbound and outbound.

.DESCRIPTION
    - Creates Windows Firewall rules to block TCP traffic on ports 21, 22, and 445.
    - Applies to all profiles (Domain, Private, Public).
    - If you re-run, existing rules with the same names are first removed to avoid duplicates.

.NOTES
    - Must be run as Administrator.
    - Tested on Windows 10/11 and Windows Server 2016+.
#>

# --- 1) Elevation check ---
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator."
    exit 1
}

# --- 2) Define ports and rule names ---
$services = @(
    @{ Name = "FTP"; Port = 21 },
    @{ Name = "SSH_SFTP"; Port = 22 },
    @{ Name = "SMB"; Port = 445 }
)

# --- 3) Remove any existing conflicting rules, then create new block rules ---
foreach ($svc in $services) {
    $svcName    = $svc.Name
    $port       = $svc.Port
    $inbound    = "Block Inbound $svcName ($port)"
    $outbound   = "Block Outbound $svcName ($port)"

    # Remove old rules if present
    Get-NetFirewallRule -DisplayName $inbound  -ErrorAction SilentlyContinue | Remove-NetFirewallRule -Confirm:$false
    Get-NetFirewallRule -DisplayName $outbound -ErrorAction SilentlyContinue | Remove-NetFirewallRule -Confirm:$false

    # Create Inbound block
    New-NetFirewallRule `
        -DisplayName $inbound `
        -Direction Inbound `
        -Protocol TCP `
        -LocalPort $port `
        -Action Block `
        -Profile Any `
        -Description "Block inbound $svcName traffic on port $port" | Out-Null

    # Create Outbound block
    New-NetFirewallRule `
        -DisplayName $outbound `
        -Direction Outbound `
        -Protocol TCP `
        -RemotePort $port `
        -Action Block `
        -Profile Any `
        -Description "Block outbound $svcName traffic on port $port" | Out-Null

    Write-Host "Created firewall rules to block $svcName on port $port (in+out)." -ForegroundColor Cyan
}

Write-Host "`nAll specified ports are now blocked. Verify with `Get-NetFirewallRule`." -ForegroundColor Green
