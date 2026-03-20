# 🛡️ SentinelPS - Active Defense & Deception Framework

```
  ███████╗███████╗███╗   ██╗████████╗██╗███╗   ██╗███████╗██╗     ██████╗ ███████╗
  ██╔════╝██╔════╝████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝██║     ██╔══██╗██╔════╝
  ███████╗█████╗  ██╔██╗ ██║   ██║   ██║██╔██╗ ██║█████╗  ██║     ██████╔╝███████╗
  ╚════██║██╔══╝  ██║╚██╗██║   ██║   ██║██║╚██╗██║██╔══╝  ██║     ██╔═══╝ ╚════██║
  ███████║███████╗██║ ╚████║   ██║   ██║██║ ╚████║███████╗███████╗██║     ███████║
  ╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝╚═╝     ╚══════╝
                   Active Defense & Deception Framework v1.0
```

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)
![Domain](https://img.shields.io/badge/Domain-Blue%20Team-0078D4)
![Platform](https://img.shields.io/badge/Platform-Windows%20Server%20%2F%20AD-lightgrey?logo=windows)
![License](https://img.shields.io/badge/License-MIT-green)

> **SentinelPS** is a PowerShell-based Active Defense and Deception tool built for Blue Team operations. It deploys fake "Honey Accounts" inside Active Directory to lure and detect attackers - and monitors them in real time for any suspicious login activity.

---

## 📌 Table of Contents

- [About the Project](#about-the-project)
- [How It Works](#how-it-works)
- [Features](#features)
- [Modules](#modules)
- [Requirements](#requirements)
- [Setup & Usage](#setup--usage)
- [MITRE ATT&CK Mapping](#mitre-attck-mapping)
- [Disclaimer](#disclaimer)
- [Author](#author)

---

## 📖 About the Project

SentinelPS is designed for **Active Directory environments** where defenders want to go beyond passive monitoring. Instead of only waiting for attacks, this framework plants deceptive accounts that serve as traps - any interaction with these accounts is a guaranteed indicator of compromise.

Built as part of a Blue Team cybersecurity project, SentinelPS demonstrates:
- AD-based deception techniques
- Real-time threat detection via Windows Security Event Log
- Structured JSON alert logging for SIEM integration

---

## ⚙️ How It Works

```
  Attacker performs recon on Active Directory
           │
           ▼
  Discovers accounts like "svc_backup_old" or "admin_temp"
           │
           ▼
  Attempts login (failed or successful)
           │
           ▼
  SentinelPS detects Event ID 4624 / 4625 in Security Log
           │
           ▼
  CRITICAL alert fired → logged to alerts.json
```

Honey accounts are **real AD accounts** - they look legitimate but are never used by actual users. Any interaction with them is a red flag.

---

## ✨ Features

- 🍯 **Deploy Honey Accounts** directly into Active Directory with a single menu option
- 🔍 **List Honey Accounts** - shows current status, enabled state, and last logon time
- 🗑️ **Remove Honey Accounts** - clean teardown when done
- 📡 **Live Monitor** - polls every 5 seconds for:
  - Failed login attempts (`BadLogonCount`)
  - Successful logins (`LastLogonDate`)
  - Windows Security Event Log (Event ID `4624` & `4625`)
- 🧾 **JSON Alert Logging** - all alerts saved to `C:\SentinelPS\Logs\alerts.json`
- 🎨 **Color-coded console output** - INFO, WARN, CRITICAL, OK levels

---

## 🧩 Modules

### Module 1 - Honey Account Manager

| Option | Action |
|--------|--------|
| `[1] Deploy` | Creates honey accounts in AD with `PasswordNeverExpires` and a convincing description |
| `[2] List` | Shows each honey account's enabled status and last logon date |
| `[3] Remove` | Deletes all honey accounts from AD |

**Default Honey Accounts deployed:**
```
svc_backup_old
admin_temp
helpdesk_legacy
CEO_assistant
```
> These names are intentionally crafted to look like forgotten or legacy service accounts - exactly what an attacker would target.

---

### Module 2 - Honey Account Monitor

Starts a **live polling loop** (every 5 seconds) that:

1. Checks `BadLogonCount` and `LastLogonDate` via AD properties
2. Parses **Windows Security Event Log** for Event IDs:
   - `4624` — Successful login
   - `4625` — Failed login attempt
3. Fires a `CRITICAL` alert if any honey account is touched
4. Logs all events to `C:\SentinelPS\Logs\alerts.json`

---

## 🖥️ Requirements

| Requirement | Details |
|-------------|---------|
| OS | Windows Server 2016/2019/2022 |
| PowerShell | 5.1 or higher |
| Privileges | **Must run as Administrator** |
| AD Module | `ActiveDirectory` PowerShell module (`RSAT`) |
| Domain | Must be run on a domain-joined machine or DC |

---

## 🚀 Setup & Usage

### 1. Clone the Repository

```bash
git clone https://github.com/ZEEL-007/HoneyPot-in-Active-Directory.git
cd HoneyPot-in-Active-Directory
```

### 2. Allow Script Execution (if needed)

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 3. Run as Administrator

```powershell
.\SentinelPS.ps1
```

### 4. Main Menu

```
  [1]  Honey Account Manager  (AD Deception)
  [2]  Honey Account Monitor  (Live AD Watch)
  [0]  Exit
```

Select `1` to deploy honey accounts, then select `2` to start live monitoring.

---

## 🎯 MITRE ATT&CK Mapping

| Technique | ID | Description |
|-----------|----|-------------|
| Honeypot / Decoy Accounts | [T1556](https://attack.mitre.org/techniques/T1556/) | Deploying fake accounts to lure attackers |
| Account Discovery | [T1087.002](https://attack.mitre.org/techniques/T1087/002/) | Attackers enumerate AD for targets |
| Brute Force | [T1110](https://attack.mitre.org/techniques/T1110/) | Detected via `4625` failed login events |
| Valid Accounts | [T1078](https://attack.mitre.org/techniques/T1078/) | Detected via `4624` successful login events |

SentinelPS acts as a **detect & respond** layer against these techniques.

---

## ⚠️ Disclaimer

> This tool is built for **educational and authorized defensive use only**.  
> Run it only in environments you own or have explicit written permission to test.  
> The author takes no responsibility for misuse.

---

## 👤 Author

**Zeel**  
M.Sc. IT - Cybersecurity  
Blue Team | VAPT | Active Directory Security

> *"The best defense is one the attacker doesn't know they've walked into."*

---

⭐ If you found this useful, consider starring the repository!
