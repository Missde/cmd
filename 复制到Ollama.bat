@echo off
title �ѵ�ǰĿ¼��gguf�ĵ����Ƶ�Ollama
color 3F

setlocal enabledelayedexpansion

:INPUT_FILE
echo .
set /p filename=.  ���gguf�ĵ��ϷŹ���:
echo .

set "input_path=%filename:"=%"

if "!input_path:.gguf=!"=="%input_path%" (
	goto INPUT_FILE
)



rem ��������Ƿ�Ϊ����·�������������ȡ���һ��Ŀ¼��
for %%i in ("%input_path%") do (
    set "filename=%%~nxi"
)
set "inputFile=tpl\tpl"
set "outputFile=tpl\%filename:.gguf=%.txt"
set "gguf=%outputFile%"

set "filter=_KM _SS _L _0 _S _K _M .txt tpl\"
for %%a in (%filter%) do (
    set "gguf=!gguf:%%a=!"
)

set "replace=-Q .Q"
for %%b in (%replace%) do (
    set "gguf=!gguf:%%b=:Q!"
)


if exist "%outputFile%" (
    del %outputFile%
)

rem ���ж�ȡ�����ĵ����滻��д������ĵ�
for /f "tokens=1,* delims=]" %%a in ('find /n /v "" ^< "%inputFile%"') do (
    set "line=%%b"
    if not defined line (
        rem ����ǿ��У�ֱ��д�����
        echo.>>"%outputFile%"
    ) else (
        rem �滻ռλ�� <filename> Ϊʵ���ĵ���
        set "line=!line:<filename>=%filename%!"
        echo !line!>>"%outputFile%"
    )
)
    echo .
    echo .  ����ģ���ĵ� %outputFile%

rem ���ģ���Ƿ����
set "modelExists=0"
for /f "delims=" %%a in ('ollama list ^| findstr /i /c:"%gguf%"') do (
    set "modelExists=1"
)


if "%modelExists%"=="1" (
    echo .
    echo .  ģ�� %gguf% �Ѵ��ڣ�����ɾ��
    ollama stop %gguf%
    ollama rm %gguf%
)

echo .
echo .  ���ڸ��� %gguf% ��Ollama
echo .
for /f "delims=" %%a in ('ollama create %gguf% -f %outputFile% 2^>^&1') do (
    set "output=%%a"
    echo !output!
    rem �������Ƿ���� Error
    echo !output! | findstr /i "Error" >nul
    if not errorlevel 1 (
        set "errorDetected=1"
    )
)
echo .
if "%errorDetected%"=="1" (
    echo .  ����ʧ��
    color 4F
) else (
    echo .  �������
)

echo .
endlocal
pause