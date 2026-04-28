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
REM
REM Pass your ComfyUI installation location as the first argument:
REM
REM   Desktop App:  install.bat C:\path\to\your\installation-location
REM                 (the folder you chose during Desktop App setup — contains .venv\, models\, custom_nodes\)
REM
REM   Portable:     install.bat C:\ComfyUI_windows_portable
REM                 (the folder containing run_nvidia_gpu.bat and python_embeded\)
REM
REM   Manual:       install.bat C:\path\to\ComfyUI
REM                 (the folder containing main.py)
REM
REM   PowerShell:   cmd /c install.bat C:\path\to\installation-location
REM
REM Install specific modules:
REM   install.bat C:\path\to\installation-location --modules 02,03,08
REM   install.bat C:\path\to\installation-location --modules all
REM
REM Remove model files for a module (frees disk space; shared models are kept):
REM   install.bat C:\path\to\installation-location --clean --modules 04

REM Force UTF-8 output so text is visible in all terminals
chcp 65001 > nul

setlocal enabledelayedexpansion

echo.
echo ================================================================
echo  ComfyUI Generative AI Workflows - Node Installer
echo ================================================================
echo.

REM Parse arguments
REM   First positional arg = ComfyUI installation location (Desktop App) or ComfyUI folder (Portable/Manual)
REM   --modules = comma-separated module list to install
set INSTALL_LOCATION=
set MODULES=
set CLEAN=0
:parse_args
if "%~1"=="" goto done_parse
if /i "%~1"=="--clean" (
    set CLEAN=1
    shift /1
    goto parse_args
)
if /i "%~1"=="--modules" (
    set MODULES=%~2
    shift /1
    shift /1
    goto parse_args
)
if not defined INSTALL_LOCATION (
    set INSTALL_LOCATION=%~1
    shift /1
    goto parse_args
)
REM cmd.exe treats commas as arg delimiters, so --modules 02,03,04 arrives as
REM separate tokens. Collect any bare non-flag tokens after INSTALL_LOCATION is
REM set and append them to MODULES.
if defined MODULES (
    set "_arg=%~1"
    if not "!_arg:~0,1!"=="-" (
        set "MODULES=!MODULES!,!_arg!"
        shift /1
        goto parse_args
    )
)
shift /1
goto parse_args
:done_parse
if not defined INSTALL_LOCATION (
    echo No installation location specified.
    echo.
    echo   Desktop App:  pass the folder you chose during setup ^(.venv\, models\, custom_nodes\^)
    echo   Portable:     pass the folder with run_nvidia_gpu.bat
    echo   Manual:       pass the folder with main.py
    echo.
    set /p INSTALL_LOCATION="  Enter your ComfyUI installation location: "
    if not defined INSTALL_LOCATION (
        echo No path entered. Exiting.
        exit /b 1
    )
)

REM Strip trailing backslash
if "%INSTALL_LOCATION:~-1%"=="\" set "INSTALL_LOCATION=%INSTALL_LOCATION:~0,-1%"

echo Installation location: %INSTALL_LOCATION%
echo.

REM -----------------------------------------------------------------------
REM Detect install type from what exists in the given path.
REM
REM   Desktop App:  <installation location>\.venv\Scripts\python.exe
REM                 <installation location>\custom_nodes\
REM                 <installation location>\models\
REM
REM   Portable:     <root>\python_embeded\python.exe  (same dir or parent)
REM                 <root>\ComfyUI\main.py
REM
REM   Manual:       <ComfyUI dir>\main.py
REM                 <ComfyUI dir>\venv\Scripts\python.exe  (optional)
REM -----------------------------------------------------------------------
set PIP_FOUND=0
set INSTALL_TYPE=unknown
set COMFYUI_SOURCE_DIR=
set NODES_DIR=%INSTALL_LOCATION%\custom_nodes

REM Resolve parent directory
for %%I in ("%INSTALL_LOCATION%\..") do set "INSTALL_PARENT=%%~fI"

REM --- Desktop App: installation location has .venv directly ---
if !PIP_FOUND!==0 if exist "%INSTALL_LOCATION%\.venv\Scripts\python.exe" (
    set "PYTHON=%INSTALL_LOCATION%\.venv\Scripts\python.exe"
    set PIP_FOUND=1
    set INSTALL_TYPE=desktop
    set "DESKTOP_USER_DIR=%INSTALL_LOCATION%"
    echo [check] ComfyUI Desktop App installation location detected.
    echo         Python environment: %INSTALL_LOCATION%\.venv
    REM Source code may be inside the installation location or in the app bundle
    if exist "%INSTALL_LOCATION%\resources\ComfyUI\main.py" (
        set "COMFYUI_SOURCE_DIR=%INSTALL_LOCATION%\resources\ComfyUI"
    ) else if exist "%INSTALL_LOCATION%\resource\ComfyUI\main.py" (
        set "COMFYUI_SOURCE_DIR=%INSTALL_LOCATION%\resource\ComfyUI"
    )
)

REM --- Catch: user passed resource\ComfyUI source dir instead of installation location ---
if !PIP_FOUND!==0 (
    echo "!INSTALL_LOCATION!" | findstr /i "\\resource\\ComfyUI" > nul 2>&1
    if not errorlevel 1 (
        echo.
        echo ================================================================
        echo  ERROR: You passed the ComfyUI source folder, not your
        echo  installation location.
        echo.
        echo  The source folder ^(resource\ComfyUI^) is managed by the app
        echo  and will be reset on updates. Do not install nodes here.
        echo.
        echo  Pass your installation location instead — the folder you chose
        echo  when setting up ComfyUI Desktop. It contains:
        echo    .venv\        ^(Python environment^)
        echo    models\       ^(model files^)
        echo    custom_nodes\ ^(custom nodes^)
        echo.
        echo  Example:
        echo    install.bat C:\path\to\your\ComfyUI-installation-location
        echo ================================================================
        echo.
        pause
        exit /b 1
    )
)

REM --- Portable: python_embeded in same dir ---
if !PIP_FOUND!==0 if exist "%INSTALL_LOCATION%\python_embeded\python.exe" (
    set "PYTHON=%INSTALL_LOCATION%\python_embeded\python.exe"
    set PIP_FOUND=1
    set INSTALL_TYPE=portable
    echo [check] ComfyUI Portable detected - using embedded Python
    if exist "%INSTALL_LOCATION%\ComfyUI\main.py" (
        set "COMFYUI_SOURCE_DIR=%INSTALL_LOCATION%\ComfyUI"
        set "NODES_DIR=%INSTALL_LOCATION%\ComfyUI\custom_nodes"
    ) else (
        set "COMFYUI_SOURCE_DIR=%INSTALL_LOCATION%"
        set "NODES_DIR=%INSTALL_LOCATION%\custom_nodes"
    )
)

REM --- Portable: python_embeded one level up (user passed ComfyUI subfolder) ---
if !PIP_FOUND!==0 if exist "!INSTALL_PARENT!\python_embeded\python.exe" (
    set "PYTHON=!INSTALL_PARENT!\python_embeded\python.exe"
    set PIP_FOUND=1
    set INSTALL_TYPE=portable
    set "COMFYUI_SOURCE_DIR=%INSTALL_LOCATION%"
    echo [check] ComfyUI Portable detected - using embedded Python ^(parent^)
)

REM --- Manual install: main.py in given dir with optional venv ---
if !PIP_FOUND!==0 if exist "%INSTALL_LOCATION%\main.py" (
    set INSTALL_TYPE=manual
    set "COMFYUI_SOURCE_DIR=%INSTALL_LOCATION%"
    if exist "%INSTALL_LOCATION%\venv\Scripts\python.exe" (
        set "PYTHON=%INSTALL_LOCATION%\venv\Scripts\python.exe"
        set PIP_FOUND=1
        echo [check] Manual install with venv detected.
    )
)

REM --- Desktop App: incomplete first-run (no .venv yet) ---
if !PIP_FOUND!==0 if !INSTALL_TYPE!==unknown (
    REM Check if this looks like a Desktop App location without a completed setup
    if not exist "%INSTALL_LOCATION%\main.py" (
        echo.
        echo ================================================================
        echo  WARNING: Could not find a Python environment at:
        echo    %INSTALL_LOCATION%\.venv
        echo.
        echo  If this is your ComfyUI Desktop installation location, the app
        echo  may not have completed its initial setup yet.
        echo  Launch ComfyUI Desktop and let it finish setup, then re-run.
        echo.
        echo  If this is a manual or portable install, make sure you are
        echo  passing the correct folder ^(the one containing main.py^).
        echo ================================================================
        echo.
        pause
        exit /b 1
    )
)

if !PIP_FOUND!==0 if defined CONDA_PREFIX (
    set "PYTHON=%CONDA_PREFIX%\python.exe"
    set PIP_FOUND=1
    echo Detected active conda env - using %CONDA_PREFIX%\python.exe
)

if !PIP_FOUND!==0 if defined CONDA_EXE (
    for %%I in ("%CONDA_EXE%\..\..\python.exe") do set "CONDA_BASE_PYTHON=%%~fI"
    if exist "!CONDA_BASE_PYTHON!" (
        set "PYTHON=!CONDA_BASE_PYTHON!"
        set PIP_FOUND=1
        echo Detected conda base env - using !CONDA_BASE_PYTHON!
    )
)

if !PIP_FOUND!==0 (
    set PYTHON=python
    echo WARNING: No venv, embedded Python, or conda env found. Using system Python.
    echo          Activate your environment first for reliable installs:
    echo            conda: conda activate ^<env^>
    echo            venv:  venv\Scripts\activate
)

REM --- Python version check ---
echo.
for /f "delims=" %%V in ('"!PYTHON!" -c "import sys; v=sys.version_info; print(str(v.major)+chr(46)+str(v.minor)+chr(46)+str(v.micro))" 2^>nul') do set "PY_VER=%%V"
for /f "delims=" %%R in ('"!PYTHON!" -c "import sys; print(1 if sys.version_info>=(3,10) else 0)" 2^>nul') do set "PY_OK=%%R"
echo [check] Python: !PY_VER!
if "!PY_OK!"=="0" (
    echo.
    echo [WARNING] Python !PY_VER! detected. ComfyUI requires Python 3.10 or higher.
    echo           Your install may have issues. Consider upgrading Python.
    echo.
)

REM --- ComfyUI version check ---
if defined COMFYUI_SOURCE_DIR (
    if exist "!COMFYUI_SOURCE_DIR!\comfyui_version.py" (
        for /f "delims=" %%V in ('"!PYTHON!" -c "f=open(r\"!COMFYUI_SOURCE_DIR!\comfyui_version.py\").read(); print([l.split()[2].strip(chr(39)+chr(34)) for l in f.splitlines() if chr(95)+chr(95)+chr(118)+chr(101)+chr(114)+chr(115)+chr(105)+chr(111)+chr(110)+chr(95)+chr(95) in l][0])" 2^>nul') do set "COMFY_VER=%%V"
        echo [check] ComfyUI: !COMFY_VER!
        echo         Tested against: 0.19.x — other versions may work but are not guaranteed.
    ) else (
        echo [check] ComfyUI: version file not found ^(pre-0.19 or non-standard install^)
    )
) else (
    echo [check] ComfyUI: source directory not found — skipping version check.
)
echo.

REM --- Install ComfyUI requirements (ensures alembic and other deps are present) ---
if defined COMFYUI_SOURCE_DIR (
    if exist "!COMFYUI_SOURCE_DIR!\requirements.txt" (
        echo Installing ComfyUI requirements...
        "!PYTHON!" -m pip install -q -r "!COMFYUI_SOURCE_DIR!\requirements.txt"
    )
)
REM comfyui-frontend-package is required by recent ComfyUI versions but missing from some requirements.txt
"!PYTHON!" -m pip install -q comfyui-frontend-package

REM --- Common dependencies needed by multiple custom nodes ---
REM opencv-python is required by: radiance, ComfyUI-VideoHelperSuite, ComfyUI-Impact-Pack,
REM   ComfyUI-Easy-Use, ComfyUI-post-processing-nodes, comfy_nv_video_prep
echo Installing common node dependencies ^(opencv, accelerate, ollama^)...
"!PYTHON!" -m pip install -q opencv-python accelerate ollama

REM --- Ensure PyTorch is CUDA-enabled ---
nvidia-smi > nul 2>&1
if errorlevel 1 goto skip_torch_check

"!PYTHON!" -c "import torch; exit(0 if torch.cuda.is_available() else 1)" > nul 2>&1
if not errorlevel 1 goto skip_torch_check

echo.
echo [torch] PyTorch does not have CUDA support. Reinstalling with CUDA (cu128)...
echo [torch] This may take several minutes (downloading ~2.5 GB)...
"!PYTHON!" -m pip install --force-reinstall torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
echo [torch] Done. Restart ComfyUI to pick up the new torch.

:skip_torch_check

REM --- Ask which modules BEFORE installing nodes ---
if !CLEAN!==1 goto skip_module_prompt
if not defined MODULES (
    echo.
    echo ================================================================
    echo  Which modules do you want to install?
    echo ================================================================
    echo.
    echo  Available modules:
    echo    01       LLM Prompt Enhancer      ^(~65 GB, Gemma3 via Ollama^)
    echo    02       Image Deconstruction     ^(~51 GB^)
    echo    03       Targeted Inpainting      ^(~52 GB^)
    echo    04       Image to Gaussian Splat  ^(~3 GB^)
    echo    05       Novel View Synthesis     ^(~60 GB^)
    echo    06       Image to Equirectangular ^(~61 GB^)
    echo    07       Panorama to HDRI         ^(~23 GB^)
    echo    08       Image to 3D              ^(~20 GB^)
    echo    09       Image Cut Out Time to Move ^(~77 GB^)
    echo    10       Video to Video           ^(~143 GB^)
    echo    bonus-a  Texture Extraction       ^(~60 GB^)
    echo    bonus-b  Texture to PBR           ^(~10 GB^)
    echo.
    echo  Enter module numbers ^(e.g. 02,03,bonus-a^), "all", or press Enter to skip:
    echo.
    set /p MODULES="  Modules: "
)
:skip_module_prompt

REM --- Validate module names ---
if defined MODULES (
    if /i not "!MODULES!"=="all" (
        "!PYTHON!" -c "import sys; v={'01','02','03','04','05','06','07','08','09','10','bonus-a','bonus-b'}; bad=[t.strip() for t in sys.argv[1].split(',') if t.strip() and t.strip() not in v]; [print('[ERROR] Unknown module: '+b+'. Valid: 01-10, bonus-a, bonus-b') for b in bad]; sys.exit(len(bad))" "!MODULES!"
        if errorlevel 1 (
            echo.
            exit /b 1
        )
    )
)

REM --- Desktop App: all content goes into the installation location ---
if !INSTALL_TYPE!==desktop (
    set "NODES_DIR=!DESKTOP_USER_DIR!\custom_nodes"
    set "MODELS_ROOT=!DESKTOP_USER_DIR!"
    REM If the source dir is known, ensure its custom_nodes folder exists (prevents startup crash)
    if defined COMFYUI_SOURCE_DIR (
        if not exist "!COMFYUI_SOURCE_DIR!\custom_nodes" mkdir "!COMFYUI_SOURCE_DIR!\custom_nodes"
    )
) else (
    set "MODELS_ROOT=%INSTALL_LOCATION%"
)

echo.
echo Installing custom nodes into: !NODES_DIR!
if not exist "!NODES_DIR!" mkdir "!NODES_DIR!"
echo.
set NODE_COUNT=0

REM --- Clean mode: remove model files and exit, skip node install ---
if !CLEAN!==1 (
    if not defined MODULES (
        echo.
        echo  [ERROR] --clean requires --modules. Specify which modules to clean.
        echo  Example: install.bat %INSTALL_LOCATION% --clean --modules 04
        echo.
        exit /b 1
    )
    echo.
    echo ================================================================
    echo  Removing model files, workflows, and templates for: !MODULES!
    echo ================================================================
    echo.
    "!PYTHON!" "%~dp0download_models.py" --comfyui "!MODELS_ROOT!" --modules !MODULES! --clean

    REM Remove workflow files and template browser entries for each cleaned module
    set "WORKFLOWS_DEST=!INSTALL_LOCATION!\user\default\workflows\NVIDIA-GenAI-Creator-Toolkit"
    set "TEMPLATE_NODE_DIR=!NODES_DIR!\NVIDIA-GenAI-Creator-Toolkit"
    for /d %%D in ("%~dp0workflows\*") do (
        set "_MNAME=%%~nxD"
        set "MOD_NUM=!_MNAME:~0,2!"
        if "!_MNAME:~0,7!"=="bonus-a" set "MOD_NUM=bonus-a"
        if "!_MNAME:~0,7!"=="bonus-b" set "MOD_NUM=bonus-b"
        set "MATCH=0"
        echo ,!MODULES!, | findstr /i ",!MOD_NUM!," > nul 2>&1 && set "MATCH=1"
        if /i "!MODULES!"=="all" set "MATCH=1"
        if "!MATCH!"=="1" (
            if exist "!WORKFLOWS_DEST!\!_MNAME!" (
                rd /s /q "!WORKFLOWS_DEST!\!_MNAME!"
                echo   Removed workflow: !_MNAME!
            )
            if exist "!TEMPLATE_NODE_DIR!\example_workflows\!_MNAME!.json" del /q "!TEMPLATE_NODE_DIR!\example_workflows\!_MNAME!.json"
            if exist "!TEMPLATE_NODE_DIR!\example_workflows\!_MNAME!.jpg"  del /q "!TEMPLATE_NODE_DIR!\example_workflows\!_MNAME!.jpg"
            if exist "!TEMPLATE_NODE_DIR!\example_workflows\!_MNAME!-videoprep.json" del /q "!TEMPLATE_NODE_DIR!\example_workflows\!_MNAME!-videoprep.json"
            if exist "!TEMPLATE_NODE_DIR!\example_workflows\!_MNAME!-videoprep.jpg"  del /q "!TEMPLATE_NODE_DIR!\example_workflows\!_MNAME!-videoprep.jpg"
        )
    )
    exit /b 0
)

REM --- Core (always installed) ---
call :install_node "ComfyUI-Manager" "https://github.com/ltdrdata/ComfyUI-Manager" ""

REM --- Modules 01 + 02: Qwen utilities ---
set DO_INSTALL=0
echo ,!MODULES!, | findstr /i ",01," > nul 2>&1 && set DO_INSTALL=1
echo ,!MODULES!, | findstr /i ",02," > nul 2>&1 && set DO_INSTALL=1
if /i "!MODULES!"=="all" set DO_INSTALL=1
if !DO_INSTALL!==1 (
    call :install_node "ComfyUI-WJNodes" "https://github.com/807502278/ComfyUI-WJNodes" ""
    "!PYTHON!" -m pip install -q librosa
    call :install_node "ComfyUI-Easy-Use" "https://github.com/yolain/ComfyUI-Easy-Use" ""
)

REM --- Module 01: LLM Prompt Enhancer ---
set DO_INSTALL=0
echo ,!MODULES!, | findstr /i ",01," > nul 2>&1 && set DO_INSTALL=1
if /i "!MODULES!"=="all" set DO_INSTALL=1
if !DO_INSTALL!==1 (
    call :install_node "comfyui-ollama" "https://github.com/stavsap/comfyui-ollama" ""
)

REM --- Modules 02-07, Bonus A+B: TextureAlchemy ---
set DO_INSTALL=0
echo ,!MODULES!, | findstr /i ",02," > nul 2>&1 && set DO_INSTALL=1
echo ,!MODULES!, | findstr /i ",03," > nul 2>&1 && set DO_INSTALL=1
echo ,!MODULES!, | findstr /i ",04," > nul 2>&1 && set DO_INSTALL=1
echo ,!MODULES!, | findstr /i ",05," > nul 2>&1 && set DO_INSTALL=1
echo ,!MODULES!, | findstr /i ",06," > nul 2>&1 && set DO_INSTALL=1
echo ,!MODULES!, | findstr /i ",07," > nul 2>&1 && set DO_INSTALL=1
echo ,!MODULES!, | findstr /i ",bonus-a," > nul 2>&1 && set DO_INSTALL=1
echo ,!MODULES!, | findstr /i ",bonus-b," > nul 2>&1 && set DO_INSTALL=1
if /i "!MODULES!"=="all" set DO_INSTALL=1
if !DO_INSTALL!==1 (
    call :install_node "ComfyUI-TextureAlchemy" "https://github.com/amtarr/ComfyUI-TextureAlchemy" "Sandbox"
)

REM --- Module 03: Targeted Inpainting ---
set DO_INSTALL=0
echo ,!MODULES!, | findstr /i ",03," > nul 2>&1 && set DO_INSTALL=1
if /i "!MODULES!"=="all" set DO_INSTALL=1
if !DO_INSTALL!==1 (
    call :install_node "ComfyUI-Inpaint-CropAndStitch" "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch" ""
)

REM --- Modules 04 + 05: Gaussian Splat ---
set DO_INSTALL=0
echo ,!MODULES!, | findstr /i ",04," > nul 2>&1 && set DO_INSTALL=1
echo ,!MODULES!, | findstr /i ",05," > nul 2>&1 && set DO_INSTALL=1
if /i "!MODULES!"=="all" set DO_INSTALL=1
if !DO_INSTALL!==1 (
    call :install_node "ComfyUI-Sharp" "https://github.com/PozzettiAndrea/ComfyUI-Sharp" ""
    call :install_node "ComfyUI-GeometryPack" "https://github.com/PozzettiAndrea/ComfyUI-GeometryPack" ""
)

REM --- Module 06: Image to Equirectangularing ---
set DO_INSTALL=0
echo ,!MODULES!, | findstr /i ",06," > nul 2>&1 && set DO_INSTALL=1
if /i "!MODULES!"=="all" set DO_INSTALL=1
if !DO_INSTALL!==1 (
    call :install_node "ComfyUI-Easy-Use" "https://github.com/yolain/ComfyUI-Easy-Use" ""
    call :install_node "ComfyUI-Inpaint-CropAndStitch" "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch" ""
    call :install_node "ComfyUI-KJNodes" "https://github.com/kijai/ComfyUI-KJNodes" ""
)

REM --- Module 07: Panorama to HDRI ---
set DO_INSTALL=0
echo ,!MODULES!, | findstr /i ",07," > nul 2>&1 && set DO_INSTALL=1
if /i "!MODULES!"=="all" set DO_INSTALL=1
if !DO_INSTALL!==1 (
    call :install_node "Luminance-Stack-Processor" "https://github.com/sumitchatterjee13/Luminance-Stack-Processor" ""
    call :install_node "ComfyUI-Marigold" "https://github.com/kijai/ComfyUI-Marigold" ""
    echo Patching ComfyUI-Marigold for numpy 2.0 compatibility...
    powershell -Command "(Get-Content \"!NODES_DIR!\ComfyUI-Marigold\nodes.py\") -replace '\.tostring\(\)', '.tobytes()' | Set-Content \"!NODES_DIR!\ComfyUI-Marigold\nodes.py\""
    echo           Upgrading diffusers for huggingface_hub compatibility...
    "!PYTHON!" -m pip install -q --upgrade diffusers
)

REM --- Module 08: Trellis2 3D ---
set DO_INSTALL=0
echo ,!MODULES!, | findstr /i ",08," > nul 2>&1 && set DO_INSTALL=1
if /i "!MODULES!"=="all" set DO_INSTALL=1
if !DO_INSTALL!==1 (
    REM Warn if Python 3.13+ — CUDA wheels and open3d are not yet available for this version
    "!PYTHON!" -c "import sys; exit(0 if sys.version_info < (3,13) else 1)" > nul 2>&1
    if errorlevel 1 (
        echo.
        echo   [WARN] Module 08 ^(Trellis2^) works best with Python 3.11 or 3.12.
        echo          You are running Python 3.13, which is missing pre-built wheels
        echo          for open3d and Trellis2 CUDA extensions. Nodes may fail to load.
        echo          To fix: create a Python 3.11 or 3.12 conda env and re-run the installer.
        echo.
    )
    call :install_node "ComfyUI-Trellis2" "https://github.com/visualbruno/ComfyUI-Trellis2" ""

    REM Trellis2 pre-built CUDA wheels require PyTorch <= 2.10.x (C++ ABI compatibility).
    REM If torch 2.11+ is installed, downgrade to 2.10.0+cu128 before installing wheels.
    REM All other modules in this collection work fine on PyTorch 2.10.0.
    "!PYTHON!" -c "import torch; v=torch.__version__.split('+')[0].split('.'); exit(0 if (int(v[0]),int(v[1])) <= (2,8) else 1)" > nul 2>&1
    if errorlevel 1 (
        echo.
        echo   [Module 08] PyTorch 2.9+ detected. Trellis2 pre-built CUDA wheels require
        echo               PyTorch 2.8.x due to C++ ABI compatibility ^(Torch280 wheels
        echo               include all required packages for Python 3.12^). Downgrading to
        echo               2.8.0+cu128. All other modules remain fully functional.
        echo.
        "!PYTHON!" -m pip install -q torch==2.8.0 torchaudio==2.8.0 torchvision --index-url https://download.pytorch.org/whl/cu128
        echo   [Module 08] PyTorch downgrade complete.
        echo.
    )

    REM Always ensure torchaudio matches torch 2.8.0 — mismatched torchaudio DLL
    REM causes WJNodes and ComfyUI built-in audio nodes to fail on import.
    echo           Ensuring torchaudio 2.8.0 is installed...
    "!PYTHON!" -m pip install -q torchaudio==2.8.0 --index-url https://download.pytorch.org/whl/cu128

    REM Install pre-built CUDA wheels — avoids needing MSVC compiler on Windows
    echo.
    echo           Detecting PyTorch version for TRELLIS2 wheel selection...
    REM Find the highest available wheel folder as fallback
    set TRELLIS_TORCH=
    for /d %%D in ("!NODES_DIR!\ComfyUI-Trellis2\wheels\Windows\Torch*") do set TRELLIS_TORCH=%%~nxD
    REM Prefer exact version match if available
    "!PYTHON!" -c "import torch,os; v=torch.__version__.split('+')[0]; short='Torch'+''.join(v.split('.')); base=r'!NODES_DIR!\ComfyUI-Trellis2\wheels\Windows'; exact=os.path.join(base,short); print(short if os.path.isdir(exact) else '')" > "%TEMP%\trellis_exact.txt" 2>nul
    set /p TRELLIS_EXACT=<"%TEMP%\trellis_exact.txt"
    del "%TEMP%\trellis_exact.txt" 2>nul
    if not "!TRELLIS_EXACT!"=="" set TRELLIS_TORCH=!TRELLIS_EXACT!

    if "!TRELLIS_TORCH!"=="" (
        echo           [WARN] No TRELLIS2 wheels found. Install deps manually via ComfyUI Manager.
    ) else (
        echo           Installing TRELLIS2 pre-built wheels ^(!TRELLIS_TORCH!^)...
        "!PYTHON!" -c "import glob,subprocess,sys; py=f'cp{sys.version_info.major}{sys.version_info.minor}'; all_whl=glob.glob(sys.argv[1]); whl=[w for w in all_whl if py in w] or all_whl; results=[subprocess.run([sys.executable,'-m','pip','install','-q','--no-warn-script-location',w],capture_output=True) for w in whl]; ok=sum(1 for r in results if r.returncode==0); print(f'           Installed {ok} of {len(whl)} TRELLIS2 wheel(s).')" "!NODES_DIR!\ComfyUI-Trellis2\wheels\Windows\!TRELLIS_TORCH!\*.whl"
    )

    REM Install Trellis2 Python dependencies (meshlib etc. may not install via requirements.txt on all setups)
    echo           Installing Trellis2 Python dependencies...
    "!PYTHON!" -m pip install -q meshlib requests pymeshlab opencv-python scipy plotly rembg

    REM open3d has no PyPI wheel for newer Python versions — try prerelease then skip gracefully
    echo           Installing open3d...
    "!PYTHON!" -m pip install -q open3d > nul 2>&1
    if errorlevel 1 (
        "!PYTHON!" -m pip install -q --pre open3d > nul 2>&1
        if errorlevel 1 (
            echo           [WARN] open3d not available for this Python version.
            echo                  Trellis2 mesh preview may not work. Install manually if needed:
            echo                  pip install open3d
        ) else (
            echo           open3d installed ^(pre-release^).
        )
    ) else (
        echo           open3d installed.
    )

    REM Patch Trellis2 image_feature_extractor.py for transformers compatibility.
    REM DINOv3ViTModel nesting changed across transformers versions (.layer vs .model.layer).
    REM Use getattr fallback so the code works regardless of transformers version.
    echo           Patching Trellis2 for transformers compatibility...
    "!PYTHON!" -c "f=r'!NODES_DIR!\ComfyUI-Trellis2\trellis2\modules\image_feature_extractor.py'; t=open(f,encoding='utf-8').read(); t=t.replace('self.model.model.layer','getattr(self.model,chr(109)+chr(111)+chr(100)+chr(101)+chr(108),self.model).layer'); t=t.replace('self.model.layer','getattr(self.model,chr(109)+chr(111)+chr(100)+chr(101)+chr(108),self.model).layer'); open(f,'w',encoding='utf-8').write(t)"

    REM Patch Trellis2 dense attention for Windows: wrap flash_attn import in try/except
    REM with torch sdpa fallback (flash_attn has no pre-built Windows wheel).
    echo           Patching Trellis2 flash_attn for Windows sdpa fallback...
    "!PYTHON!" "%~dp0patch_flash_attn.py" "!NODES_DIR!\ComfyUI-Trellis2"
)

REM --- Module 09: Image Cut Out Time to Move ---
set DO_INSTALL=0
echo ,!MODULES!, | findstr /i ",09," > nul 2>&1 && set DO_INSTALL=1
if /i "!MODULES!"=="all" set DO_INSTALL=1
if !DO_INSTALL!==1 (
    call :install_node "comfy_nv_video_prep" "https://github.com/NVIDIA/comfy_nv_video_prep" ""
    call :install_node "ComfyUI-Custom-Scripts" "https://github.com/pythongosssss/ComfyUI-Custom-Scripts" ""
    call :install_node "ComfyUI_essentials" "https://github.com/cubiq/ComfyUI_essentials" ""
    call :install_node "ComfyUI-Inpaint-CropAndStitch" "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch" ""
    call :install_node "comfyui-sam2" "https://github.com/neverbiasu/ComfyUI-SAM2" ""
    call :install_node "ComfyUI-SAM3" "https://github.com/PozzettiAndrea/ComfyUI-SAM3" ""
    call :install_node "ComfyUI-VideoHelperSuite" "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite" ""
    call :install_node "ComfyUI-Impact-Pack" "https://github.com/ltdrdata/ComfyUI-Impact-Pack" ""
    call :install_node "ComfyUI-Easy-Use" "https://github.com/yolain/ComfyUI-Easy-Use" ""
    call :install_node "ComfyUI-WanVideoWrapper" "https://github.com/kijai/ComfyUI-WanVideoWrapper" ""
    call :install_node "ComfyUI-KJNodes" "https://github.com/kijai/ComfyUI-KJNodes" ""
    REM triton must match PyTorch version for torch.compile/inductor to work.
    REM WanVideoWrapper uses torch.compile — triton 3.3+ removes triton_key which
    REM torch 2.8.0 requires. Pin to 3.2.0 which is compatible with torch 2.8.x.
    echo           Pinning triton-windows to 3.2.0 for torch.compile compatibility...
    "!PYTHON!" -m pip install -q triton-windows==3.2.0.post21
)

REM --- Module 10: Video to Video ---
set DO_INSTALL=0
echo ,!MODULES!, | findstr /i ",10," > nul 2>&1 && set DO_INSTALL=1
if /i "!MODULES!"=="all" set DO_INSTALL=1
if !DO_INSTALL!==1 (
    call :install_node "ComfyUI-WanVideoWrapper" "https://github.com/kijai/ComfyUI-WanVideoWrapper" ""
    call :install_node "ComfyUI-Lotus" "https://github.com/kijai/ComfyUI-Lotus" ""
    call :install_node "ComfyUI-KJNodes" "https://github.com/kijai/ComfyUI-KJNodes" ""
    call :install_node "ComfyUI-Custom-Scripts" "https://github.com/pythongosssss/ComfyUI-Custom-Scripts" ""
    call :install_node "ComfyUI-VideoHelperSuite" "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite" ""
    call :install_node "comfyui-post-processing-nodes" "https://github.com/EllangoK/ComfyUI-post-processing-nodes" ""
    call :install_node "cg-use-everywhere" "https://github.com/chrisgoringe/cg-use-everywhere" ""
    call :install_node "radiance" "https://github.com/fxtdstudios/radiance" ""
    call :install_node "comfyui-rtx-simple" "https://github.com/BetaDoggo/comfyui-rtx-simple" ""
    call :install_node "ComfyUI-Impact-Pack" "https://github.com/ltdrdata/ComfyUI-Impact-Pack" ""
    echo           Installing NVIDIA VFX SDK for RTX Super Resolution...
    "!PYTHON!" -m pip install -q nvidia-vfx --extra-index-url https://pypi.nvidia.com/ > "%TEMP%\comfyui_pip.tmp" 2>&1
    if errorlevel 1 (
        echo           [WARN] nvidia-vfx install failed. RTX Super Resolution node may not load.
        echo                  Requires CUDA 12+ and an RTX GPU. Details: type %TEMP%\comfyui_pip.tmp
    )
)

REM --- Bonus A: Texture Extraction ---
set DO_INSTALL=0
echo ,!MODULES!, | findstr /i ",bonus-a," > nul 2>&1 && set DO_INSTALL=1
if /i "!MODULES!"=="all" set DO_INSTALL=1
if !DO_INSTALL!==1 (
    call :install_node "ComfyUI-Easy-Use" "https://github.com/yolain/ComfyUI-Easy-Use" ""
    call :install_node "ComfyUI-Inpaint-CropAndStitch" "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch" ""
    call :install_node "ComfyUI-KJNodes" "https://github.com/kijai/ComfyUI-KJNodes" ""
)

REM --- Bonus B: Texture to PBR ---
set DO_INSTALL=0
echo ,!MODULES!, | findstr /i ",bonus-b," > nul 2>&1 && set DO_INSTALL=1
if /i "!MODULES!"=="all" set DO_INSTALL=1
if !DO_INSTALL!==1 (
    call :install_node "ComfyUI-Easy-Use" "https://github.com/yolain/ComfyUI-Easy-Use" ""
    call :install_node "ComfyUI-Lotus" "https://github.com/kijai/ComfyUI-Lotus" ""
    call :install_node "ComfyUI-Marigold" "https://github.com/kijai/ComfyUI-Marigold" ""
    echo Patching ComfyUI-Marigold for numpy 2.0 compatibility...
    powershell -Command "(Get-Content \"!NODES_DIR!\ComfyUI-Marigold\nodes.py\") -replace '\.tostring\(\)', '.tobytes()' | Set-Content \"!NODES_DIR!\ComfyUI-Marigold\nodes.py\""
    echo           Upgrading diffusers for huggingface_hub compatibility...
    "!PYTHON!" -m pip install -q --upgrade diffusers
)

REM --- Copy workflow JSONs into ComfyUI Workflows tab ---
set "WORKFLOWS_DEST=%INSTALL_LOCATION%\user\default\workflows\NVIDIA-GenAI-Creator-Toolkit"
if not exist "!WORKFLOWS_DEST!" mkdir "!WORKFLOWS_DEST!"
for /d %%D in ("%~dp0workflows\*") do (
  set "MODULE_NAME=%%~nxD"
  set "MOD_NUM=!MODULE_NAME:~0,2!"
  if "!MODULE_NAME:~0,7!"=="bonus-a" set "MOD_NUM=bonus-a"
  if "!MODULE_NAME:~0,7!"=="bonus-b" set "MOD_NUM=bonus-b"
  set "COPY_THIS=0"
  if "!MODULES!"=="" set "COPY_THIS=1"
  if /i "!MODULES!"=="all" set "COPY_THIS=1"
  echo ,!MODULES!, | findstr /i ",!MOD_NUM!," > nul 2>&1 && set "COPY_THIS=1"
  if "!COPY_THIS!"=="1" (
    if exist "%%D\!MODULE_NAME!.json" (
      if not exist "!WORKFLOWS_DEST!\!MODULE_NAME!" mkdir "!WORKFLOWS_DEST!\!MODULE_NAME!"
      copy /y "%%D\!MODULE_NAME!.json" "!WORKFLOWS_DEST!\!MODULE_NAME!\!MODULE_NAME!.json" > nul
      if exist "%%D\!MODULE_NAME!-videoprep.json" (
        copy /y "%%D\!MODULE_NAME!-videoprep.json" "!WORKFLOWS_DEST!\!MODULE_NAME!\!MODULE_NAME!-videoprep.json" > nul
      )
    )
  )
)
echo Workflows copied to: !WORKFLOWS_DEST!
echo.

REM --- Copy sample inputs into ComfyUI ---
set "INPUTS_DEST=%INSTALL_LOCATION%\input"
if not exist "!INPUTS_DEST!" mkdir "!INPUTS_DEST!"
for /d %%D in ("%~dp0workflows\*") do (
  set "MODULE_NAME=%%~nxD"
  set "MOD_NUM=!MODULE_NAME:~0,2!"
  if "!MODULE_NAME:~0,7!"=="bonus-a" set "MOD_NUM=bonus-a"
  if "!MODULE_NAME:~0,7!"=="bonus-b" set "MOD_NUM=bonus-b"
  set "COPY_THIS=0"
  if "!MODULES!"=="" set "COPY_THIS=1"
  if /i "!MODULES!"=="all" set "COPY_THIS=1"
  echo ,!MODULES!, | findstr /i ",!MOD_NUM!," > nul 2>&1 && set "COPY_THIS=1"
  if "!COPY_THIS!"=="1" (
    if exist "%%D\input\" (
      copy /y "%%D\input\*" "!INPUTS_DEST!\" > nul
    )
  )
)
echo Sample inputs copied to: !INPUTS_DEST!
echo.

REM --- Install template browser extension ---
REM Creates a lightweight custom node whose example_workflows\ folder makes all
REM workflows appear in ComfyUI's template browser under Extensions.
echo.
echo Installing template browser extension...
set "TEMPLATE_NODE=NVIDIA-GenAI-Creator-Toolkit"
set "TEMPLATE_NODE_DIR=!NODES_DIR!\!TEMPLATE_NODE!"
if not exist "!TEMPLATE_NODE_DIR!" mkdir "!TEMPLATE_NODE_DIR!"
copy /y "%~dp0custom_node\__init__.py" "!TEMPLATE_NODE_DIR!\__init__.py" > nul
if not exist "!TEMPLATE_NODE_DIR!\example_workflows" mkdir "!TEMPLATE_NODE_DIR!\example_workflows"
for /d %%D in ("%~dp0workflows\*") do (
    set "_MNAME=%%~nxD"
    set "MOD_NUM=!_MNAME:~0,2!"
    if "!_MNAME:~0,7!"=="bonus-a" set "MOD_NUM=bonus-a"
    if "!_MNAME:~0,7!"=="bonus-b" set "MOD_NUM=bonus-b"
    set "COPY_THIS=0"
    if "!MODULES!"=="" set "COPY_THIS=1"
    if /i "!MODULES!"=="all" set "COPY_THIS=1"
    echo ,!MODULES!, | findstr /i ",!MOD_NUM!," > nul 2>&1 && set "COPY_THIS=1"
    if "!COPY_THIS!"=="1" (
        if exist "%%D\!_MNAME!.json" (
            copy /y "%%D\!_MNAME!.json" "!TEMPLATE_NODE_DIR!\example_workflows\!_MNAME!.json" > nul
            if exist "%%D\!_MNAME!-videoprep.json" (
                copy /y "%%D\!_MNAME!-videoprep.json" "!TEMPLATE_NODE_DIR!\example_workflows\!_MNAME!-videoprep.json" > nul
                if exist "%%D\images\preview-videoprep.jpg" (
                    copy /y "%%D\images\preview-videoprep.jpg" "!TEMPLATE_NODE_DIR!\example_workflows\!_MNAME!-videoprep.jpg" > nul
                )
            )
            if exist "%%D\images\preview.png" (
                copy /y "%%D\images\preview.png" "!TEMPLATE_NODE_DIR!\example_workflows\!_MNAME!.jpg" > nul
            ) else if exist "%%D\images\preview.gif" (
                copy /y "%%D\images\preview.gif" "!TEMPLATE_NODE_DIR!\example_workflows\!_MNAME!.jpg" > nul
            )
        )
    )
)
echo   Workflows available in template browser: Extensions ^> !TEMPLATE_NODE!

REM --- Write ComfyUI settings: show template browser on next launch ---
set "SETTINGS_FILE=!INSTALL_LOCATION!\user\default\comfy.settings.json"
if not exist "!INSTALL_LOCATION!\user\default" mkdir "!INSTALL_LOCATION!\user\default"
"!PYTHON!" -c "import json,os; f=r'!SETTINGS_FILE!'; s=json.load(open(f)) if os.path.isfile(f) else {}; s['Comfy.TutorialCompleted']=False; open(f,'w').write(json.dumps(s,indent=4))"
echo   ComfyUI will open the template browser on next launch.

REM --- Normalize model path separators to Windows backslash ---
REM ComfyUI on Windows resolves model paths with backslashes; JSONs authored on
REM Mac/Linux store forward slashes which cause "model not found" on first load.
REM This patches the installed copies only — repo files are not modified.
echo.
echo Normalizing workflow model paths for Windows...
"!PYTHON!" "%~dp0normalize_paths_win.py" "!WORKFLOWS_DEST!" "!TEMPLATE_NODE_DIR!\example_workflows"

REM --- Offer to install Ollama if module 01 or all selected ---
set NEEDS_OLLAMA=0
echo ,!MODULES!, | findstr /i ",01," > nul 2>&1 && set NEEDS_OLLAMA=1
if /i "!MODULES!"=="all" set NEEDS_OLLAMA=1

if not "!NEEDS_OLLAMA!"=="1" goto skip_ollama

set OLLAMA_FOUND=0
set "OLLAMA_EXE=ollama"
ollama --version > nul 2>&1
if not errorlevel 1 set OLLAMA_FOUND=1
if "!OLLAMA_FOUND!"=="0" if exist "%LOCALAPPDATA%\Programs\Ollama\ollama.exe" (
    set OLLAMA_FOUND=1
    set "OLLAMA_EXE=%LOCALAPPDATA%\Programs\Ollama\ollama.exe"
)

if "!OLLAMA_FOUND!"=="1" goto ollama_check_gemma

echo.
echo ================================================================
echo  Module 01 requires Ollama ^(not detected on this machine^)
echo ================================================================
echo.
choice /c YN /m "  Install Ollama now?"
if not errorlevel 2 (
    echo.
    echo  Installing Ollama...
    powershell -Command "irm https://ollama.com/install.ps1 | iex"
    echo.
    choice /c YN /m "  Pull gemma3 model now? (~5 GB)"
    if not errorlevel 2 (
        echo.
        "!OLLAMA_EXE!" pull gemma3
    )
)
REM Re-check in case Ollama was present but undetected at script start (e.g. not yet in PATH)
ollama --version > nul 2>&1
if not errorlevel 1 (
    set OLLAMA_FOUND=1
    set "OLLAMA_EXE=ollama"
    goto ollama_check_gemma
)
if exist "%LOCALAPPDATA%\Programs\Ollama\ollama.exe" (
    set OLLAMA_FOUND=1
    set "OLLAMA_EXE=%LOCALAPPDATA%\Programs\Ollama\ollama.exe"
    goto ollama_check_gemma
)
goto skip_ollama

:ollama_check_gemma
echo.
echo  Ollama already installed.
set GEMMA_FOUND=0
"!OLLAMA_EXE!" list > "%TEMP%\ollama_list.tmp" 2>nul
findstr /i "gemma3" "%TEMP%\ollama_list.tmp" > nul 2>&1
if not errorlevel 1 set GEMMA_FOUND=1
if "!GEMMA_FOUND!"=="1" (
    echo  gemma3 already pulled.
) else (
    choice /c YN /m "  Pull gemma3 model now? (~5 GB)"
    if not errorlevel 2 (
        echo.
        "!OLLAMA_EXE!" pull gemma3
    )
)

:skip_ollama

if /i not "!MODULES!"=="" (
    echo.
    echo ================================================================
    echo  Step: HuggingFace Login
    echo ================================================================
    echo.
    echo  HuggingFace login is required for:
    echo    - Faster, rate-limit-free downloads
    echo    - Gated models ^(Module 07 Flux.1-dev, Module 08 DINOv3^)
    echo.
    set HF_LOGGED_IN=0
    "!PYTHON!" -c "from huggingface_hub import get_token; exit(0 if get_token() else 1)" > nul 2>&1
    if not errorlevel 1 (
        set HF_LOGGED_IN=1
        echo  Already logged in to HuggingFace.
    )
    if "!HF_LOGGED_IN!"=="0" (
        echo  Not currently logged in.
        echo.
        choice /c YN /m "  Log in to HuggingFace now?"
        if not errorlevel 2 (
            echo.
            echo  Running: huggingface-cli login
            echo  ^(You will be prompted to enter or paste your HuggingFace token.^)
            echo  Get a token at: https://huggingface.co/settings/tokens
            echo.
            for %%F in ("!PYTHON!") do set "PYTHON_DIR=%%~dpF"
            if exist "!PYTHON_DIR!huggingface-cli.exe" (
                "!PYTHON_DIR!huggingface-cli.exe" login
            ) else (
                echo  huggingface-cli not found. Run manually after install: huggingface-cli login
            )
        ) else (
            echo.
            echo  Skipping login. Gated model downloads ^(Module 07, 08^) will fail.
            echo  To log in later: huggingface-cli login
        )
    )
    echo.
    echo ================================================================
    echo  Downloading models for modules: !MODULES!
    echo ================================================================
    echo.
    "!PYTHON!" "%~dp0download_models.py" --comfyui "!MODELS_ROOT!" --modules !MODULES!
    if errorlevel 1 (
        echo.
        echo ================================================================
        echo  [ERROR] One or more model downloads failed after 3 attempts.
        echo ================================================================
        echo.
        echo  This is usually a temporary network or HuggingFace issue.
        echo  Already-downloaded models will be skipped on retry.
        echo.
        echo  To retry, run:
        echo    install.bat %INSTALL_LOCATION% --modules !MODULES!
        echo.
        echo  Do NOT launch ComfyUI until all models are downloaded --
        echo  workflows will fail to run with missing models.
        echo.
        exit /b 1
    )
)

echo.
echo ================================================================
echo  Installation complete
echo ================================================================
echo.
echo  Workflows available in template browser: Browse Templates ^> Extensions ^> NVIDIA-GenAI-Creator-Toolkit
echo.
echo  To install a different module later, run:
echo    install.bat %INSTALL_LOCATION% --modules 03
echo  ^(already-installed nodes are skipped automatically^)
echo.

REM Ask user if they want to launch ComfyUI now
if !INSTALL_TYPE!==desktop (
    echo  Launch ComfyUI using the Desktop App icon to load your models and nodes correctly.
    echo.
    goto skip_launch
)
choice /c YN /m "  Launch ComfyUI now?"
if not errorlevel 2 (
    if exist "!INSTALL_PARENT!\run_nvidia_gpu.bat" (
        echo.
        echo  Launching ComfyUI ^(Portable^)...
        pushd "!INSTALL_PARENT!"
        start "" "run_nvidia_gpu.bat"
        popd
    ) else if exist "%INSTALL_LOCATION%\run_nvidia_gpu.bat" (
        echo.
        echo  Launching ComfyUI ^(Portable^)...
        pushd "%INSTALL_LOCATION%"
        start "" "run_nvidia_gpu.bat"
        popd
    ) else if exist "%INSTALL_LOCATION%\venv\Scripts\activate.bat" (
        echo.
        echo  Launching ComfyUI ^(venv^)...
        start cmd /k "cd /d "%INSTALL_LOCATION%" && venv\Scripts\activate && python main.py"
    ) else if defined COMFYUI_SOURCE_DIR (
        echo.
        echo  Launching ComfyUI...
        start cmd /k "cd /d "!COMFYUI_SOURCE_DIR!" && "!PYTHON!" main.py"
    ) else (
        echo.
        echo  Could not detect launch method. Start ComfyUI manually.
    )
) else (
    echo.
    echo  To launch ComfyUI later:
    echo    Portable: run_nvidia_gpu.bat ^(in the portable root folder^)
    echo    Manual install: venv\Scripts\activate ^&^& python main.py
)
echo.
:skip_launch
goto :eof

:install_node
set NODE_NAME=%~1
set NODE_REPO=%~2
set NODE_BRANCH=%~3
set NODE_DIR=%NODES_DIR%\%NODE_NAME%
set /a NODE_COUNT+=1

if exist "%NODE_DIR%" (
  echo   [%NODE_COUNT%] skip    %NODE_NAME% ^(already installed^)
) else (
  echo   [%NODE_COUNT%] install %NODE_NAME% ...
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
    echo           OK
  )
)

if exist "%NODE_DIR%\requirements.txt" (
  echo           Installing Python requirements...
  "%PYTHON%" -m pip install -q --no-warn-script-location -r "%NODE_DIR%\requirements.txt" > "%TEMP%\comfyui_pip.tmp" 2>&1
  if errorlevel 1 (
    echo           [WARN] Some packages failed to install for !NODE_NAME!
    echo                  This is usually OK - ComfyUI Manager resolves missing deps on first run.
    echo                  To see details: type %TEMP%\comfyui_pip.tmp
  )
)
goto :eof
