# DumpMonitor
Created PowerShell script for performance monitoring.

# What does it do
 - Create dump for process where memory size exceeds Threshold;
 - Upload dump to FTP;
 - Send email with result of work;

# How do make it work 
 You have two configuration files.
 1) setVarsAndStart.ps1 - sets variables and starts monitoring process
 	- set countOfDumps - max count of folders where dumps will be saved  (if resulting count > countOfDumps more early folders will removed);
	- set countOfLogs - max count of Log files (if resulting count > countOfLogs more early folders will removed);
	- set ftp setting (ftpLogin, ftpPassword, ftpAddress, ftpLocalFolder, ftpRemoveFolder); 
	- set processes - array of monitoring processes;
	- set threshold - in bytes;
	- set email sending;
 2) createTask.ps1 - creates a task in Task Scheduler (it automaticaly runs script setVarsAndStart.ps1 every time as you set) 
 	- set TaskName (by default - DumpMonitorTask);
	- set RepetitionInterval (by default - 15 minutes) and RepetitionDuration(by default - 20 years);
 
 All parameters set as String or String array.
 - run setVarsAndStartScript.ps1;
 - run createTask.ps1;
 - check your email (message with result of work should be sent);
 - See results on your ftp server.
  
