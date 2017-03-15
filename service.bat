@echo off 
setlocal 
set service=UbsICS
set state=-1
set logfile="D:\Windows\Temp\state_service.txt" 
for /f "tokens=1,4" %%i in ('sc query %service%') do ( 
    if "%%i"=="STATE" ( 
        if "%%j"=="RUNNING" (set state=0) else (set state=1) 
   ) 
)
echo %date% %time% >> %logfile%
echo =================================== >> %logfile%
if %state% EQU 1 sc start %service% >> %logfile%
if %state% EQU 0 exit
if %state% EQU -1 echo "%service% state unknown" >> %logfile%
