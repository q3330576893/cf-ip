@echo off
setlocal
set "PYTHONPATH=%~dp0lib"
set "PYTHONIOENCODING=utf-8"
cd /d "%~dp0"
"C:\Users\Administrator\AppData\Local\Programs\Python\Python314\python.exe" "%~dp0main.py" >> "%~dp0run.log" 2>&1
echo [exit=%ERRORLEVEL%] %DATE% %TIME% >> "%~dp0run.log"
