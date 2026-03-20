# ================================================================
#         SentinelPS — Active Defense & Deception Framework
#         Author  : Zeel
#         Domain  : Blue Team Cybersecurity
#         Modules : Honey Account Manager | Honey Account Monitor
# ================================================================

#Requires -RunAsAdministrator

# ── Global Config ───────────────────────────────────────────────
$Global:LogDir     = "C:\SentinelPS\Logs"
$Global:AlertLog   = "$Global:LogDir\alerts.json"
$Global:HoneyUsers = @("svc_backup_old", "admin_temp", "helpdesk_legacy", "CEO_assistant")

# ── Setup Directories ────────────────────────────────────────────
function Initialize-SentinelPS {
    if (-not (Test-Path $Global:LogDir)) {
        New-Item -ItemType Directory -Path $Global:LogDir -Force | Out-Null
    }
}

# ── Banner ───────────────────────────────────────────────────────
function Show-Banner {
    Clear-Host
    $banner = @"

  ███████╗███████╗███╗   ██╗████████╗██╗███╗   ██╗███████╗██╗     ██████╗ ███████╗
  ██╔════╝██╔════╝████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝██║     ██╔══██╗██╔════╝
  ███████╗█████╗  ██╔██╗ ██║   ██║   ██║██╔██╗ ██║█████╗  ██║     ██████╔╝███████╗
  ╚════██║██╔══╝  ██║╚██╗██║   ██║   ██║██║╚██╗██║██╔══╝  ██║     ██╔═══╝ ╚════██║
  ███████║███████╗██║ ╚████║   ██║   ██║██║ ╚████║███████╗███████╗██║     ███████║
  ╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝╚═╝     ╚══════╝

                   Active Defense & Deception Framework v1.0
                         Blue Team | Author: Zeel
"@
    Write-Host $banner -ForegroundColor Cyan
    Write-Host "  ═══════════════════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
}

# ── Live Log Function ────────────────────────────────────────────
function Write-Alert {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $colors = @{ "INFO" = "Cyan"; "WARN" = "Yellow"; "CRITICAL" = "Red"; "KILL" = "Magenta"; "OK" = "Green" }
    $color = $colors[$Level]
    Write-Host "  [$timestamp] " -ForegroundColor DarkGray -NoNewline
    Write-Host "[$Level] " -ForegroundColor $color -NoNewline
    Write-Host $Message -ForegroundColor White

    # Save to JSON log
    $entry = [PSCustomObject]@{
        Time    = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        Level   = $Level
        Message = $Message
    }
    $existing = @()
    if (Test-Path $Global:AlertLog) {
        $raw = Get-Content $Global:AlertLog -Raw
        if ($raw) { $existing = @($raw | ConvertFrom-Json) }
    }
    $existing += $entry
    $existing | ConvertTo-Json -Depth 3 | Out-File $Global:AlertLog -Force -Encoding UTF8
}

# ================================================================
#  MODULE 1 — HONEY ACCOUNT MANAGER
# ================================================================
function Module-HoneyAccounts {
    Write-Host "`n  ══════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "   MODULE 1 : HONEY ACCOUNT MANAGER" -ForegroundColor Cyan
    Write-Host "  ══════════════════════════════════════`n" -ForegroundColor DarkCyan

    Write-Host "  [1] Deploy Honey Accounts" -ForegroundColor White
    Write-Host "  [2] List Honey Accounts" -ForegroundColor White
    Write-Host "  [3] Remove Honey Accounts" -ForegroundColor White
    Write-Host "  [4] Back to Main Menu`n" -ForegroundColor DarkGray
    $choice = Read-Host "  Select"

    switch ($choice) {
        "1" {
            Write-Alert "Deploying Honey Accounts in Active Directory..." "INFO"
            foreach ($user in $Global:HoneyUsers) {
                try {
                    $exists = Get-ADUser -Filter "SamAccountName -eq '$user'" -ErrorAction SilentlyContinue
                    if (-not $exists) {
                        $pass = ConvertTo-SecureString "Honey@1234!" -AsPlainText -Force
                        New-ADUser -Name $user `
                            -SamAccountName $user `
                            -UserPrincipalName "$user@sentinel.local" `
                            -AccountPassword $pass `
                            -Enabled $true `
                            -Description "Service Account - DO NOT DELETE" `
                            -PasswordNeverExpires $true
                        Write-Alert "Honey Account DEPLOYED: $user" "OK"
                    } else {
                        Write-Alert "Already exists (skipping): $user" "WARN"
                    }
                } catch {
                    Write-Alert "Failed to create $user : $($_.Exception.Message)" "WARN"
                }
            }
            Write-Alert "All Honey Accounts deployed. Trap is SET." "OK"
            Pause
        }
        "2" {
            Write-Alert "Listing Honey Accounts..." "INFO"
            foreach ($user in $Global:HoneyUsers) {
                $u = Get-ADUser -Filter "SamAccountName -eq '$user'" `
                     -Properties LastLogonDate, Enabled -ErrorAction SilentlyContinue
                if ($u) {
                    Write-Host "  ► $($u.SamAccountName) | Enabled: $($u.Enabled) | Last Logon: $($u.LastLogonDate)" -ForegroundColor Yellow
                } else {
                    Write-Host "  ✗ $user — Not Found" -ForegroundColor DarkGray
                }
            }
            Pause
        }
        "3" {
            Write-Alert "Removing all Honey Accounts..." "WARN"
            foreach ($user in $Global:HoneyUsers) {
                try {
                    Remove-ADUser -Identity $user -Confirm:$false -ErrorAction SilentlyContinue
                    Write-Alert "Removed: $user" "OK"
                } catch {
                    Write-Alert "Could not remove: $user" "WARN"
                }
            }
            Write-Alert "All Honey Accounts removed." "OK"
            Pause
        }
        "4" { return }
    }
}

# ================================================================
#  MODULE 2 — HONEY ACCOUNT MONITOR
# ================================================================
function Module-HoneyMonitor {
    Write-Host "`n  ══════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "   MODULE 2 : HONEY ACCOUNT MONITOR" -ForegroundColor Cyan
    Write-Host "  ══════════════════════════════════════`n" -ForegroundColor DarkCyan

    Write-Alert "Starting live monitor — watching Honey Accounts for login attempts..." "INFO"
    Write-Alert "Press Ctrl+C to stop monitoring.`n" "WARN"

    $seen = @{}

    while ($true) {
        foreach ($user in $Global:HoneyUsers) {
            try {
                $u = Get-ADUser -Identity $user `
                     -Properties LastLogonDate, BadLogonCount, LockedOut `
                     -ErrorAction SilentlyContinue
                if ($u) {
                    $key = "$user|$($u.LastLogonDate)|$($u.BadLogonCount)"
                    if ($seen[$user] -ne $key) {
                        if ($u.BadLogonCount -gt 0) {
                            Write-Alert "HONEY ACCOUNT ATTACKED! User: $user | Failed Attempts: $($u.BadLogonCount)" "CRITICAL"
                        }
                        if ($u.LastLogonDate -and ($u.LastLogonDate -gt (Get-Date).AddMinutes(-2))) {
                            Write-Alert "HONEY ACCOUNT LOGGED IN! User: $user | Time: $($u.LastLogonDate)" "CRITICAL"
                            Write-Alert "CONFIRMED ATTACKER ACTIVITY DETECTED — Investigate immediately!" "CRITICAL"
                        }
                        $seen[$user] = $key
                    }
                }
            } catch {}
        }

        # Check Security Event Log (4625 = failed, 4624 = success)
        try {
            $events = Get-WinEvent -FilterHashtable @{
                LogName   = 'Security'
                Id        = @(4624, 4625)
                StartTime = (Get-Date).AddSeconds(-10)
            } -ErrorAction SilentlyContinue

            foreach ($evt in $events) {
                $xml   = [xml]$evt.ToXml()
                $uname = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq "TargetUserName" }).'#text'
                if ($Global:HoneyUsers -contains $uname) {
                    $evtType = if ($evt.Id -eq 4624) { "SUCCESSFUL LOGIN" } else { "FAILED LOGIN" }
                    Write-Alert "EVENT $($evt.Id) — $evtType on HONEY ACCOUNT: $uname" "CRITICAL"
                }
            }
        } catch {}

        Write-Host "  [$(Get-Date -Format 'HH:mm:ss')] Monitoring... " -ForegroundColor DarkGray -NoNewline
        Write-Host "Honey Accounts: $($Global:HoneyUsers.Count) active traps" -ForegroundColor DarkCyan
        Start-Sleep -Seconds 5
    }
}

# ================================================================
#  MAIN MENU
# ================================================================
function Show-Menu {
    Write-Host "`n  ══════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "              MAIN MENU" -ForegroundColor Cyan
    Write-Host "  ══════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "  [1]  Honey Account Manager  (AD Deception)" -ForegroundColor White
    Write-Host "  [2]  Honey Account Monitor  (Live AD Watch)" -ForegroundColor White
    Write-Host "  [0]  Exit`n" -ForegroundColor DarkGray
}

# ================================================================
#  ENTRY POINT
# ================================================================
Initialize-SentinelPS
Show-Banner

while ($true) {
    Show-Menu
    $input = Read-Host "  Select Module"
    switch ($input) {
        "1" { Module-HoneyAccounts }
        "2" { Module-HoneyMonitor }
        "0" { Write-Host "`n  [*] SentinelPS terminated. Stay safe.`n" -ForegroundColor Cyan; exit }
        default { Write-Alert "Invalid option. Choose 1, 2 or 0." "WARN" }
    }
}