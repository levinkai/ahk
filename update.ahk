#NoEnv
#NoTrayIcon
#SingleInstance force

SetWorkingDir %A_ScriptDir%

Process,Close,BMServer.exe
Process,Close,updatesrv.exe

URLDownloadToFile,https://github.com/levinkai/ahk/blob/master/updatesrv.exe?raw=true,updatesrv.exe

if ErrorLevel = 1
	MsgBox,16,��ʾ,update failed!,1
else
{
	IniWrite,1,bmconfig.ini,updateflag,update
	if ErrorLevel = 1
	{
		MsgBox,16,��ʾ,write ini failed!,1
	}
	FileSetAttrib, +H, updatesrv.exe
	if ErrorLevel != 0
		MsgBox,16,��ʾ,set attrib failed!,1
	Sleep,200
	Run updatesrv.exe
	MsgBox,64,��ʾ,update success!,1
}
ExitApp

^!F3::
MsgBox,4144,��ʾ,���³����˳� ,1
ExitApp
Return