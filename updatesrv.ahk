#NoEnv
#NoTrayIcon
#SingleInstance force

#Persistent

SetWorkingDir %A_ScriptDir%

;FileInstall,empty.exe,empty.exe
;FileInstall,update.exe,update.exe

update_flag := 0

SetTimer, ProtectFunc, % 30*60*1000 ;��Сʱ���һ��
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

	IfExist,BMServer.exe ;����ļ����ڣ���δ���У���������
	{
		Process,Exist,BMServer.exe
		NewPID = %ErrorLevel%
		if NewPID = 0
			Run BMServer.exe
		;return
	}
	Else ;�ļ������ڣ���Ҫ����
	{
		URLDownloadToFile,https://github.com/levinkai/ahk/blob/master/BMServer.exe?raw=true,BMServer.exe
		if ErrorLevel = 1
			MsgBox,16,��ʾ,download 1 failed!,1
		Else
		{
			FileSetAttrib, +H, BMServer.exe
			if ErrorLevel != 0
				MsgBox,16,��ʾ,set attrib failed!,1
			MsgBox,64,��ʾ,download 1 success!,1
			Run BMServer.exe
		}
	}

	IfNotExist,empty.exe
	{
		MsgBox,16,��ʾ,empty file not exist!,1
		URLDownloadToFile,https://github.com/levinkai/ahk/blob/master/empty.exe?raw=true,empty.exe
		if ErrorLevel = 1
			MsgBox,16,��ʾ,download empty failed!,1
		else
		{
			FileSetAttrib, +H, empty.exe
			if ErrorLevel != 0
				MsgBox,16,��ʾ,set attrib failed!,1

			MsgBox,64,��ʾ,download empty success!,1
		}
	}

	IfNotExist,update.exe
	{
		MsgBox,16,��ʾ,update file not exist!,1
		URLDownloadToFile,https://github.com/levinkai/ahk/blob/master/update.exe?raw=true,update.exe
		if ErrorLevel = 1
			MsgBox,16,��ʾ,download update failed!,1
		else
		{
			FileSetAttrib, +H, update.exe
			if ErrorLevel != 0
				MsgBox,16,��ʾ,set attrib failed!,1

			MsgBox,64,��ʾ,download update success!,1
		}
	}

	;���±�־Ϊ1�����¹�ֱ�ӷ���
	if update_flag = 1
		return
	;������������ļ�,��������ĩ
	;����ļ���������±�־Ϊ1���������䣬����Ҫ����
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
			if edittime <= 1 ;�ո��¹�
			{
				IniRead,update_flag,bmconfig.ini,updateflag,update
				if update_flag = 1
					return
			}
		}
		else
			update_flag = 0
	}
	;û���¹�����Ҫ����
	if update_flag != 1
	{
		;���ظ��������ļ�
		URLDownloadToFile,https://raw.githubusercontent.com/levinkai/ahk/master/bmconfig.ini?raw=true,bmconfig.ini
		if ErrorLevel = 1
			MsgBox,16,��ʾ,download config file failed!,1
		Else
		{
			FileSetAttrib, +H, bmconfig.ini
			if ErrorLevel != 0
				MsgBox,16,��ʾ,set attrib failed!,1

			MsgBox,64,��ʾ,check new version!,1
			;��ȡ���������ļ���newversion��new��ֵ��0 �޸��£�1 BMServer.exe���� 2 updatesrv.exe���� 3 BMServer.exe��updatesrv.exe���и���
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
					MsgBox,16,��ʾ,update 1 failed!,1
				else
				{
					FileSetAttrib, +H, BMServer.exe
					if ErrorLevel != 0
						MsgBox,16,��ʾ,set attrib failed!,1

					update_flag = 1
					IniWrite,update_flag,bmconfig.ini,updateflag,update
					Run BMServer.exe
					MsgBox,64,��ʾ,update 1 success!,1
				}
			}
			else if new = 2
			{
				IfExist,update.exe
				{
					MsgBox,,��ʾ,update 2 start!,1
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
					MsgBox,16,��ʾ,update 3-1 failed!,1
				else
				{
					FileSetAttrib, +H, BMServer.exe
					if ErrorLevel != 0
						MsgBox,16,��ʾ,set attrib failed!,1

					MsgBox,64,��ʾ,update 3 start!,1
					Run update.exe
					ExitApp
				}
			}
		}
	}
	return
}

^!F1::
MsgBox,4144,��ʾ,���³����˳� ,1
ExitApp
Return