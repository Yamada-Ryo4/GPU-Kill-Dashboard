@echo off
chcp 65001 >nul
pushd "%~dp0"

echo GPUKill 自動重啟（用 PowerShell 執行）...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0restart_gpukill.ps1"

echo.
echo PowerShell 腳本已退出。按任意鍵關閉此視窗...
pause

popd
