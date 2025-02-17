@echo off
title python llama.cpp/convertתsafetensorsΪGGUF - by missde
color 3F

setlocal enabledelayedexpansion

:INPUT_FOLDER
echo.
set /p filename=.  ������safetensors�ļ������� (���Ϸ��ļ���):

set "input_path=%filename:"=%"  REM ȥ�����ܴ��ڵ�����


set "found=false"
for %%f in ("%input_path%\*.safetensors") do (
    set "found=true"
)

if "%found%"=="false" (
    color 6F
    echo.
    echo.  δ�ҵ�safetensors�ĵ������������롣
    goto INPUT_FOLDER
)



rem ��������Ƿ�Ϊ����·�������������ȡ���һ��Ŀ¼��
for %%i in ("%input_path%") do (
    set "filename=%%~nxi"
)


if not exist "%filename%" (
	color 6F
    echo.
    echo.  ��%filename%�� ������
    goto INPUT_FOLDER
)
color 3F

:INPUT_QUANTIZATION
echo.
echo.  ��ѡ��Ҫת�����������ͣ������Ӧ�Ĵ��ţ���
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
set /p choice=. ���������:

if not defined map_%choice% (
	color 6F
    echo. ������Ĵ��Ų���ȷ�����������롣
    goto INPUT_QUANTIZATION
)


color 3F
set "selected_q=!map_%choice%!"
set "gguf_filename=%filename%-%selected_q%.gguf"
if exist "%gguf_filename%" (
    set /p "fugai=.  �ĵ� %gguf_filename% �Ѵ��ڣ��Ƿ񸲸ǣ�(y/1 ��ʾ���ǣ�������ʾȡ��) "
    echo.
    if /i "!fugai!"=="y" (
        del "%gguf_filename%"
        echo.  ���ĵ���ɾ������ʼ����ת��...
    ) else if /i "!fugai!"=="1" (
        del "%gguf_filename%"
        echo.  ���ĵ���ɾ������ʼ����ת��...
    ) else (
        echo.  ȡ�����ǲ��������������
         echo.
        goto INPUT_QUANTIZATION
    )
)

    echo.  ת�� %filename% ,��������: %selected_q%
    echo.
    python llama.cpp/convert_hf_to_gguf.py %filename%  --outtype %selected_q% --outfile %gguf_filename%

endlocal

cmd