@echo off

rem ����뢠�� ���� � ᯨ�� 䠩���, ����� ����室��� ����஢���. � ᯨ᪥ 㪠�뢠���� ����� ���� � �����㥬��� 䠩��.
set backup_list=D:\Backup\backup_list.txt

rem ���� � 䠩�� ���� ��������� �訡�� � ࠡ��� �ਯ�
set backup_log=D:\Backup\GoOnNAS.txt

rem ����뢠�� ���� ��� ������砥���� �⥢��� ��᪠ V:
set net_disk=\\192.168.0.225\akcia-backup\server\serverfiles

rem ��⠭�������� �ଠ� ���� � �६��� ����: ��������_����
set datetime=%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%

rem ��⠭�������� ��⠫�� �����祭��, �㤠 ���� ����஢����� 䠩��
set backup_folder="V:\%datetime%"

echo %date% %time% >> %backup_log%

rem �᫨ ��� ᯨ᪠ �����㥬�� 䠩���, ������� �訡�� � ��� � ���.
if not exist %backup_list% ( echo File %backup_list% not found! >> %backup_log% && exit )

rem �᫨ ������祭���� ��᪠ �� �뫮, � ������稬 ���.
if not exist V:\nul (net use V: %net_disk%)

rem �᫨ ������祭���� ��᪠ V: ���, ������� �訡�� � ��� � ���.
if not exist V:\nul ( echo Cannot mount network drive %net_disk% >> %backup_log% && exit )

mkdir %backup_folder%
rem ��ॡ�ࠥ� � 横�� ��ப� �� ᯨ᪠ � �����㥬 ����� 䠩�. ��᫥ �ᯥ譮�� ����஢���� ��襬 ����� � ���.

for /f "tokens=*" %%i in (%backup_list%) do (copy /Y %%i %backup_folder% && echo File %%i copied! >> %backup_log%)
net use V: /DELETE
echo %date% %time% >> %backup_log%
echo. >> %backup_log%