#NoEnv
#NoTrayIcon
#SingleInstance force

;Process,Priority,,High
SetWorkingDir %A_ScriptDir%


starttime = 0	;游戏开始时间点
endtime = 0		;游戏强制结束时间点

;idletime = 0	;休息的一段时间
gametime = 0	;玩游戏的一段时间

currentime = 0	;当前时间

gamename = null.exe ;默认游戏名字

SetTimer, DetectFunc, % 1*60*1000 ;一分钟运行一次
Gosub,DetectFunc
return

DetectFunc:
BMService()
return

;主程序，对时间、游戏开始、结束、玩的时间进行判断处理
BMService()
{
	global starttime, endtime, gametime, currentime, gamename
	;晚十点强制关机
	if A_Hour >= 22
	{
		MsgBox,,提示,晚十点，休息时间到，五分钟后强制关机,3
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

			;判断游戏是否运行，是则进行处理，否则继续
			if NewPID != 0
			{
				;间断玩了半个小时游戏，需要休息
				if gametime >= 30
				{
					gametime = 0
					endtime = %A_Now%
					MsgBox,,提示,需要休息半个小时才能玩！,1
					Process,Close,%gamename%
				}
				Else
				{
					;如果结束时间不为零，需要判断休息时间
					if endtime != 0
					{
						EnvSub, currentime, %endtime%, Minutes ;如果不为零，说明游戏结束后又运行了，计算结束经过的分钟

						if currentime = 0
						{
							MsgBox,,提示,需要休息半个小时才能玩！,1
							Process,Close,%gamename%
						}
						else if currentime <= 30
						{
							endtime = %A_Now%
							starttime = 0
							MsgBox,,提示,刚休息%currentime%分钟就玩，从现在重新计时！,1
							Process,Close,%gamename%
						}
						Else
						{
							endtime =0
							gametime = 0
							starttime = %A_Now%
							MsgBox,,提示,休息满半个小时，可以玩。,1
						}
					}
					Else
					{ ;游戏还未结束
						if starttime = 0
						{
							starttime = %A_Now% ;如果开始时间为零，说明游戏刚开始，记录开始时间
							;MsgBox,,提示,游戏开始！,1
						}
						else
						{
							EnvSub, currentime, %starttime%, Minutes ;如果不为零，说明游戏开始一段时间了，计算经过的分钟

							if currentime >= 30
							{
								endtime = %A_Now%
								starttime = 0
								MsgBox,,提示,玩半个小时了，需要休息！,1
								Process,Close,%gamename%
							}
							Else
							{
								;MsgBox,,,游戏继续。。。,3
							}
						}
					}
				}
			}
			Else
			{
				;MsgBox,,,游戏未运行,3
				;开始时间不为零，计算玩的时间
				if starttime != 0
				{
					EnvSub, currentime, %starttime%, Minutes ;游戏未运行，但是开始时间不为零，说明用户玩游戏了，计算玩的总时间
					if gametime > 0
					{
						gametime += %currentime%
						MsgBox,,提示,玩了总共%gametime%分钟游戏 ,1
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

;判断游戏是否在运行
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

;关掉所有游戏进程
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

;获得运行的游戏名字，如果运行两个以上游戏就关掉所有游戏
GetGame()
{
	if A_OSVersion = WIN_XP
	{
		if GameExistFlag("spider.exe")+GameExistFlag("sol.exe")+GameExistFlag("mshearts.exe")+GameExistFlag("freecell.exe")+GameExistFlag("winmine.exe") > 1
		{
			MsgBox,,提示,一次只能玩一个游戏！,1
			CloseAllGame()
			return 0
		}
	}
	else
	{
		if GameExistFlag("Solitaire.exe")+GameExistFlag("SpiderSolitaire.exe")+GameExistFlag("MineSweeper.exe")+GameExistFlag("FreeCell.exe")+GameExistFlag("Hearts.exe")+GameExistFlag("PurblePlace.exe")+GameExistFlag("Mahjong.exe")+GameExistFlag("Chess.exe") > 1
		{
			MsgBox,,提示,一次只能玩一个游戏！,1
			CloseAllGame()
			return 0
		}
	}
}

^!F2::
MsgBox,,提示,程序退出 ,1
ExitApp
Return

^!t::
MsgBox,4,提示,取消关机？ ,3
IfMsgBox yes
	SetTimer,shutdownos,Off
Return

;强制关机
shutdownos:
	MsgBox,,提示,关机时间到！,1
	Shutdown,1
	Return
