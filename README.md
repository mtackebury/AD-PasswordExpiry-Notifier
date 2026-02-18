# AD Password Expiry Notifier

A PowerShell automation tool that monitors Active Directory user accounts for upcoming password expiration and outputs actionable data for notifications, reporting, or SIEM ingestion.

## 🚀 Overview

Expired passwords are a common cause of help desk tickets, account lockouts, and productivity loss.  
This script queries Active Directory for users whose passwords are expired or nearing expiration and produces structured output suitable for:

- Email notifications
- Syslog / SIEM ingestion
- CSV reporting
- Scheduled compliance checks

Built for modern Active Directory environments using the computed attribute:

`msDS-UserPasswordExpiryTimeComputed`

---

## ✨ Features

- Detects expired passwords
- Identifies users nearing expiration (configurable thresholds)
- Supports multiple warning windows (e.g., 14, 7 days)
- Excludes non-expiring accounts
- Optional inclusion of disabled accounts
- Outputs structured objects (ideal for automation pipelines)
- Supports OU scoping via `-SearchBase`

---

## 🧰 Requirements

- Windows PowerShell 5.1+ or PowerShell 7+
- Active Directory module (RSAT)
- Domain connectivity and permissions to query AD

Install RSAT (Windows 10/11):

```powershell
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
```

---

## 📂 Script

**Notify-ADPasswordExpiry.ps1**

---

## ⚙️ Usage

### Basic Run

```powershell
.\Notify-ADPasswordExpiry.ps1
```

---

### Custom Warning Thresholds

```powershell
.\Notify-ADPasswordExpiry.ps1 -WarnDays 21,14,7
```

---

### Include Disabled Accounts

```powershell
.\Notify-ADPasswordExpiry.ps1 -IncludeDisabled
```

---

### Limit to an OU

```powershell
.\Notify-ADPasswordExpiry.ps1 -SearchBase "OU=Users,DC=corp,DC=local"
```

---

## 📊 Example Output

```text
Name            : John Doe
SamAccountName  : jdoe
Enabled         : True
Email           : jdoe@corp.local
PasswordLastSet : 1/10/2026 8:42:12 AM
ExpiresOn       : 2/10/2026 8:42:12 AM
DaysLeft        : 5
Status          : ExpiringSoon-7
```

---

## 📤 Export to CSV

```powershell
.\Notify-ADPasswordExpiry.ps1 |
Export-Csv .\PasswordExpiryReport.csv -NoTypeInformation
```

---

## 📧 Email Report Example

```powershell
$report = .\Notify-ADPasswordExpiry.ps1

$body = $report | ConvertTo-Html | Out-String

Send-MailMessage `
    -To "it-admins@corp.local" `
    -From "ad-monitor@corp.local" `
    -Subject "AD Password Expiry Report" `
    -Body $body `
    -BodyAsHtml `
    -SmtpServer "smtp.corp.local"
```

---

## 📡 Syslog / SIEM Integration Example

```powershell
.\Notify-ADPasswordExpiry.ps1 |
ForEach-Object {
    $msg = "AD Password Alert: $($_.SamAccountName) - $($_.Status) ($($_.DaysLeft) days)"
    Send-SyslogMessage -Message $msg -Server "10.0.0.10" -Port 514
}
```

*(Implement `Send-SyslogMessage` according to your environment.)*

---

## ⏰ Scheduling

This script is designed to run as a scheduled task.

### Example: Daily Check

1. Open **Task Scheduler**
2. Create Task → Run whether user is logged in or not
3. Action:

```text
Program/script: powershell.exe
Arguments: -File "C:\Scripts\Notify-ADPasswordExpiry.ps1"
```

---

## 🔐 Security Considerations

- Requires read access to Active Directory user attributes
- Avoid sending reports externally without data review
- Consider excluding service accounts from notifications
- Use secure SMTP where possible

---

## 🛣️ Roadmap

Planned enhancements:

- Per-user email notifications
- HTML email templates
- Syslog sender module
- Service account exclusion list
- Logging & rotation
- Azure AD / Entra ID support

---

## 📜 License

MIT License — free to use and modify.

---

## 🤝 Contributing

Pull requests welcome. Suggestions and improvements are encouraged.

---

## 👤 Author

Created by an infrastructure & automation engineer focused on improving identity hygiene and operational efficiency.
