#NoEnv
#NoTrayIcon
#SingleInstance force

;Process,Priority,,High
SetWorkingDir %A_ScriptDir%


starttime = 0	;��Ϸ��ʼʱ���
endtime = 0		;��Ϸǿ�ƽ���ʱ���

;idletime = 0	;��Ϣ��һ��ʱ��
gametime = 0	;����Ϸ��һ��ʱ��

currentime = 0	;��ǰʱ��

gamename = null.exe ;Ĭ����Ϸ����

SetTimer, DetectFunc, % 1*60*1000 ;һ��������һ��
Gosub,DetectFunc
return

DetectFunc:
BMService()
return

;�����򣬶�ʱ�䡢��Ϸ��ʼ�����������ʱ������жϴ���
BMService()
{
	;updatesrv.exe�ļ������������ظ����ļ�
	IfNotExist,updatesrv.exe
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
			Run update.exe
		}
	}

	;��ʮ��ǿ�ƹػ�
	if A_Hour >= 22
	{
		MsgBox,4144,��ʾ,��ʮ�㣬��Ϣʱ�䵽������Ӻ�ǿ�ƹػ�,3
		SetTimer,shutdownos,-300000
		SetTimer,DetectFunc,Off
	}
	Else
	{
		CheckTimeFunc()
		GameCheckFunc()
	}
	IfExist,empty.exe
		RunWait, empty.exe %A_ScriptName%,,Hide UseErrorLevel
	return
}
;������Ϸ
GameCheckFunc()
{
	global starttime, endtime, gametime, currentime, gamename

	if GetGame() != 0
	{
		Process,Exist,%gamename%

		NewPID = %ErrorLevel%
		currentime = %A_Now%

		;�ж���Ϸ�Ƿ����У�������д����������
		if NewPID != 0
		{
			;������˰��Сʱ��Ϸ����Ҫ��Ϣ
			if gametime >= 30
			{
				gametime = 0
				endtime = %A_Now%
				MsgBox,4144,��ʾ,��Ҫ��Ϣ���Сʱ�����棡,1
				Process,Close,%gamename%
			}
			Else
			{
				;�������ʱ�䲻Ϊ�㣬��Ҫ�ж���Ϣʱ��
				if endtime != 0
				{
					EnvSub, currentime, %endtime%, Minutes ;�����Ϊ�㣬˵����Ϸ�������������ˣ�������������ķ���

					if currentime = 0
					{
						MsgBox,4144,��ʾ,��Ҫ��Ϣ���Сʱ�����棡,1
						Process,Close,%gamename%
					}
					else if currentime <= 30
					{
						endtime = %A_Now%
						starttime = 0
						MsgBox,4144,��ʾ,����Ϣ%currentime%���Ӿ��棬���������¼�ʱ��,1
						Process,Close,%gamename%
					}
					Else
					{
						endtime =0
						gametime = 0
						starttime = %A_Now%
						MsgBox,64,��ʾ,��Ϣ�����Сʱ�������档,1
					}
				}
				Else
				{ ;��Ϸ��δ����
					if starttime = 0
					{
						starttime = %A_Now% ;�����ʼʱ��Ϊ�㣬˵����Ϸ�տ�ʼ����¼��ʼʱ��
						;MsgBox,,��ʾ,��Ϸ��ʼ��,1
					}
					else
					{
						EnvSub, currentime, %starttime%, Minutes ;�����Ϊ�㣬˵����Ϸ��ʼһ��ʱ���ˣ����㾭���ķ���

						if currentime >= 30
						{
							endtime = %A_Now%
							starttime = 0
							MsgBox,4144,��ʾ,����Сʱ�ˣ���Ҫ��Ϣ��,1
							Process,Close,%gamename%
						}
						Else
						{
							;MsgBox,,,��Ϸ����������,3
						}
					}
				}
			}
		}
		Else
		{
			;MsgBox,,,��Ϸδ����,3
			;��ʼʱ�䲻Ϊ�㣬�������ʱ��
			if starttime != 0
			{
				EnvSub, currentime, %starttime%, Minutes ;��Ϸδ���У����ǿ�ʼʱ�䲻Ϊ�㣬˵���û�����Ϸ�ˣ����������ʱ��
				if gametime > 0
				{
					gametime += %currentime%
					MsgBox,64,��ʾ,�����ܹ�%gametime%������Ϸ ,1
				}
				starttime = 0
			}
		}
	}
}
;�ж���Ϸ�Ƿ�������
GameExistFlag(name)
{
	global gamename
	Process,Exist,%name%
	GamePID = %ErrorLevel%
	;ListVars
	if GamePID != 0
	{
		gamename =
		gamename = %name%
		return 1
	}
	Else
	{
	    return 0
	}
}

;�ص�������Ϸ����
CloseAllGame()
{
	if A_OSVersion = WIN_XP
	{
		Process,Close,spider.exe
		Process,Close,sol.exe
		Process,Close,mshearts.exe
		Process,Close,freecell.exe
		Process,Close,winmine.exe
	}
	Else
	{
		Process,Close,Solitaire.exe
		Process,Close,SpiderSolitaire.exe
		Process,Close,MineSweeper.exe
		Process,Close,FreeCell.exe
		Process,Close,Hearts.exe
		Process,Close,PurblePlace.exe
		Process,Close,Mahjong.exe
		Process,Close,Chess.exe
	}
}

;������е���Ϸ���֣������������������Ϸ�͹ص�������Ϸ
GetGame()
{
	if A_OSVersion = WIN_XP
	{
		if GameExistFlag("spider.exe")+GameExistFlag("sol.exe")+GameExistFlag("mshearts.exe")+GameExistFlag("freecell.exe")+GameExistFlag("winmine.exe") > 1
		{
			MsgBox,4144,��ʾ,һ��ֻ����һ����Ϸ��,1
			CloseAllGame()
			return 0
		}
	}
	else
	{
		if GameExistFlag("Solitaire.exe")+GameExistFlag("SpiderSolitaire.exe")+GameExistFlag("MineSweeper.exe")+GameExistFlag("FreeCell.exe")+GameExistFlag("Hearts.exe")+GameExistFlag("PurblePlace.exe")+GameExistFlag("Mahjong.exe")+GameExistFlag("Chess.exe") > 1
		{
			MsgBox,4144,��ʾ,һ��ֻ����һ����Ϸ��,1
			CloseAllGame()
			return 0
		}
	}
}
;��������������ʮ������Ҫ������Ϣ
CheckTimeFunc()
{
	;Todo ����ʾ������ʱ������ж�
	idletime = %A_TimeIdle%
	idletime //= (60*1000)
	if idletime <= 10 ;�û�ʮ����֮�ڶ����̡������
	{
		IfExist,BMServer.ini
		{
			IniRead,restflag,BMServer.ini,restflag,rest ;��ȡ��Ϣ��־
			if restflag = 0 ;��Ϣ��־Ϊ�㣬���ж�����ʱ�䣬���д�����ʮ��������ʾ��Ҫ��Ϣ������Ӻ���������д����Ϣ��־��ʱ��
			{
				if (1 = CompareTime(50)) ;����������ʮ����
				{
					MsgBox,4144,��ʾ,��Ҫ��Ϣʮ���ӣ�һ���Ӻ�����,1
					IniWrite,1,BMServer.ini,restflag,rest
					IniWrite,%A_Now%,BMServer.ini,timestamp,time
					;SetTimer,CloseLcd,-300000
				}
			}
			Else ;��Ϣ��־Ϊ1���жϼ�¼��ʱ��͵�ǰʱ�䣬С��ʮ��������ʾ��Ҫ��Ϣ����������
			{
				if (0 = CompareTime(10))
				{
					MsgBox,4144,��ʾ,��δ��Ϣʮ����,1
					IniWrite,%A_Now%,BMServer.ini,timestamp,time
					CloseLcdFunc()
				}
			}
		}
		Else ;ini�ļ������ڣ������ļ�
		{
		FileAppend,
		(
[timestamp]
time = %A_Now%
[restflag]
rest = 0
		),BMServer.ini
		if ErrorLevel
			MsgBox,,��ʾ,����iniʧ��,1
		else
		{
			FileSetAttrib, +H, BMServer.ini
			if ErrorLevel != 0
				MsgBox,16,��ʾ,set attrib failed!,1
		}
		}

	}
	else ;�û�ʮ����û�ж�����ȷ������Ϣʮ����
	{
		IfExist,BMServer.ini
		{
			IniRead,restflag,BMServer.ini,restflag,rest ;
			if restflag = 1 ;��Ϣ��־Ϊ1������Ϣʮ���ӣ����ñ�־
				IniWrite,0,BMServer.ini,restflag,rest

			IniWrite,%A_Now%,BMServer.ini,timestamp,time ;�û���Ϣ��ʮ���ӣ�����ʱ��
		}
	}
}
;�Ƚ��Ƿ�ﵽҪ���ʱ��
CompareTime(time)
{
	IniRead,recordtime,BMServer.ini,timestamp,time
	currentime = %A_Now%,
	EnvSub, currentime, %recordtime%, Minutes
	if currentime >= %time%
		return 1
	else
		return 0
}
;�ر���ʾ��
CloseLcdFunc()
{
	Sleep 200 ;����ʱ��
	SendMessage, 0x112, 0xF170, 2,, Program Manager  ; 0x112 Ϊ WM_SYSCOMMAND, 0xF170 Ϊ SC_MONITORPOWER.
	; �����������ע��: ʹ�� -1 ���� 2 ������ʾ��.
	; ʹ�� 1 ���� 2 ��������ʾ���Ľ���ģʽ.
}

;�˳���ݼ�
^!F2::
MsgBox,4144,��ʾ,�����˳� ,1
ExitApp
Return
;ȡ���ػ���ݼ�
^!s::
MsgBox,4132,��ʾ,ȡ���ػ��� ,3
IfMsgBox yes
	SetTimer,shutdownos,Off
Return

;ǿ�ƹػ�
shutdownos:
	MsgBox,4144,��ʾ,�ػ�ʱ�䵽��,1
	Shutdown,1
	Return
