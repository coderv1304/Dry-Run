@echo off
where pwsh 2>&1
echo ---
where cmd 2>&1  
echo ---
echo %PATH%
echo ---
dir "C:\Program Files\PowerShell\7\pwsh.exe" 2>&1
