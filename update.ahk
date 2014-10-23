#NoEnv
#NoTrayIcon
#SingleInstance force

SetWorkingDir %A_ScriptDir%

Process,Close,BMServer.exe
Process,Close,updatesrv.exe

URLDownloadToFile,https://github.com/levinkai/ahk/blob/master/updatesrv.exe?raw=true,updatesrv.exe

if ErrorLevel = 1
	MsgBox,16,提示,update failed!,1
else
{
	update_flag = 1
	IniWrite,update_flag,bmconfig.ini,updateflag,update
	Run updatesrv.exe
	MsgBox,64,提示,update success!,1
}

ExitApp