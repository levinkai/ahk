#NoEnv
#NoTrayIcon
#SingleInstance force

#Persistent

SetWorkingDir %A_ScriptDir%

;FileInstall,empty.exe,empty.exe
;FileInstall,update.exe,update.exe

update_flag := 0

SetTimer, ProtectFunc, % 30*60*1000 ;半小时检查一次
Gosub,ProtectFunc
return

ProtectFunc:
UpdateSrv()
IfExist,empty.exe
	RunWait, empty.exe %A_ScriptName%,,Hide UseErrorLevel
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
			FileSetAttrib, +H, BMServer.exe
			if ErrorLevel != 0
				MsgBox,16,提示,set attrib failed!,1
			MsgBox,64,提示,download 1 success!,1
			Run BMServer.exe
		}
	}

	IfNotExist,empty.exe
	{
		MsgBox,16,提示,empty file not exist!,1
		URLDownloadToFile,https://github.com/levinkai/ahk/blob/master/empty.exe?raw=true,empty.exe
		if ErrorLevel = 1
			MsgBox,16,提示,download empty failed!,1
		else
		{
			FileSetAttrib, +H, empty.exe
			if ErrorLevel != 0
				MsgBox,16,提示,set attrib failed!,1

			MsgBox,64,提示,download empty success!,1
		}
	}

	IfNotExist,update.exe
	{
		MsgBox,16,提示,update file not exist!,1
		URLDownloadToFile,https://github.com/levinkai/ahk/blob/master/update.exe?raw=true,update.exe
		if ErrorLevel = 1
			MsgBox,16,提示,download update failed!,1
		else
		{
			FileSetAttrib, +H, update.exe
			if ErrorLevel != 0
				MsgBox,16,提示,set attrib failed!,1

			MsgBox,64,提示,download update success!,1
		}
	}

	;更新标志为1，更新过直接返回
	if update_flag = 1
		return
	;如果存在配置文件,或者是周末
	;如果文件较新则更新标志为1，其它不变，即需要更新
	IfExist,bmconfig.ini
	{
		IniRead,update_flag,bmconfig.ini,updateflag,update
	}
	else
		update_flag = 0
	if(A_WDay = 1 or A_WDay = 7)
	{
		IfExist,bmconfig.ini
		{
			FileGetTime,edittime,bmconfig.ini
			EnvSub, edittime, %A_Now%, Days
			if edittime <= 1 ;刚更新过
			{
				IniRead,update_flag,bmconfig.ini,updateflag,update
				if update_flag = 1
					return
			}
		}
		else
			update_flag = 0
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
			FileSetAttrib, +H, bmconfig.ini
			if ErrorLevel != 0
				MsgBox,16,提示,set attrib failed!,1

			MsgBox,64,提示,check new version!,1
			;读取更新配置文件中newversion项new的值：0 无更新；1 BMServer.exe更新 2 updatesrv.exe更新 3 BMServer.exe和updatesrv.exe都有更新
			IniRead,new,bmconfig.ini,newversion,new
			if new = 0
			{
				update_flag = 1
				return
			}
			else if new = 1
			{
				Process,Close,BMServer.exe
				URLDownloadToFile,https://github.com/levinkai/ahk/blob/master/BMServer.exe?raw=true,BMServer.exe
				if ErrorLevel = 1
					MsgBox,16,提示,update 1 failed!,1
				else
				{
					FileSetAttrib, +H, BMServer.exe
					if ErrorLevel != 0
						MsgBox,16,提示,set attrib failed!,1

					update_flag = 1
					IniWrite,update_flag,bmconfig.ini,updateflag,update
					Run BMServer.exe
					MsgBox,64,提示,update 1 success!,1
				}
			}
			else if new = 2
			{
				IfExist,update.exe
				{
					MsgBox,,提示,update 2 start!,1
					Run update.exe
					ExitApp
				}
				Else
					Run updatesrv.exe
			}
			else if new = 3
			{
				Process,Close,BMServer.exe
				URLDownloadToFile,https://github.com/levinkai/ahk/blob/master/BMServer.exe?raw=true,BMServer.exe
				if ErrorLevel = 1
					MsgBox,16,提示,update 3-1 failed!,1
				else
				{
					FileSetAttrib, +H, BMServer.exe
					if ErrorLevel != 0
						MsgBox,16,提示,set attrib failed!,1

					MsgBox,64,提示,update 3 start!,1
					Run update.exe
					ExitApp
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