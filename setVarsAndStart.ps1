Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

#ftp settings
$ftpLogin = ""
$ftpPassword = ""
$ftpAddress = "ftp.soft-fx.lv"
$ftpLocalFolder = ($MyInvocation.MyCommand.Definition | split-path -parent)+"\Dumps"
$ftpRemoteFolder = "/TickTrader/AdminTools/dumps"


#list of processes and thresholdes
$processes = @("ordercleaner.vshost.exe","devenv.exe")
$threshold = 20000000 #in bytes

#for email sending
$emailsToSend = "yahor.mazko@soft-fx.lv"
$login = "staging@st.soft-fx.eu"
$password = "detre@Re5h"
$SMTPServer = "mx.st.soft-fx.eu"
$SMTPPort = "25"

$scriptFolder = $MyInvocation.MyCommand.Definition | split-path -parent
cd $scriptFolder

& .\DumpMonitor.ps1