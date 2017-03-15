@echo off

rem Указываем путь к списку файлов, которые необходимо копировать. В списке указывается полный путь к копируемому файлу.
set backup_list=D:\Backup\backup_list.txt

rem Путь к файлу лога возможных ошибок и работы скрипта
set backup_log=D:\Backup\GoOnNAS.txt

rem Указываем путь для подключаемого сетевого диска V:
set net_disk=\\192.168.0.225\akcia-backup\server\serverfiles

rem Устанавливаем формат даты и времени вида: ГГГГММДД_ЧЧММ
set datetime=%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%

rem Устанавливаем каталог назначения, куда будут копироваться файлы
set backup_folder="V:\%datetime%"

echo %date% %time% >> %backup_log%

rem Если нет списка копируемых файлов, записать ошибку в лог и выйти.
if not exist %backup_list% ( echo File %backup_list% not found! >> %backup_log% && exit )

rem Если подключенного диска не было, то подключим его.
if not exist V:\nul (net use V: %net_disk%)

rem Если подключенного диска V: нет, записать ошибку в лог и выйти.
if not exist V:\nul ( echo Cannot mount network drive %net_disk% >> %backup_log% && exit )

mkdir %backup_folder%
rem Перебираем в цикле строки из списка и копируем каждый файл. После успешного копирования пишем строчку в лог.

for /f "tokens=*" %%i in (%backup_list%) do (copy /Y %%i %backup_folder% && echo File %%i copied! >> %backup_log%)
net use V: /DELETE
echo %date% %time% >> %backup_log%
echo. >> %backup_log%