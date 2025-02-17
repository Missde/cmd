@echo off
title 把当前目录的gguf文档复制到Ollama
color 3F

setlocal enabledelayedexpansion

:INPUT_FILE
echo .
set /p filename=.  请把gguf文档拖放过来:
echo .

set "input_path=%filename:"=%"

if "!input_path:.gguf=!"=="%input_path%" (
	goto INPUT_FILE
)



rem 检查输入是否为完整路径，如果是则提取最后一层目录名
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

rem 逐行读取输入文档，替换并写入输出文档
for /f "tokens=1,* delims=]" %%a in ('find /n /v "" ^< "%inputFile%"') do (
    set "line=%%b"
    if not defined line (
        rem 如果是空行，直接写入空行
        echo.>>"%outputFile%"
    ) else (
        rem 替换占位符 <filename> 为实际文档名
        set "line=!line:<filename>=%filename%!"
        echo !line!>>"%outputFile%"
    )
)
    echo .
    echo .  生成模板文档 %outputFile%

rem 检查模型是否存在
set "modelExists=0"
for /f "delims=" %%a in ('ollama list ^| findstr /i /c:"%gguf%"') do (
    set "modelExists=1"
)


if "%modelExists%"=="1" (
    echo .
    echo .  模型 %gguf% 已存在，正在删除
    ollama stop %gguf%
    ollama rm %gguf%
)

echo .
echo .  现在复制 %gguf% 到Ollama
echo .
for /f "delims=" %%a in ('ollama create %gguf% -f %outputFile% 2^>^&1') do (
    set "output=%%a"
    echo !output!
    rem 检查输出是否包含 Error
    echo !output! | findstr /i "Error" >nul
    if not errorlevel 1 (
        set "errorDetected=1"
    )
)
echo .
if "%errorDetected%"=="1" (
    echo .  操作失败
    color 4F
) else (
    echo .  复制完成
)

echo .
endlocal
pause