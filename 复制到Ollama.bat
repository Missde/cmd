@echo off
chcp 65001 > nul

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
    set "name=%%~ni"
)


set "inputFile=tpl\tpl"
set "outputFile=tpl\%name:.gguf=%.txt"

rem 核心处理逻辑：定位最后一个[-.]并替换
set "last_pos=-1"

rem 逆向遍历字符串（从末尾开始）
:reverse_loop
set "char=!name:~%last_pos%,1!"
if "!char!" neq "" (
    if "!char!" == "-" set "split_char=-" & goto replace_char
    if "!char!" == "." set "split_char=." & goto replace_char
    set /a last_pos-=1
    goto reverse_loop
)

:replace_char
rem 执行替换操作
set "front_part=!name:~0,%last_pos%!"
set /a last_pos+=1
set "end_part=!name:~%last_pos%!"
set "gguf=!front_part!:!end_part!"

rem set "filter=_KM _SS _L _0 _S _K _M .txt tpl\"
rem for %%a in (%filter%) do set "gguf=!gguf:%%a=!"


if exist "%outputFile%" (
    del %outputFile%
)



set ctime=%date% %time%

rem 逐行读取输入文档，替换并写入输出文档
for /f "tokens=1,* delims=]" %%a in ('find /n /v "" ^< "%inputFile%"') do (
    set "line=%%b"
    if not defined line (
        rem 如果是空行，直接写入空行
        echo.>>"%outputFile%"
    ) else (
        rem 替换占位符 <filename> 为实际文档名
        set "line=!line:<filename>=%name%.gguf!"
        set "line=!line:<ctime>=%ctime%!"
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
ollama create %gguf% -f %outputFile%

@REM for /f "delims=" %%a in ('ollama create %gguf% -f %outputFile% 2^>^&1') do (
@REM     set "output=%%a"
@REM     echo !output!
@REM     rem 检查输出是否包含 Error
@REM     echo !output! | findstr /i "Error" >nul
@REM     if not errorlevel 1 (
@REM         set "errorDetected=1"
@REM     )
@REM )
@REM echo .
@REM if "%errorDetected%"=="1" (
@REM     echo .  操作失败
@REM     color 4F
@REM ) else (
@REM     echo .  复制完成
@REM )

echo .
endlocal
pause