@echo off
REM install.bat — ComfyUI custom node installer for comfyui-generative-ai-workflows
REM No UI. Run from the ComfyUI root directory:
REM   install.bat
REM   install.bat C:\path\to\ComfyUI
REM
REM What this does:
REM   1. Installs ComfyUI-Manager (if not already present)
REM   2. Clones all required custom node packs
REM   3. Installs each pack's Python dependencies
REM   4. Reminds you to install Ollama (required for Module 01)
REM
REM Does NOT download models — see each module's models.md for that.

setlocal enabledelayedexpansion

if "%~1"=="" (
  set COMFYUI_DIR=%cd%
) else (
  set COMFYUI_DIR=%~1
)

set NODES_DIR=%COMFYUI_DIR%\custom_nodes

if not exist "%COMFYUI_DIR%\main.py" (
  echo ERROR: Run this from the ComfyUI root directory, or pass it as an argument:
  echo   install.bat C:\path\to\ComfyUI
  exit /b 1
)

echo Installing custom nodes into: %NODES_DIR%
if not exist "%NODES_DIR%" mkdir "%NODES_DIR%"

echo.
echo === ComfyUI Manager ===
call :install_node "ComfyUI-Manager" "https://github.com/ltdrdata/ComfyUI-Manager"

echo.
echo === Module 01 — LLM Prompt Enhancer ===
call :install_node "ComfyUI-Ollama" "https://github.com/stavsap/ComfyUI-Ollama"

echo.
echo === Modules 04 + 05 — Gaussian Splat ===
call :install_node "ComfyUI-Sharp" "https://github.com/PozzettiAndrea/ComfyUI-Sharp"
call :install_node "ComfyUI-GeometryPack" "https://github.com/PozzettiAndrea/ComfyUI-GeometryPack"

echo.
echo === Module 08 — Trellis2 ===
call :install_node "ComfyUI-TRELLIS2" "https://github.com/PozzettiAndrea/ComfyUI-TRELLIS2"

echo.
echo === Modules 09 + 10 — Wan Video ===
call :install_node "ComfyUI-WanVideoWrapper" "https://github.com/kijai/ComfyUI-WanVideoWrapper"
call :install_node "ComfyUI-VideoHelperSuite" "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
call :install_node "comfyui_controlnet_aux" "https://github.com/Fannovel16/comfyui_controlnet_aux"

echo.
echo === Bonus B — Texture to PBR ===
call :install_node "ComfyUI-Marigold" "https://github.com/kijai/ComfyUI-Marigold"

echo.
echo === Done ===
echo.
echo Next steps:
echo   1. Install Ollama for Module 01: https://ollama.com/download
echo      Then run: ollama pull gemma3
echo   2. Download models — see each workflow's models.md
echo      Large models (Wan2.2, Trellis2) should be pre-downloaded before running
echo   3. Launch ComfyUI: python main.py
echo   4. Drag a workflow.json into the ComfyUI canvas
goto :eof

:install_node
set NODE_NAME=%~1
set NODE_REPO=%~2
set NODE_DIR=%NODES_DIR%\%NODE_NAME%

if exist "%NODE_DIR%" (
  echo   [skip] %NODE_NAME% already installed
) else (
  echo   [install] %NODE_NAME%
  git clone --depth 1 %NODE_REPO% "%NODE_DIR%"
)

if exist "%NODE_DIR%\requirements.txt" (
  pip install -q -r "%NODE_DIR%\requirements.txt"
)
goto :eof
