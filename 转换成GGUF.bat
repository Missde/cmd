@echo off
title python llama.cpp/convert转safetensors为GGUF - by missde
color 3F

setlocal enabledelayedexpansion

:INPUT_FOLDER
echo.
set /p filename=.  请输入safetensors文件夹名称 (可拖放文件夹):

set "input_path=%filename:"=%"  REM 去除可能存在的引号


set "found=false"
for %%f in ("%input_path%\*.safetensors") do (
    set "found=true"
)

if "%found%"=="false" (
    color 6F
    echo.
    echo.  未找到safetensors文档，请重新输入。
    goto INPUT_FOLDER
)



rem 检查输入是否为完整路径，如果是则提取最后一层目录名
for %%i in ("%input_path%") do (
    set "filename=%%~nxi"
)


if not exist "%filename%" (
	color 6F
    echo.
    echo.  【%filename%】 不存在
    goto INPUT_FOLDER
)
color 3F

:INPUT_QUANTIZATION
echo.
echo.  请选择要转换的量化类型（输入对应的代号）：
echo.
echo     0      -     auto
rem     1      -     tq1_0
rem     2      -     tq2_0
echo     3      -     f32
rem echo     4      -     q4_0
echo     8      -     q8_0
echo     16     -     f16

set "map_0=auto"
set "map_1=tq1_0"
set "map_2=tq2_0"
set "map_3=f32"
set "map_4=q4_0"
set "map_8=q8_0"
set "map_16=f16"
set "map_16=bf16"

echo.
set /p choice=. 请输入代号:

if not defined map_%choice% (
	color 6F
    echo. 你输入的代号不正确，请重新输入。
    goto INPUT_QUANTIZATION
)


color 3F
set "selected_q=!map_%choice%!"
set "gguf_filename=%filename%-%selected_q%.gguf"
if exist "%gguf_filename%" (
    set /p "fugai=.  文档 %gguf_filename% 已存在，是否覆盖？(y/1 表示覆盖，其他表示取消) "
    echo.
    if /i "!fugai!"=="y" (
        del "%gguf_filename%"
        echo.  旧文档已删除，开始重新转换...
    ) else if /i "!fugai!"=="1" (
        del "%gguf_filename%"
        echo.  旧文档已删除，开始重新转换...
    ) else (
        echo.  取消覆盖操作，程序结束。
         echo.
        goto INPUT_QUANTIZATION
    )
)

    echo.  转换 %filename% ,量化类型: %selected_q%
    echo.
    python llama.cpp/convert_hf_to_gguf.py %filename%  --outtype %selected_q% --outfile %gguf_filename%

endlocal

cmd