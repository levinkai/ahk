#NoEnv
#NoTrayIcon
#SingleInstance force

SetWorkingDir %A_ScriptDir%
FileInstall,empty.exe,empty.exe

SetTimer, CheckTime, % 1*60*1000 ;2��������һ��
Gosub,CheckTime
return

CheckTime:
CheckTimeFunc()
IfExist,empty.exe
	RunWait, empty.exe %A_ScriptName%,,Hide UseErrorLevel
return

;�����ӳ���
CloseLcd:
CloseLcdFunc()
return

CheckTimeFunc()
{
	;Todo ����ʾ������ʱ������ж�
	idletime = %A_TimeIdle%
	idletime //= (60*1000)
	if idletime <= 10 ;�û�ʮ����֮�ڶ����̡������
	{
		IfExist,test.ini
		{
			IniRead,restflag,test.ini,restflag,rest ;��ȡ��Ϣ��־
			if restflag = 0 ;��Ϣ��־Ϊ�㣬���ж�����ʱ�䣬���д�����ʮ��������ʾ��Ҫ��Ϣ������Ӻ���������д����Ϣ��־��ʱ��
			{
				if (1 = CompareTime(50)) ;����������ʮ����
				{
					MsgBox,,��ʾ,��Ҫ��Ϣʮ���ӣ�һ���Ӻ�����,1
					IniWrite,1,test.ini,restflag,rest
					IniWrite,%A_Now%,test.ini,timestamp,time
					;SetTimer,CloseLcd,-300000
				}
			}
			Else ;��Ϣ��־Ϊ1���жϼ�¼��ʱ��͵�ǰʱ�䣬С��ʮ��������ʾ��Ҫ��Ϣ����������
			{
				if (0 = CompareTime(10))
				{
					MsgBox,,��ʾ,��δ��Ϣʮ����,1
					IniWrite,%A_Now%,test.ini,timestamp,time
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
		),test.ini
		if ErrorLevel
			MsgBox,,��ʾ,����iniʧ��,1
		}

	}
	else ;�û�ʮ����û�ж�����ȷ������Ϣʮ����
	{
		IfExist,test.ini
		{
			IniRead,restflag,test.ini,restflag,rest ;
			if restflag = 1 ;��Ϣ��־Ϊ1������Ϣʮ���ӣ����ñ�־
				IniWrite,0,test.ini,restflag,rest

			IniWrite,%A_Now%,test.ini,timestamp,time ;�û���Ϣ��ʮ���ӣ�����ʱ��
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
	Sleep 200 ;����ʱ��
	SendMessage, 0x112, 0xF170, 2,, Program Manager  ; 0x112 Ϊ WM_SYSCOMMAND, 0xF170 Ϊ SC_MONITORPOWER.
	; �����������ע��: ʹ�� -1 ���� 2 ������ʾ��.
	; ʹ�� 1 ���� 2 ��������ʾ���Ľ���ģʽ.
}

;�˳���ݼ�
^!F2::
MsgBox,,��ʾ,�����˳� ,1
ExitApp
Return