#requires -Modules ActiveDirectory
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [int[]]$WarnDays = @(14,7),
    [switch]$IncludeDisabled,
    [string]$SearchBase
)

function Convert-FileTimeToDateTime {
    [CmdletBinding()]
    param([Parameter(Mandatory)][long]$FileTime)
    [DateTime]::FromFileTime($FileTime)
}

$now = Get-Date
$warnDaysSorted = $WarnDays | Sort-Object

$adParams = @{
    Filter     = '*'
    Properties = @(
        'DisplayName','Enabled','Mail','PasswordNeverExpires','PasswordExpired','PasswordLastSet',
        'msDS-UserPasswordExpiryTimeComputed'
    )
}
if ($SearchBase) { $adParams.SearchBase = $SearchBase }

Get-ADUser @adParams |
Where-Object {
    $_.PasswordNeverExpires -ne $true -and
    $_.'msDS-UserPasswordExpiryTimeComputed' -and
    ($IncludeDisabled -or $_.Enabled -eq $true)
} |
ForEach-Object {
    $expiry = Convert-FileTimeToDateTime -FileTime $_.'msDS-UserPasswordExpiryTimeComputed'
    $daysLeft = [int](($expiry - $now).TotalDays)

    $status = if ($daysLeft -lt 0 -or $_.PasswordExpired) {
        'Expired'
    } else {
        # Find the smallest warn threshold the user is within (e.g., 7 before 14)
        $threshold = $warnDaysSorted | Where-Object { $daysLeft -le $_ } | Select-Object -First 1
        if ($null -ne $threshold) { "ExpiringSoon-$threshold" } else { 'OK' }
    }

    if ($status -ne 'OK') {
        [pscustomobject]@{
            Name            = $_.Name
            DisplayName     = $_.DisplayName
            SamAccountName  = $_.SamAccountName
            Enabled         = $_.Enabled
            Email           = $_.Mail
            PasswordLastSet = $_.PasswordLastSet
            ExpiresOn       = $expiry
            DaysLeft        = $daysLeft
            Status          = $status
        }
    }
} |
Sort-Object DaysLeft, Name
