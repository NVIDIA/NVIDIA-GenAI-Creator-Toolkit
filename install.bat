@echo off
REM SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
REM SPDX-License-Identifier: Apache-2.0
REM
REM Licensed under the Apache License, Version 2.0 (the "License");
REM you may not use this file except in compliance with the License.
REM You may obtain a copy of the License at
REM
REM http://www.apache.org/licenses/LICENSE-2.0
REM
REM Unless required by applicable law or agreed to in writing, software
REM distributed under the License is distributed on an "AS IS" BASIS,
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM See the License for the specific language governing permissions and
REM limitations under the License.
REM
REM install.bat — ComfyUI custom node installer for comfyui-generative-ai-workflows
REM
REM IMPORTANT: Run this from Command Prompt (cmd.exe), NOT from Git Bash or PowerShell.
REM   cmd.exe:    install.bat C:\path\to\ComfyUI
REM   PowerShell: cmd /c install.bat C:\path\to\ComfyUI
REM
REM Optionally download models immediately after install:
REM   install.bat C:\path\to\ComfyUI --modules 02,03,08
REM   install.bat C:\path\to\ComfyUI --modules all

REM Force UTF-8 output so text is visible in all terminals
chcp 65001 > nul

setlocal enabledelayedexpansion

echo.
echo ================================================================
echo  ComfyUI Generative AI Workflows - Node Installer
echo ================================================================
echo.

REM Parse arguments: first positional = ComfyUI path, --modules = module list
set COMFYUI_DIR=
set MODULES=
:parse_args
if "%~1"=="" goto done_parse
if /i "%~1"=="--modules" (
    set MODULES=%~2
    shift /1
    shift /1
    goto parse_args
)
if not defined COMFYUI_DIR set COMFYUI_DIR=%~1
shift /1
goto parse_args
:done_parse
if not defined COMFYUI_DIR set COMFYUI_DIR=%cd%

echo ComfyUI path: %COMFYUI_DIR%
echo.

set NODES_DIR=%COMFYUI_DIR%\custom_nodes

if not exist "%COMFYUI_DIR%\main.py" (
  echo ERROR: main.py not found at: %COMFYUI_DIR%
  echo.
  echo   This script requires the ComfyUI root directory ^(the folder containing main.py^).
  echo   Pass the path as an argument:
  echo     install.bat C:\path\to\ComfyUI
  echo.
  echo   If using ComfyUI Portable, the root is the folder with run_nvidia_gpu.bat,
  echo   NOT a subfolder. Example: install.bat C:\ComfyUI_windows_portable
  exit /b 1
)

REM Detect which Python/pip to use
REM Priority: Portable embedded Python (same dir or parent) > venv > system pip
REM
REM ComfyUI Portable layout:
REM   <root>\python_embeded\   <- embedded Python here
REM   <root>\ComfyUI\main.py   <- main.py here (one level down)
REM Uses !PIP_FOUND! (delayed expansion) to short-circuit once a pip is found.
set PIP_FOUND=0

if exist "%COMFYUI_DIR%\python_embeded\python.exe" (
    set "PIP=%COMFYUI_DIR%\python_embeded\python.exe -m pip"
    set PIP_FOUND=1
    echo Detected ComfyUI Portable - using embedded Python
)

if !PIP_FOUND!==0 if exist "%COMFYUI_DIR%\..\python_embeded\python.exe" (
    set "PIP=%COMFYUI_DIR%\..\python_embeded\python.exe -m pip"
    set PIP_FOUND=1
    echo Detected ComfyUI Portable - using embedded Python ^(parent directory^)
)

if !PIP_FOUND!==0 if exist "%COMFYUI_DIR%\venv\Scripts\pip.exe" (
    set "PIP=%COMFYUI_DIR%\venv\Scripts\pip.exe"
    set PIP_FOUND=1
    echo Detected venv - using %COMFYUI_DIR%\venv\Scripts\pip.exe
)

if !PIP_FOUND!==0 (
    set PIP=pip
    echo WARNING: No venv or embedded Python found. Using system pip.
    echo          If installs fail, activate your venv first or check your ComfyUI path.
)

echo Installing custom nodes into: %NODES_DIR%
if not exist "%NODES_DIR%" mkdir "%NODES_DIR%"
echo.
set NODE_COUNT=0
set NODE_TOTAL=20

REM --- Core ---
call :install_node "ComfyUI-Manager" "https://github.com/ltdrdata/ComfyUI-Manager" ""

REM --- Modules 01 + 02: Qwen utilities ---
call :install_node "ComfyUI-WJNodes" "https://github.com/807502278/ComfyUI-WJNodes" ""
call :install_node "ComfyUI-Easy-Use" "https://github.com/yolain/ComfyUI-Easy-Use" ""

REM --- Module 01: LLM Prompt Enhancer ---
call :install_node "comfyui-ollama" "https://github.com/stavsap/comfyui-ollama" ""

REM --- Modules 02-07, Bonus A+B: TextureAlchemy ---
call :install_node "ComfyUI-TextureAlchemy" "https://github.com/amtarr/ComfyUI-TextureAlchemy" "Sandbox"

REM --- Modules 04 + 05: Gaussian Splat ---
call :install_node "ComfyUI-Sharp" "https://github.com/PozzettiAndrea/ComfyUI-Sharp" ""
call :install_node "ComfyUI-GeometryPack" "https://github.com/PozzettiAndrea/ComfyUI-GeometryPack" ""

REM --- Module 08: Trellis2 3D ---
call :install_node "ComfyUI-TRELLIS2" "https://github.com/PozzettiAndrea/ComfyUI-TRELLIS2" ""

REM --- Module 09: Cutout Animation ---
call :install_node "comfy_nv_video_prep" "https://github.com/NVIDIA/comfy_nv_video_prep" ""
call :install_node "ComfyUI-Custom-Scripts" "https://github.com/pythongosssss/ComfyUI-Custom-Scripts" ""
call :install_node "ComfyUI_essentials" "https://github.com/cubiq/ComfyUI_essentials" ""
call :install_node "ComfyUI-Inpaint-CropAndStitch" "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch" ""
call :install_node "comfyui-sam2" "https://github.com/neverbiasu/ComfyUI-SAM2" ""
call :install_node "ComfyUI-VideoHelperSuite" "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite" ""

REM --- Module 10: Playblast to Video ---
call :install_node "ComfyUI-WanVideoWrapper" "https://github.com/kijai/ComfyUI-WanVideoWrapper" ""
call :install_node "ComfyUI-KJNodes" "https://github.com/kijai/ComfyUI-KJNodes" ""
call :install_node "cg-use-everywhere" "https://github.com/chrisgoringe/cg-use-everywhere" ""
call :install_node "radiance" "https://github.com/fxtdstudios/radiance" ""

REM --- Modules 10 + Bonus B: Lotus ---
call :install_node "ComfyUI-Lotus" "https://github.com/kijai/ComfyUI-Lotus" ""

REM --- Bonus B: Texture to PBR ---
call :install_node "ComfyUI-Marigold" "https://github.com/kijai/ComfyUI-Marigold" ""

REM --- Copy workflow JSON files into ComfyUI ---
set WORKFLOWS_DEST=%COMFYUI_DIR%\user\default\workflows\creative-genai-workflows
if not exist "%WORKFLOWS_DEST%" mkdir "%WORKFLOWS_DEST%"
for /d %%D in ("%~dp0workflows\*") do (
  if exist "%%D\workflow.json" (
    set "MODULE_NAME=%%~nxD"
    if not exist "%WORKFLOWS_DEST%\!MODULE_NAME!" mkdir "%WORKFLOWS_DEST%\!MODULE_NAME!"
    copy /y "%%D\workflow.json" "%WORKFLOWS_DEST%\!MODULE_NAME!\workflow.json" > nul
  )
)
echo.
echo Workflows copied to: %WORKFLOWS_DEST%

if not defined MODULES (
    echo.
    echo ================================================================
    echo  Which modules do you want to download models for?
    echo ================================================================
    echo.
    echo  Available modules:
    echo    01  LLM Prompt Enhancer      ^(Ollama/Gemma3 — no download needed^)
    echo    02  Image Deconstruction     ^(~8 GB^)
    echo    03  Targeted Inpainting      ^(~8 GB^)
    echo    04  Image to Gaussian Splat  ^(~1 GB^)
    echo    05  Gaussian Splat SceneFill ^(~8 GB^)
    echo    06  Equirectangular Outpaint ^(~12 GB^)
    echo    07  Panorama to HDRI         ^(~24 GB^)
    echo    08  Trellis2 3D Asset Gen    ^(~20 GB^)
    echo    09  Cutout Animation         ^(~30 GB^)
    echo    10  Playblast to Video       ^(~30 GB^)
    echo.
    echo  Enter module numbers ^(e.g. 02,03,08^), "all", or press Enter to skip:
    echo.
    set /p MODULES="  Modules: "
)

if defined MODULES (
    if /i not "%MODULES%"=="" (
        echo.
        echo ================================================================
        echo  Downloading models for modules: %MODULES%
        echo ================================================================
        python "%~dp0download_models.py" --comfyui "%COMFYUI_DIR%" --modules %MODULES%
    )
)

echo.
echo ================================================================
echo  Installation complete
echo ================================================================
echo.
if not defined MODULES (
    echo Next steps:
    echo   1. Module 01 only — install Ollama: https://ollama.com/download
    echo      Then run: ollama pull gemma3
    echo   2. Download models for the modules you want to use:
    echo      python download_models.py --comfyui "%COMFYUI_DIR%" --modules 02,03,08
    echo      (large models like Wan2.2 and Trellis2 take time -- do this before your session)
    echo   3. Launch ComfyUI:
    echo      Portable: run_nvidia_gpu.bat ^(in the portable root folder^)
    echo      Manual install: venv\Scripts\activate ^&^& python main.py
    echo   4. Workflows are ready in ComfyUI under: Load ^> creative-genai-workflows
) else (
    echo Next steps:
    echo   1. Module 01 only — install Ollama: https://ollama.com/download
    echo      Then run: ollama pull gemma3
    echo   2. Launch ComfyUI:
    echo      Portable: run_nvidia_gpu.bat ^(in the portable root folder^)
    echo      Manual install: venv\Scripts\activate ^&^& python main.py
    echo   3. Workflows are ready in ComfyUI under: Load ^> creative-genai-workflows
)
echo.
goto :eof

:install_node
set NODE_NAME=%~1
set NODE_REPO=%~2
set NODE_BRANCH=%~3
set NODE_DIR=%NODES_DIR%\%NODE_NAME%
set /a NODE_COUNT+=1

if exist "%NODE_DIR%" (
  echo [%NODE_COUNT%/%NODE_TOTAL%] skip   %NODE_NAME% ^(already installed^)
) else (
  echo [%NODE_COUNT%/%NODE_TOTAL%] install %NODE_NAME% ...
  if "%NODE_BRANCH%"=="" (
    git clone --depth 1 %NODE_REPO% "%NODE_DIR%" 2>&1
  ) else (
    git clone --depth 1 --branch %NODE_BRANCH% %NODE_REPO% "%NODE_DIR%" 2>&1
  )
  if errorlevel 1 (
    echo [ERROR] Failed to clone %NODE_NAME%
    echo         Repo: %NODE_REPO%
    echo         Check your internet connection and that Git is installed.
  ) else (
    echo         OK
  )
)

if exist "%NODE_DIR%\requirements.txt" (
  echo         Installing Python requirements...
  %PIP% install -q --no-warn-script-location -r "%NODE_DIR%\requirements.txt" > "%TEMP%\comfyui_pip.tmp" 2>&1
  if errorlevel 1 (
    echo         [WARN] Some packages failed to install for !NODE_NAME!
    echo               This is usually OK - ComfyUI Manager resolves missing deps on first run.
    echo               To see details: type %TEMP%\comfyui_pip.tmp
  )
)
goto :eof
