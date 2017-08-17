Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
$scriptFolder = $MyInvocation.MyCommand.Definition | split-path -parent 
$Sta = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-f setVarsAndStart.ps1" -WorkingDirectory "$($scriptFolder)\"
$Stt = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 15) -RepetitionDuration (New-TimeSpan -Days (365 * 20))
$Stp = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -RunLevel Highest
Register-ScheduledTask -TaskName DumpMonitorTask -Action $Sta -Trigger $Stt -Principal $Stp