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

REM Strip trailing backslash (causes quoting issues when path is passed to Python)
if "%COMFYUI_DIR:~-1%"=="\" set "COMFYUI_DIR=%COMFYUI_DIR:~0,-1%"

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
REM Priority: Portable embedded Python (same dir or parent) > venv > conda > system pip
REM
REM ComfyUI Portable layout:
REM   <root>\python_embeded\   <- embedded Python here
REM   <root>\ComfyUI\main.py   <- main.py here (one level down)
REM Uses !PIP_FOUND! (delayed expansion) to short-circuit once a pip is found.
set PIP_FOUND=0

REM Resolve the parent directory as an absolute path so 'if exist' works reliably
for %%I in ("%COMFYUI_DIR%\..") do set "COMFYUI_PARENT=%%~fI"

if exist "%COMFYUI_DIR%\python_embeded\python.exe" (
    set "PYTHON=%COMFYUI_DIR%\python_embeded\python.exe"
    set PIP_FOUND=1
    echo Detected ComfyUI Portable - using embedded Python
)

if !PIP_FOUND!==0 if exist "!COMFYUI_PARENT!\python_embeded\python.exe" (
    set "PYTHON=!COMFYUI_PARENT!\python_embeded\python.exe"
    set PIP_FOUND=1
    echo Detected ComfyUI Portable - using embedded Python ^(parent directory^)
)

if !PIP_FOUND!==0 if exist "%COMFYUI_DIR%\venv\Scripts\python.exe" (
    set "PYTHON=%COMFYUI_DIR%\venv\Scripts\python.exe"
    set PIP_FOUND=1
    echo Detected venv - using %COMFYUI_DIR%\venv\Scripts\python.exe
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

REM --- Install ComfyUI requirements (ensures alembic and other deps are present) ---
if exist "%COMFYUI_DIR%\requirements.txt" (
    echo.
    echo Installing ComfyUI requirements...
    "!PYTHON!" -m pip install -q -r "%COMFYUI_DIR%\requirements.txt"
)

REM --- Ensure PyTorch is CUDA-enabled ---
nvidia-smi > nul 2>&1
if errorlevel 1 goto skip_torch_check

"!PYTHON!" -c "import torch; exit(0 if torch.cuda.is_available() else 1)" > nul 2>&1
if not errorlevel 1 goto skip_torch_check

echo.
echo [torch] PyTorch is installed but CUDA is not available. Reinstalling with CUDA support...

REM Detect CUDA version from nvidia-smi and map to PyTorch wheel tag
"!PYTHON!" -c "import subprocess,re,sys; o=subprocess.run(['nvidia-smi'],capture_output=True,text=True).stdout; m=re.search(r'CUDA Version: ([0-9]+)[.]([0-9]+)',o); v=(int(m.group(1)),int(m.group(2))) if m else (12,8); tag='cu118' if v[0]<12 else 'cu121' if v<(12,4) else 'cu124' if v<(12,6) else 'cu126' if v<(12,8) else 'cu128'; open('%TEMP%\\\\cuda_tag.tmp','w').write(tag)" 2>nul
set /p CUDA_TAG=< "%TEMP%\cuda_tag.tmp"
del "%TEMP%\cuda_tag.tmp" 2>nul
if "!CUDA_TAG!"=="" set CUDA_TAG=cu128

echo [torch] Installing for CUDA !CUDA_TAG! (this may take a few minutes)...
"!PYTHON!" -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/!CUDA_TAG! -q
echo [torch] Done.

:skip_torch_check

REM --- Ask which modules BEFORE installing nodes ---
if not defined MODULES (
    echo.
    echo ================================================================
    echo  Which modules do you want to install?
    echo ================================================================
    echo.
    echo  Available modules:
    echo    01       LLM Prompt Enhancer      ^(Ollama/Gemma3 — no download needed^)
    echo    02       Image Deconstruction     ^(~8 GB^)
    echo    03       Targeted Inpainting      ^(~8 GB^)
    echo    04       Image to Gaussian Splat  ^(~1 GB^)
    echo    05       Gaussian Splat SceneFill ^(~8 GB^)
    echo    06       Equirectangular Outpaint ^(~12 GB^)
    echo    07       Panorama to HDRI         ^(~24 GB^)
    echo    08       Trellis2 3D Asset Gen    ^(~20 GB^)
    echo    09       Cutout Animation         ^(~30 GB^)
    echo    10       Playblast to Video       ^(~30 GB^)
    echo    bonus-a  Texture Extraction       ^(~8 GB^)
    echo    bonus-b  Texture to PBR           ^(~12 GB^)
    echo.
    echo  Enter module numbers ^(e.g. 02,03,08^), "all", or press Enter to skip:
    echo.
    set /p MODULES="  Modules: "
)

echo.
echo Installing custom nodes into: %NODES_DIR%
if not exist "%NODES_DIR%" mkdir "%NODES_DIR%"
echo.
set NODE_COUNT=0

REM --- Core (always installed) ---
call :install_node "ComfyUI-Manager" "https://github.com/ltdrdata/ComfyUI-Manager" ""

REM --- Modules 01 + 02: Qwen utilities ---
set DO_INSTALL=0
echo ,!MODULES!, | findstr /i ",01," > nul 2>&1 && set DO_INSTALL=1
echo ,!MODULES!, | findstr /i ",02," > nul 2>&1 && set DO_INSTALL=1
if /i "!MODULES!"=="all" set DO_INSTALL=1
if !DO_INSTALL!==1 (
    call :install_node "ComfyUI-WJNodes" "https://github.com/807502278/ComfyUI-WJNodes" ""
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

REM --- Module 06: Equirectangular Outpainting ---
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
)

REM --- Module 08: Trellis2 3D ---
set DO_INSTALL=0
echo ,!MODULES!, | findstr /i ",08," > nul 2>&1 && set DO_INSTALL=1
if /i "!MODULES!"=="all" set DO_INSTALL=1
if !DO_INSTALL!==1 (
    call :install_node "ComfyUI-Trellis2" "https://github.com/visualbruno/ComfyUI-Trellis2" ""

    REM Install pre-built CUDA wheels — avoids needing MSVC compiler on Windows Portable
    echo.
    echo           Detecting PyTorch version for TRELLIS2 wheel selection...
    "!PYTHON!" -c "import torch; v=torch.__version__; print('270' if v.startswith('2.7') else '280' if v.startswith('2.8') else 'unsupported')" > "%TEMP%\trellis_torch.txt" 2>nul
    set /p TRELLIS_TORCH=<"%TEMP%\trellis_torch.txt"
    del "%TEMP%\trellis_torch.txt" 2>nul

    if "!TRELLIS_TORCH!"=="unsupported" (
        echo           [WARN] PyTorch 2.7 or 2.8 not detected. Install TRELLIS2 wheels manually from:
        echo                  !NODES_DIR!\ComfyUI-Trellis2\wheels\Windows\
    ) else (
        echo           Installing TRELLIS2 pre-built wheels ^(PyTorch !TRELLIS_TORCH!^)...
        "!PYTHON!" -c "import glob,subprocess,sys; whl=glob.glob(sys.argv[1]); [subprocess.run([sys.executable,'-m','pip','install','-q','--no-warn-script-location',w],check=False) for w in whl]; print(f'           Installed {len(whl)} TRELLIS2 wheel(s).')" "!NODES_DIR!\ComfyUI-Trellis2\wheels\Windows\Torch!TRELLIS_TORCH!\*.whl"
    )
)

REM --- Module 09: Cutout Animation ---
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
)

REM --- Module 10: Playblast to Video ---
set DO_INSTALL=0
echo ,!MODULES!, | findstr /i ",10," > nul 2>&1 && set DO_INSTALL=1
if /i "!MODULES!"=="all" set DO_INSTALL=1
if !DO_INSTALL!==1 (
    call :install_node "ComfyUI-WanVideoWrapper" "https://github.com/kijai/ComfyUI-WanVideoWrapper" ""
    call :install_node "ComfyUI-KJNodes" "https://github.com/kijai/ComfyUI-KJNodes" ""
    call :install_node "cg-use-everywhere" "https://github.com/chrisgoringe/cg-use-everywhere" ""
    call :install_node "radiance" "https://github.com/fxtdstudios/radiance" ""
    call :install_node "ComfyUI-Impact-Pack" "https://github.com/ltdrdata/ComfyUI-Impact-Pack" ""
    call :install_node "ComfyUI-Lotus" "https://github.com/kijai/ComfyUI-Lotus" ""
    call :install_node "ComfyUI-post-processing-nodes" "https://github.com/EllangoK/ComfyUI-post-processing-nodes" ""
    call :install_node "ComfyUI-VideoUpscale_WithModel" "https://github.com/ShmuelRonen/ComfyUI-VideoUpscale_WithModel" ""
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
)

REM --- Copy workflow JSON files and sample inputs into ComfyUI ---
set WORKFLOWS_DEST=%COMFYUI_DIR%\user\default\workflows\creative-genai-workflows
set INPUTS_DEST=%COMFYUI_DIR%\input
if not exist "%WORKFLOWS_DEST%" mkdir "%WORKFLOWS_DEST%"
if not exist "%INPUTS_DEST%" mkdir "%INPUTS_DEST%"
for /d %%D in ("%~dp0workflows\*") do (
  if exist "%%D\workflow.json" (
    set "MODULE_NAME=%%~nxD"
    if not exist "%WORKFLOWS_DEST%\!MODULE_NAME!" mkdir "%WORKFLOWS_DEST%\!MODULE_NAME!"
    copy /y "%%D\workflow.json" "%WORKFLOWS_DEST%\!MODULE_NAME!\!MODULE_NAME!.json" > nul
    if exist "%%D\videoprep.json" (
      copy /y "%%D\videoprep.json" "%WORKFLOWS_DEST%\!MODULE_NAME!\!MODULE_NAME!-videoprep.json" > nul
    )
    if exist "%%D\input\" (
      copy /y "%%D\input\*" "%INPUTS_DEST%\" > nul
    )
  )
)
REM --- Patch model paths in workflow JSONs for Windows (forward slash -> backslash) ---
REM ComfyUI on Windows lists models with backslashes; the JSONs were authored on Linux.
"!PYTHON!" "%~dp0patch_model_paths.py" "%WORKFLOWS_DEST%"
echo.
echo Workflows copied to: %WORKFLOWS_DEST%
echo Sample inputs copied to: %INPUTS_DEST%

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
    echo  Downloading models for modules: !MODULES!
    echo ================================================================
    echo.
    echo  TIP: Log in to HuggingFace for faster downloads and access to
    echo  gated models ^(required for Module 07 Flux^):
    echo    huggingface-cli login
    echo.
    "!PYTHON!" "%~dp0download_models.py" --comfyui "%COMFYUI_DIR%" --modules !MODULES!
)

echo.
echo ================================================================
echo  Installation complete
echo ================================================================
echo.
echo  Workflows are pre-loaded in ComfyUI under: Load ^> creative-genai-workflows
echo.
echo  To install a different module later, run:
echo    install.bat %COMFYUI_DIR% --modules 03
echo  ^(already-installed nodes are skipped automatically^)
echo.

REM Ask user if they want to launch ComfyUI now
choice /c YN /m "  Launch ComfyUI now?"
if not errorlevel 2 (
    if exist "!COMFYUI_PARENT!\run_nvidia_gpu.bat" (
        echo.
        echo  Launching ComfyUI ^(Portable^)...
        pushd "!COMFYUI_PARENT!"
        start "" "run_nvidia_gpu.bat"
        popd
    ) else if exist "%COMFYUI_DIR%\run_nvidia_gpu.bat" (
        echo.
        echo  Launching ComfyUI ^(Portable^)...
        pushd "%COMFYUI_DIR%"
        start "" "run_nvidia_gpu.bat"
        popd
    ) else if exist "%COMFYUI_DIR%\venv\Scripts\activate.bat" (
        echo.
        echo  Launching ComfyUI ^(venv^)...
        start cmd /k "cd /d "%COMFYUI_DIR%" && venv\Scripts\activate && python main.py"
    ) else if defined PYTHON (
        echo.
        echo  Launching ComfyUI...
        start cmd /k "cd /d "!COMFYUI_DIR!" && "!PYTHON!" main.py"
    ) else (
        echo.
        echo  Could not detect launch method. Start ComfyUI manually:
        echo    Portable: run_nvidia_gpu.bat ^(in the portable root folder^)
        echo    Manual install: venv\Scripts\activate ^&^& python main.py
    )
) else (
    echo.
    echo  To launch ComfyUI later:
    echo    Portable: run_nvidia_gpu.bat ^(in the portable root folder^)
    echo    Manual install: venv\Scripts\activate ^&^& python main.py
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
