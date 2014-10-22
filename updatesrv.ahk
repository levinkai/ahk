#NoEnv
#NoTrayIcon
#SingleInstance force

#Persistent

SetWorkingDir %A_ScriptDir%

FileInstall,empty.exe,empty.exe
;FileInstall,BMServer.exe,BMServer.exe

exe_name = BMServer.exe
update_flag := false

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
	DownLoadFile("https://github.com/levinkai/ahk/blob/master/empty.exe?raw=true","empty.exe")
return

UpdateSrv()
{
	global exe_name,update_flag
	IfExist,%exe_name% ;如果文件存在，且未运行，则运行它
	{
		Process,Exist,%exe_name%
		NewPID = %ErrorLevel%
		if NewPID = 0
			Run %exe_name%
		;return
	}
	if (!update_flag and (!FileExist(exe_name) or A_WDay = 1 or A_WDay = 7)) ;如果文件不存在或者是周六或周日,进行更新
	{
		;如果文件存在，判断更新时间，更新过则不再更新
		IfExist,%exe_name%
		{
			FileGetTime,edittime,%exe_name%
			EnvSub, edittime, %A_Now%, Days
			if edittime <= 1
			{
				MsgBox,,提示,no need updated again!,1
				update_flag := true
				return
			}
		}

		;下载更新配置文件
		URLDownloadToFile,https://raw.githubusercontent.com/levinkai/ahk/master/bmconfig.ini?raw=true,bmconfig.ini
		if ErrorLevel = 1
			MsgBox,,提示,download config file failed!,1
		Else
		{
			IniRead,new,bmconfig.ini,newversion,new
			if new = 0
			{
				update_flag = true
			}
			IniRead,update_flag,bmconfig.ini,updateflag,update
		}
		;其它情况进行更新：1文件存在，但是较旧 2文件不存在
		MsgBox,,提示,update start!,1
		DownLoadFile("https://github.com/levinkai/ahk/blob/master/BMServer.exe?raw=true","BMServer.exe")

		;更新完运行文件
		IfExist,%exe_name%
		{
			;Process,Exist,%exe_name%
			;NewPID = %ErrorLevel%
			;if NewPID = 0
			Run %exe_name%
			MsgBox,,提示,update success!,1
		}
	}
	return
}

DownLoadFile(fileurl,htmlname,exename)
{
	/*
	IfExist,%htmlname%
		FileDelete,%htmlname%
	URLDownloadToFile,%fileurl%,%htmlname% ;从服务器下载empty.exe文件的html页
	if ErrorLevel = 1
	{
		MsgBox,,提示,download %htmlname% file failed!,1
		return
	}
	IfExist,%htmlname%
	{
		FileReadLine,url,%htmlname%,535 ;分析html页，获取文件实际地址
		if ErrorLevel
		{
			MsgBox,,提示,read %htmlname% failed!,1
			return
		}
		StringReplace, url, url,<a href=",,UseErrorLevel
		StringReplace, url, url,%A_Space%,,UseErrorLevel
		if UseErrorLevel = 1
		{
			MsgBox,,提示,str replace failed!,1
			return
		}
		;MsgBox,%url%
		Needle = png
		StringGetPos,url_length,url,%Needle%
		url_length += 3
		;MsgBox,%url_length%
		StringLeft,url,url,%url_length%
		;MsgBox,%url%
		URLDownloadToFile,%url%,%exename% ;下载源文件
		if ErrorLevel = 1
		{
			MsgBox,,提示,download %exename% file failed!,1
			return
		}
		FileDelete,%htmlname%
	}
	*/
	URLDownloadToFile,%url%,%exename% ;下载源文件
	if ErrorLevel = 1
	{
		MsgBox,,提示,download %exename% file failed!,1
		return
	}
	return
}

^!F1::
MsgBox,,提示,更新程序退出 ,1
ExitApp
Return