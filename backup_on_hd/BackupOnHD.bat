rem Для работы на Windows XP требуется установить Resource Kit Tools для Windows Server 2003.

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

rem Определяем съёмный диск
mountvol |>nul find /i "%volume1%" && ( set volume=%volume1% && goto mount ) || ( goto volume2 )
:volume2
mountvol |>nul find /i "%volume2%" && ( set volume=%volume2% && goto mount ) || ( echo Не найдено доступных съёмных дисков для монтирования! >> %logfile% && exit )

:mount
rem Подключаем съёмный диск через TrueCrypt
"%truecrypt_path%\truecrypt.exe" /q /v %volume% /lm /b /k %key% /p %volume_password%
sleep 3
rem Проверим подключение съёмного диска
if not exist %disk%\nul ( echo Диск не подключен! >> %logfile% && exit )

rem Проверим, существует ли файл настроек копирования
if not exist %file_settings_backup% ( echo Файл настроек копирования %file_settings_backup% не найден! >> %logfile% && exit )

:net_test
rem Проверим сетевое соединение с NAS
ping -n 2 %ip_NAS% |>nul find /i "TTL=" && ( echo Соединение c NAS установлено %date% %time%>> %logfile% && goto rm_files ) || ( ping 127.1 -n 2& echo Повторная попытка... >> %logfile%& goto net_test)


:rm_files
rem Выполняем удаление со съёмного диска файлов старше 14 дней и пустых каталогов.
for /d %%B in (%disk%\*) do echo %%B>> %dirlist%
for /f "tokens=*" %%a in (%dirlist%) do (
	forfiles /p "%%a" /s /m *.* /d -14 /c "cmd /c del /q @path"
	sleep 5
	for /d %%i in ("%%a\*") do rd /q "%%i" 2>nul
)
del /q %dirlist%

rem Копируем файлы с NAS хранилища в соответствии с параметрами из файла настроек
for /f "eol=; tokens=1,2,3,4 delims=:" %%i in (%file_settings_backup%) do (
	robocopy "%unc_NAS%\%%i" "%disk%\%%j" /S /LOG+:%logfile% /NDL /NJS /NP /TEE /MAXAGE:%%k /XF %%l
)
echo. >> %logfile%

rem --------------------------------------------------------------------------------------------------------------------------
rem ---Резервное копирование архивов каталога _DOC и Электронных досье с сервера PRILOG выполняется отдельно в этой секции!---
rem -----------------------------Это связано с добавочным механизмом создания архивов!----------------------------------------
rem --------------------------------------------------------------------------------------------------------------------------

echo Начинаем копирование архивов каталога _DOC...>> %logfile%

set dir_name=\\192.168.0.225\akcia-backup\server\Prilog\
set disk_dir_name=%disk%\Prilog\

rem Находим последнюю полную копию
for /f "tokens=*" %%i in ('dir "%dir_name%" /b /o:d /a:-d ^| findstr "_DOC.*Полный"') do set full_copy_name=%%i

rem Получаем дату создания последней полной копии
for /f "tokens=1" %%i in ('dir /T:C "%dir_name%%full_copy_name%" ^| findstr "_DOC.*Полный"') do set date_cr=%%i

rem Преобразуем дату последней полной копии в формат, понятный robocopy
for /f "tokens=1,2,3 delims=." %%a in ( "%date_cr%" ) do set date_cr=%%c%%b%%a

rem Копирование полной копии
if not exist "%disk_dir_name%%full_copy_name%" (
	echo Файл последней полной копии отсутствует! >> %logfile%
	robocopy %dir_name% %disk_dir_name% "%full_copy_name%" /LOG+:%logfile% /NDL /NJS /NP /TEE
) else (
	echo Найдена последняя полная копия "%full_copy_name%", пропуск... >> %logfile%
)

echo. >> %logfile%
echo Копирование добавочных архивов _DOC...>> %logfile%
rem Копирование добавочных копий
	robocopy %dir_name% %disk_dir_name% "_DOC*Добавочный*" /LOG+:%logfile% /NDL /NJS /NP /TEE /MAXAGE:%date_cr% 


echo. >> %logfile%
echo Начинаем копирование архива Электронных досье...>> %logfile%
rem Находим последнюю полную копию
for /f "tokens=*" %%i in ('dir "%dir_name%" /b /o:d /a:-d ^| findstr ".*досье*"') do set full_copy_name=%%i

rem Копирование полной копии
if not exist "%disk_dir_name%%full_copy_name%" (
	echo Файл последней полной копии не найден! >> %logfile%
	robocopy %dir_name% %disk_dir_name% "%full_copy_name%" /LOG+:%logfile% /NDL /NJS /NP /TEE
) else (
	echo Найдена последняя полная копия "%full_copy_name%", пропуск... >> %logfile%
)

echo. >> %logfile%
echo Копирование файлов на съёмный жёсткий диск завершено %date% в %time%.>> %logfile%

rem Отлючаем съёмный жёсткий диск через TrueCrypt
"%truecrypt_path%\truecrypt.exe" /q /dm



