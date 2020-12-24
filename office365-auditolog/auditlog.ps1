<#
.Objective
     Collect Office 365 audit logs, saving them in a json file

.Parameters
    startDate: Audit log initial date
    endDate: Audit log end date
    logFile: Name of the json file where the audit logs are going to be save
    loginAccount: Office 365 login account used to access the admin area

.Utilization sample
    .\auditlog.ps1 -startDate 11/01/2020 -endDate 11/30/2020 -logfile auditlogs.json -loginaccount some.user@somedomain.com

Author	: Renato Pinheiro de Souza
Version : v0.3
Date	: 24/12/2020
#>

param(
    [Parameter(Mandatory=$true)][String]$startDate,
    [Parameter(Mandatory=$true)][String]$endDate,
    [Parameter(Mandatory=$true)][String]$logFile,
    [Parameter(Mandatory=$true)][String]$loginAccount
    )

# Converting to date format
[datetime]$startDate = $startDate
[datetime]$endDate = $endDate

# Importing Exchange Module
Import-Module ExchangeOnlineManagement

# Connecting to Exchange Online
Connect-ExchangeOnline -UserPrincipalName $loginAccount

# Getting user list
$users = get-recipient | select PrimarySmtpAddress

# Counter
$counter = 1

# Getting the audit log for each user
foreach ($user in $users) {

    # Screen cleanning
    cls

    # Showing audit log collect period and progress
    $percentual = [math]::round((($counter / $users.Length) * 100),2) 
    Write-Host "Collecting audit logs from " $startDate " to " $endDate
    Write-Host "Completed " $percentual " %"

    # Getting individual user
    $user = "" + $user
    $user = $user.Substring(21,$user.Length - 22)
    Write-Host "User: " $user

    # Getting audit data    
    $logData = Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -UserIds $user -Formatted | select AuditData

    # Converting to json
    $jsonLogData = ConvertTo-Json $logData

    # Adding to file
    Add-Content -Path $logFile -Value $jsonLogData

    # Increasing counter to progress meter
    $counter += 1
}
