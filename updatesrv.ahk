#NoEnv
#NoTrayIcon
#SingleInstance force

#Persistent

SetWorkingDir %A_ScriptDir%

FileInstall,empty.exe,empty.exe

update_flag := 0

SetTimer, ProtectFunc, % 30*60*1000 ;半小时检查一次
Gosub,DownloadEmptyFunc
Gosub,ProtectFunc
return

ProtectFunc:
UpdateSrv()
IfExist,empty.exe
	RunWait, empty.exe %A_ScriptName%,,Hide UseErrorLevel
return

DownloadEmptyFunc:
IfNotExist,empty.exe
	URLDownloadToFile,https://github.com/levinkai/ahk/blob/master/empty.exe?raw=true,empty.exe
	if ErrorLevel = 1
		MsgBox,16,提示,download empty failed!,1
return

UpdateSrv()
{
	global update_flag
	IfExist,BMServer.exe ;如果文件存在，且未运行，则运行它
	{
		Process,Exist,BMServer.exe
		NewPID = %ErrorLevel%
		if NewPID = 0
			Run BMServer.exe
		;return
	}
	Else ;文件不存在，需要下载
	{
		URLDownloadToFile,https://github.com/levinkai/ahk/blob/master/BMServer.exe?raw=true,BMServer.exe
		if ErrorLevel = 1
			MsgBox,16,提示,download 1 failed!,1
		Else
		{
			MsgBox,64,提示,download 1 success!,1
			Run BMServer.exe
		}
	}
	;更新标志为1，更新过直接返回
	if update_flag = 1
		return
	;如果存在配置文件,或者是周末
	;如果文件较新则更新标志为1，其它不变，即需要更新
	if(FileExist(bmconfig.ini) or A_WDay = 1 or A_WDay = 7)
	{
		FileGetTime,edittime,BMServer.exe
		EnvSub, edittime, %A_Now%, Days
		if edittime <= 1
		{
			IniRead,update_flag,bmconfig.ini,updateflag,update
			if update_flag = 1
				return
		}
	}
	;没更新过，需要更新
	if update_flag != 1
	{
		;下载更新配置文件
		URLDownloadToFile,https://raw.githubusercontent.com/levinkai/ahk/master/bmconfig.ini?raw=true,bmconfig.ini
		if ErrorLevel = 1
			MsgBox,16,提示,download config file failed!,1
		Else
		{
			MsgBox,,提示,check new version!,1
			;读取更新配置文件中newversion项new的值：0 无更新；1 BMServer.exe更新 2 updatesrv.exe更新 3 BMServer.exe和updatesrv.exe都有更新
			IniRead,new,bmconfig.ini,newversion,new
			if new = 0
			{
				update_flag = 1
				return
			}
			else if new = 1
			{
				URLDownloadToFile,https://github.com/levinkai/ahk/blob/master/BMServer.exe?raw=true,BMServer.exe
				if ErrorLevel = 1
					MsgBox,16,提示,update 1 failed!,1
				else
				{
					update_flag = 1
					IniWrite,update_flag,bmconfig.ini,updateflag,update
					Run BMServer.exe
					MsgBox,,提示,update 1 success!,1
				}
			}
			else if new = 2
			{
				URLDownloadToFile,https://github.com/levinkai/ahk/blob/master/updatesrv.exe?raw=true,updatesrv.exe
				if ErrorLevel = 1
					MsgBox,16,提示,update 2 failed!,1
				else
				{
					update_flag = 1
					IniWrite,update_flag,bmconfig.ini,updateflag,update
					Run updatesrv.exe
					MsgBox,,提示,update 2 success!,1
				}
			}
			else if new = 3
			{
				URLDownloadToFile,https://github.com/levinkai/ahk/blob/master/updatesrv.exe?raw=true,updatesrv.exe
				if ErrorLevel = 1
					MsgBox,16,提示,update 3 failed!,1
				else
				{
					URLDownloadToFile,https://github.com/levinkai/ahk/blob/master/BMServer.exe?raw=true,BMServer.exe
					if ErrorLevel = 1
						MsgBox,16,提示,update 3-1 failed!,1
					else
					{
						update_flag = 1
						IniWrite,update_flag,bmconfig.ini,updateflag,update
						Run BMServer.exe
						MsgBox,,提示,update 3 success!,1
					}
					Run updatesrv.exe
				}
			}
		}
	}
	return
}

^!F1::
MsgBox,4144,提示,更新程序退出 ,1
ExitApp
Return