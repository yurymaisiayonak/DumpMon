Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

#count of info that stored at the same time
$countOfDumps = 2
$countOfLogs = 2

#ftp settings
$ftpLogin = ""
$ftpPassword = ""
$ftpAddress = "ftp.soft-fx.lv"
$ftpLocalFolder = ($MyInvocation.MyCommand.Definition | split-path -parent)+"\Dumps"
$ftpRemoteFolder = "/TickTrader/AdminTools/dumps"


#list of processes and thresholdes
$processes = @("devenv.exe","notepad.exe")
$threshold = 20000 #in bytes

#for email sending
$emailsToSend = "yahor.mazko@soft-fx.lv"
$login = "staging@st.soft-fx.eu"
$password = "detre@Re5h"
$SMTPServer = "mx.st.soft-fx.eu"
$SMTPPort = "25"

$scriptFolder = $MyInvocation.MyCommand.Definition | split-path -parent
cd $scriptFolder

& .\DumpMonitor.ps1