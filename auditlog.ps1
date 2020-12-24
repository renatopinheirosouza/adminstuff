<#
.Purpose
     Collect Office 365 audit logs

.INPUTS
    startDate: Audit log initial date
    endDate: Audit log end date
    logFile: Audit log file path
    loginAccount: Office 365 login account

.Utilization Samples
    .\auditlog.ps1 -startDate 11/01/2020 -endDate 11/30/2020 -logfile teste.log -loginaccount adm.renato.pinheiro@bridgeconsulting.com.br

Author		: Renato Souza (renato.pinheiro@bridgeconsulting.com.br)
Version : v0.1
Date	: 23/12/2020
#>

param(
    [Parameter(Mandatory=$true)][String]$startDate,
    [Parameter(Mandatory=$true)][String]$endDate,
    [Parameter(Mandatory=$true)][String]$logFile,
    [Parameter(Mandatory=$true)][String]$loginAccount
    )

[datetime]$startDate = $startDate
[datetime]$endDate = $endDate

# Importing Exchange Module
Import-Module ExchangeOnlineManagement

# Connecting to Exchange Online
Connect-ExchangeOnline -UserPrincipalName $loginAccount

# Getting user list
$users = get-recipient | select PrimarySmtpAddress

# Creating collection
$logResults = @()

# Counter
$counter = 1

# Getting the audit log for each user
foreach ($user in $users) {

    # Screen cleanning
    cls

    # Showing perido and progress
    $percentual = [math]::round((($counter / $users.Length) * 100),2) 
    Write-Host "Collecting audit logs from " $startDate " to " $endDate
    Write-Host "Completed " $percentual " %"

    # Getting individual user
    $user = "" + $user
    $user = $user.Substring(21,$user.Length - 22)
    #echo $user

    # Getting audit data    
    $logData = Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -UserIds $user -Formatted | select AuditData

    # Converting to json
    $jsonLogData = ConvertTo-Json $logData

    # Adding to log file
    Add-Content -Path $logFile -Value $jsonLogData

    # Increasing counter
    $counter += 1
}
