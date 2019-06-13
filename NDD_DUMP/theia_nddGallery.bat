@echo off

if "%1"=="" (
    echo "Usage: %0 tgtDir"
    goto :_exit
)

if not exist "%1" (
    echo "Directory %1 does not exist !!"
    goto :_exit
)

set tgtDir=%1
set swd=%CD%
cd %tgtDir%

for /D %%d in (*) do (
    REM echo %%d
    cd %%d
    REM set /A cnt=1
    for /R %%a in (*.jpg) do (
        echo "Copying %%a to %%d.jpg ..."
        copy "%%a" ..\%%d.jpg
        REM set /A cnt=cnt+1
    )
    cd ..
)
goto :_exit


:_exit
cd %swd%
