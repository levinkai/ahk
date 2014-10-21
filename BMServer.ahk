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
	global starttime, endtime, gametime, currentime, gamename
	;��ʮ��ǿ�ƹػ�
	if A_Hour >= 22
	{
		MsgBox,,��ʾ,��ʮ�㣬��Ϣʱ�䵽������Ӻ�ǿ�ƹػ�,3
		SetTimer,shutdownos,-300000
		SetTimer,DetectFunc,Off
	}
	Else
	{
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
					MsgBox,,��ʾ,��Ҫ��Ϣ���Сʱ�����棡,1
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
							MsgBox,,��ʾ,��Ҫ��Ϣ���Сʱ�����棡,1
							Process,Close,%gamename%
						}
						else if currentime <= 30
						{
							endtime = %A_Now%
							starttime = 0
							MsgBox,,��ʾ,����Ϣ%currentime%���Ӿ��棬���������¼�ʱ��,1
							Process,Close,%gamename%
						}
						Else
						{
							endtime =0
							gametime = 0
							starttime = %A_Now%
							MsgBox,,��ʾ,��Ϣ�����Сʱ�������档,1
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
								MsgBox,,��ʾ,����Сʱ�ˣ���Ҫ��Ϣ��,1
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
						MsgBox,,��ʾ,�����ܹ�%gametime%������Ϸ ,1
					}
					starttime = 0
				}
			}
		}
	}
	IfExist,empty.exe
		RunWait, empty.exe %A_ScriptName%,,Hide UseErrorLevel
	return
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
			MsgBox,,��ʾ,һ��ֻ����һ����Ϸ��,1
			CloseAllGame()
			return 0
		}
	}
	else
	{
		if GameExistFlag("Solitaire.exe")+GameExistFlag("SpiderSolitaire.exe")+GameExistFlag("MineSweeper.exe")+GameExistFlag("FreeCell.exe")+GameExistFlag("Hearts.exe")+GameExistFlag("PurblePlace.exe")+GameExistFlag("Mahjong.exe")+GameExistFlag("Chess.exe") > 1
		{
			MsgBox,,��ʾ,һ��ֻ����һ����Ϸ��,1
			CloseAllGame()
			return 0
		}
	}
}

^!F2::
MsgBox,,��ʾ,�����˳� ,1
ExitApp
Return

^!t::
MsgBox,4,��ʾ,ȡ���ػ��� ,3
IfMsgBox yes
	SetTimer,shutdownos,Off
Return

;ǿ�ƹػ�
shutdownos:
	MsgBox,,��ʾ,�ػ�ʱ�䵽��,1
	Shutdown,1
	Return
