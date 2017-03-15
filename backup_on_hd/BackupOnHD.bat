rem ��� ࠡ��� �� Windows XP �ॡ���� ��⠭����� Resource Kit Tools ��� Windows Server 2003.

@echo off
setlocal enableextensions

set dir_script=%~dp0
set truecrypt_path=C:\Program Files\TrueCrypt
set key=%dir_script%\new_key
set volume1=\\?\Volume{466c60ae-a206-11e4-bec5-00241dff56b5}\
set volume2=\\?\Volume{5b228e16-a86c-11e5-b3a3-00241dff56b5}\
set volume_password=gfgfhe,bklhjdf
set disk=M:
set dirlist=%dir_script%\dirlist.txt
set logfile=%dir_script%\log\log_%date%.txt
set file_settings_backup=%dir_script%\settings.ini
set ip_NAS=192.168.0.225
set unc_NAS=\\192.168.0.225

echo %date% %time%> %logfile%

rem ��।��塞 ���� ���
mountvol |>nul find /i "%volume1%" && ( set volume=%volume1% && goto mount ) || ( goto volume2 )
:volume2
mountvol |>nul find /i "%volume2%" && ( set volume=%volume2% && goto mount ) || ( echo �� ������� ����㯭�� ����� ��᪮� ��� ����஢����! >> %logfile% && exit )

:mount
rem ������砥� ���� ��� �१ TrueCrypt
"%truecrypt_path%\truecrypt.exe" /q /v %volume% /lm /b /k %key% /p %volume_password%
sleep 3
rem �஢�ਬ ������祭�� ��񬭮�� ��᪠
if not exist %disk%\nul ( echo ��� �� ������祭! >> %logfile% && exit )

rem �஢�ਬ, ������� �� 䠩� ����஥� ����஢����
if not exist %file_settings_backup% ( echo ���� ����஥� ����஢���� %file_settings_backup% �� ������! >> %logfile% && exit )

:net_test
rem �஢�ਬ �⥢�� ᮥ������� � NAS
ping -n 2 %ip_NAS% |>nul find /i "TTL=" && ( echo ���������� c NAS ��⠭������ %date% %time%>> %logfile% && goto rm_files ) || ( ping 127.1 -n 2& echo ����ୠ� ����⪠... >> %logfile%& goto net_test)


:rm_files
rem �믮��塞 㤠����� � ��񬭮�� ��᪠ 䠩��� ���� 14 ���� � ������ ��⠫����.
for /d %%B in (%disk%\*) do echo %%B>> %dirlist%
for /f "tokens=*" %%a in (%dirlist%) do (
	forfiles /p "%%a" /s /m *.* /d -14 /c "cmd /c del /q @path"
	sleep 5
	for /d %%i in ("%%a\*") do rd /q "%%i" 2>nul
)
del /q %dirlist%

rem �����㥬 䠩�� � NAS �࠭���� � ᮮ⢥��⢨� � ��ࠬ��ࠬ� �� 䠩�� ����஥�
for /f "eol=; tokens=1,2,3,4 delims=:" %%i in (%file_settings_backup%) do (
	robocopy "%unc_NAS%\%%i" "%disk%\%%j" /S /LOG+:%logfile% /NDL /NJS /NP /TEE /MAXAGE:%%k /XF %%l
)
echo. >> %logfile%

rem --------------------------------------------------------------------------------------------------------------------------
rem ---����ࢭ�� ����஢���� ��娢�� ��⠫��� _DOC � �����஭��� ���� � �ࢥ� PRILOG �믮������ �⤥�쭮 � �⮩ ᥪ樨!---
rem -----------------------------�� �易�� � �������� ��堭����� ᮧ����� ��娢��!----------------------------------------
rem --------------------------------------------------------------------------------------------------------------------------

echo ��稭��� ����஢���� ��娢�� ��⠫��� _DOC...>> %logfile%

set dir_name=\\192.168.0.225\akcia-backup\server\Prilog\
set disk_dir_name=%disk%\Prilog\

rem ��室�� ��᫥���� ������ �����
for /f "tokens=*" %%i in ('dir "%dir_name%" /b /o:d /a:-d ^| findstr "_DOC.*�����"') do set full_copy_name=%%i

rem ����砥� ���� ᮧ����� ��᫥���� ������ �����
for /f "tokens=1" %%i in ('dir /T:C "%dir_name%%full_copy_name%" ^| findstr "_DOC.*�����"') do set date_cr=%%i

rem �८�ࠧ㥬 ���� ��᫥���� ������ ����� � �ଠ�, ������ robocopy
for /f "tokens=1,2,3 delims=." %%a in ( "%date_cr%" ) do set date_cr=%%c%%b%%a

rem ����஢���� ������ �����
if not exist "%disk_dir_name%%full_copy_name%" (
	echo ���� ��᫥���� ������ ����� ���������! >> %logfile%
	robocopy %dir_name% %disk_dir_name% "%full_copy_name%" /LOG+:%logfile% /NDL /NJS /NP /TEE
) else (
	echo ������� ��᫥���� ������ ����� "%full_copy_name%", �ய��... >> %logfile%
)

echo. >> %logfile%
echo ����஢���� ��������� ��娢�� _DOC...>> %logfile%
rem ����஢���� ��������� �����
	robocopy %dir_name% %disk_dir_name% "_DOC*��������*" /LOG+:%logfile% /NDL /NJS /NP /TEE /MAXAGE:%date_cr% 


echo. >> %logfile%
echo ��稭��� ����஢���� ��娢� �����஭��� ����...>> %logfile%
rem ��室�� ��᫥���� ������ �����
for /f "tokens=*" %%i in ('dir "%dir_name%" /b /o:d /a:-d ^| findstr ".*����*"') do set full_copy_name=%%i

rem ����஢���� ������ �����
if not exist "%disk_dir_name%%full_copy_name%" (
	echo ���� ��᫥���� ������ ����� �� ������! >> %logfile%
	robocopy %dir_name% %disk_dir_name% "%full_copy_name%" /LOG+:%logfile% /NDL /NJS /NP /TEE
) else (
	echo ������� ��᫥���� ������ ����� "%full_copy_name%", �ய��... >> %logfile%
)

echo. >> %logfile%
echo ����஢���� 䠩��� �� ���� ���⪨� ��� �����襭� %date% � %time%.>> %logfile%

rem ���砥� ���� ���⪨� ��� �१ TrueCrypt
"%truecrypt_path%\truecrypt.exe" /q /dm



