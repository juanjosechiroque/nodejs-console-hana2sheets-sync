@echo off
cd C:\project-folder
node index.js

if %ERRORLEVEL% NEQ 0 (
    echo Ocurrio un error.
)


