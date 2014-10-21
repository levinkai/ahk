#NoEnv
#NoTrayIcon
#SingleInstance force

SetWorkingDir %A_ScriptDir%
FileInstall,empty.exe,empty.exe

SetTimer, CheckTime, % 1*60*1000 ;2分钟运行一次
Gosub,CheckTime
return

CheckTime:
CheckTimeFunc()
IfExist,empty.exe
	RunWait, empty.exe %A_ScriptName%,,Hide UseErrorLevel
return

;灭屏子程序
CloseLcd:
CloseLcdFunc()
return

CheckTimeFunc()
{
	;Todo 当显示器亮的时候进行判断
	idletime = %A_TimeIdle%
	idletime //= (60*1000)
	if idletime <= 10 ;用户十分钟之内动键盘、鼠标了
	{
		IfExist,test.ini
		{
			IniRead,restflag,test.ini,restflag,rest ;读取休息标志
			if restflag = 0 ;休息标志为零，则判断运行时间，运行大于五十分钟则提示需要休息，五分钟后灭屏，且写入休息标志和时间
			{
				if (1 = CompareTime(50)) ;电脑运行五十分钟
				{
					MsgBox,,提示,需要休息十分钟，一分钟后灭屏,1
					IniWrite,1,test.ini,restflag,rest
					IniWrite,%A_Now%,test.ini,timestamp,time
					;SetTimer,CloseLcd,-300000
				}
			}
			Else ;休息标志为1，判断记录的时间和当前时间，小于十分钟则提示需要休息，立即灭屏
			{
				if (0 = CompareTime(10))
				{
					MsgBox,,提示,还未休息十分钟,1
					IniWrite,%A_Now%,test.ini,timestamp,time
					CloseLcdFunc()
				}
			}
		}
		Else ;ini文件不存在，创建文件
		{
		FileAppend,
		(
[timestamp]
time = %A_Now%
[restflag]
rest = 0
		),test.ini
		if ErrorLevel
			MsgBox,,提示,创建ini失败,1
		}

	}
	else ;用户十分钟没有动作，确认已休息十分钟
	{
		IfExist,test.ini
		{
			IniRead,restflag,test.ini,restflag,rest ;
			if restflag = 1 ;休息标志为1，已休息十分钟，重置标志
				IniWrite,0,test.ini,restflag,rest

			IniWrite,%A_Now%,test.ini,timestamp,time ;用户休息满十分钟，重置时间
		}
	}
}

CompareTime(time)
{
	IniRead,recordtime,test.ini,timestamp,time
	currentime = %A_Now%,
	EnvSub, currentime, %recordtime%, Minutes
	if currentime >= %time%
		return 1
	else
		return 0
}

CloseLcdFunc()
{
	Sleep 200 ;缓冲时间
	SendMessage, 0x112, 0xF170, 2,, Program Manager  ; 0x112 为 WM_SYSCOMMAND, 0xF170 为 SC_MONITORPOWER.
	; 对上面命令的注释: 使用 -1 代替 2 来打开显示器.
	; 使用 1 代替 2 来激活显示器的节能模式.
}

;退出快捷键
^!F2::
MsgBox,,提示,程序退出 ,1
ExitApp
Return