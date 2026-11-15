#!/usr/bin/env pwsh
#Requires -Modules Posh-SSH

<#
.SYNOPSIS
    Command execution using ssh.
.DESCRIPTION
    Execute command on the host connected using ssh.
.NOTES
    Author: Hajimu UMEMOTO <ume@mahoroba.org>
    Version: 0.0
    Created: 2026-11-15
#>

$server = "SERVER"
$user = "USER"
$password = "PASSWORD"
$command = "COMMAND"

# Import-Module Posh-SSH

$logFile = '~\tmp\xxx.log'

# 資格情報の作成
$secPassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.AUtomation.PSCredential($user, $secPassword)

$Session = $null
$resultCode = 0
try {
    # SSH接続
    $sessionParams = @{
        ComputerName      = $server
        Credential        = $credential
        ConnectionTimeout = 10
        AcceptKey         = $true
        ErrorAction       = 'Stop'
    }
    $session = New-SSHSession @sessionParams

    # コマンド実行
    $commandParam = @{
        Index       = $session.sessionid
        Command     = $command
        ErrorAction = 'Stop'
    }
    $response = Invoke-SSHCommand @commandParam
    if ($response.ExitStatus -ne 0) {
        throw $response.Error.TrimEnd()
    }
    $response.Output | Out-File -FilePath $logFile -Append -Encoding default
} catch {
    Write-Error "$($_.Exception.Message)" -ErrorVariable err -ErrorAction SilentlyContinue
    "[ERROR] $($err.Exception.Message)" | Out-File -FilePath $logFile -Append -Encoding default
    $resultCode = 1
}

if ($null -ne $session) {
    Remove-SSHSession -SessionId $session.SessionId | Out-Null
}
exit $resultCode
