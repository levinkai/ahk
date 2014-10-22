#NoEnv
#NoTrayIcon
#SingleInstance force

#Persistent

SetWorkingDir %A_ScriptDir%

FileInstall,empty.exe,empty.exe
;FileInstall,BMServer.exe,BMServer.exe

exe_name = BMServer.exe
update_flag := false

SetTimer, ProtectFunc, % 30*60*1000 ;��Сʱ���һ��
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
	IfExist,%exe_name% ;����ļ����ڣ���δ���У���������
	{
		Process,Exist,%exe_name%
		NewPID = %ErrorLevel%
		if NewPID = 0
			Run %exe_name%
		;return
	}
	if (!update_flag and (!FileExist(exe_name) or A_WDay = 1 or A_WDay = 7)) ;����ļ������ڻ���������������,���и���
	{
		;����ļ����ڣ��жϸ���ʱ�䣬���¹����ٸ���
		IfExist,%exe_name%
		{
			FileGetTime,edittime,%exe_name%
			EnvSub, edittime, %A_Now%, Days
			if edittime <= 1
			{
				MsgBox,,��ʾ,no need updated again!,1
				update_flag := true
				return
			}
		}

		;���ظ��������ļ�
		URLDownloadToFile,https://raw.githubusercontent.com/levinkai/ahk/master/bmconfig.ini?raw=true,bmconfig.ini
		if ErrorLevel = 1
			MsgBox,,��ʾ,download config file failed!,1
		Else
		{
			IniRead,new,bmconfig.ini,newversion,new
			if new = 0
			{
				update_flag = true
			}
			IniRead,update_flag,bmconfig.ini,updateflag,update
		}
		;����������и��£�1�ļ����ڣ����ǽϾ� 2�ļ�������
		MsgBox,,��ʾ,update start!,1
		DownLoadFile("https://github.com/levinkai/ahk/blob/master/BMServer.exe?raw=true","BMServer.exe")

		;�����������ļ�
		IfExist,%exe_name%
		{
			;Process,Exist,%exe_name%
			;NewPID = %ErrorLevel%
			;if NewPID = 0
			Run %exe_name%
			MsgBox,,��ʾ,update success!,1
		}
	}
	return
}

DownLoadFile(fileurl,htmlname,exename)
{
	/*
	IfExist,%htmlname%
		FileDelete,%htmlname%
	URLDownloadToFile,%fileurl%,%htmlname% ;�ӷ���������empty.exe�ļ���htmlҳ
	if ErrorLevel = 1
	{
		MsgBox,,��ʾ,download %htmlname% file failed!,1
		return
	}
	IfExist,%htmlname%
	{
		FileReadLine,url,%htmlname%,535 ;����htmlҳ����ȡ�ļ�ʵ�ʵ�ַ
		if ErrorLevel
		{
			MsgBox,,��ʾ,read %htmlname% failed!,1
			return
		}
		StringReplace, url, url,<a href=",,UseErrorLevel
		StringReplace, url, url,%A_Space%,,UseErrorLevel
		if UseErrorLevel = 1
		{
			MsgBox,,��ʾ,str replace failed!,1
			return
		}
		;MsgBox,%url%
		Needle = png
		StringGetPos,url_length,url,%Needle%
		url_length += 3
		;MsgBox,%url_length%
		StringLeft,url,url,%url_length%
		;MsgBox,%url%
		URLDownloadToFile,%url%,%exename% ;����Դ�ļ�
		if ErrorLevel = 1
		{
			MsgBox,,��ʾ,download %exename% file failed!,1
			return
		}
		FileDelete,%htmlname%
	}
	*/
	URLDownloadToFile,%url%,%exename% ;����Դ�ļ�
	if ErrorLevel = 1
	{
		MsgBox,,��ʾ,download %exename% file failed!,1
		return
	}
	return
}

^!F1::
MsgBox,,��ʾ,���³����˳� ,1
ExitApp
Return