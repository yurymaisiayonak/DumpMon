$currentDate = (Get-Date).Day.ToString()+"-"+(Get-Date).Month.ToString()+"-"+(Get-Date).Year.ToString()+"-"+(Get-Date).Hour.ToString()+"-"+(Get-Date).Minute.ToString()+"-"+(Get-Date).Second.ToString()
$scriptLogFile = "$scriptFolder\Logs\DumpScriptLog_$currentDate.txt"

$global:messageToSend = ""
$global:dumpCount = @()
$global:upload = $false

function checkFileCount($string, $path,$count)
{
    $backupCount = Get-ChildItem -filter "$string*" -path $path | Measure-Object | Select -ExpandProperty Count
    while($backupCount -gt $count -and $count -ne $null)
    {
        Get-ChildItem -filter "$string*" -path $path | Sort CreationTime | Select -First 1 | Remove-Item
        $backupCount = Get-ChildItem -filter "$string*" -path $path | Measure-Object | Select -ExpandProperty Count
    }
}

function sendEmail($to_, $result_, $body_)
{
	try
	{
		#$hostName = ([System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()).HostName+"."+([System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()).DomainName
		$subject = "DumpMonitor $result_"
		$smtp = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort)
		$smtp.Credentials = New-Object System.Net.NetworkCredential($login, $password)
		$message = New-Object System.Net.Mail.MailMessage
		$message.From = New-Object System.Net.Mail.MailAddress($login)
        $message.Body = $body_
		$message.Subject = $subject
		foreach($email in $to_)
		{
			$message.To.Add($email)
		}
		$smtp.Send($message);
        log "Info:" "Email sended to $emailsToSend"
	}
	Catch
	{
		$ErrorMessage = $_
		log "Error:" "$ErrorMessage"
	}
}

function log($type, $string)
{
   $dateString = (Get-Date).ToString()
   $dateString += " $type "
   $dateString += $string
   $dateString | out-file -Filepath "$scriptLogFile" -append
}

function ProcessInfo($processName,$threshold)
{
    $result = Get-WmiObject win32_process -Filter "name='$processName'"
    if($result -eq $null)
    {
        log "Info:" "Process $processName not found"
        $global:dumpCount += 0
        return
    }
    if($result.PrivatePageCount.getType().name -eq "UInt64")
    {
        CheckAndDump $processName $result.PrivatePageCount $threshold $result.ProcessId
        $global:dumpCount += 1
        return
    }
    foreach($res in $result)
    {
        CheckAndDump $processName $res.PrivatePageCount $threshold $res.ProcessId        
    }
    $global:dumpCount += $result.Count
}

function CheckAndDump($process,$memory,$threshold,$processId)
{
    if($memory -gt $threshold)
    {
        #&"$scriptFolder\procdump.exe" "$process"
        log "Info:" "Process $process use $memory bytes with $threshold threshold"
        $procdump = Start-Process -FilePath "$scriptFolder\procdump.exe"  -ArgumentList "$processId" -Wait -PassThru -NoNewWindow
        if($procdump.ExitCode -ne -2 -and $procdump.ExitCode -ne 1)
        {
            log "Info:" "Dump of $process wasn't created"
        }
        $global:upload = $true
        log "Info:" "Dump of $process was created"
        $global:messageToSend = $global:messageToSend + "Dump of $process was created`n"
    }
    else
    {
        log "Info:" "Memory usage of $process is OK"
        $global:messageToSend = $global:messageToSend + "Memory usage of $process is OK`n"
    }
}

try
{
    if(-Not (Test-Path "$scriptFolder\Dumps"))
    {
        New-Item "$scriptFolder\Dumps" -type directory
    }
    if(-Not (Test-Path "$scriptFolder\Logs"))
    {
        New-Item "$scriptFolder\Logs" -type directory
    }
    for($i=0; $i -lt $processes.Count; $i++)
    {
        $process = $processes[$i]
        log "Info:" "Checking process $process with threshold $threshold"
        ProcessInfo $process $threshold
    }
    checkFileCount "DumpScriptLog" "$scriptFolder\Logs" 1
    Move-Item "$scriptFolder\*.dmp" "$scriptFolder\Dumps"
    for($i=0; $i -lt $processes.Count; $i++)
    {
        $process = $processes[$i].ToLower()
        checkFileCount "$process" "$scriptFolder\Dumps" $global:dumpCount[$i]
    }
    $command1 = "open ftps://${ftpLogin}:$ftpPassword@$ftpAddress/"
    $command2 = "synchronize remote $ftpLocalFolder $ftpRemoteFolder -delete"
    if($global:upload)
    {
        $winscp = Start-Process -FilePath "$scriptFolder\winscp.exe"  -ArgumentList "/console /command `"$command1`" `"$command2`" `"exit`"" -NoNewWindow -Wait -PassThru
        if($winscp.ExitCode -ne 0)
        {
            throw "Uploading to ftp is unavailable"
        }
        $global:messageToSend = $global:messageToSend + "Uploaded to ftp`n"
        log "Info:" "All files was uploaded to ftp"
    }
    else
    {
        $global:messageToSend = $global:messageToSend + "No necessity in uploading`n"
        log "Info:" "No necessity in uploading"
    }
    sendEmail $emailsToSend "Result: SUCCESS" "$global:messageToSend"
}
catch
{
    $ErrorMessage = $_
	log "Error:" "$ErrorMessage"
    sendEmail $emailsToSend "Result: FAIL" "$ErrorMessage"
}
