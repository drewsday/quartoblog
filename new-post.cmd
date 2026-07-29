@echo off
REM Wrapper so the scaffolder can be run from cmd.exe, where .ps1 files open in
REM an editor rather than executing. Passes every argument through unchanged:
REM
REM   new-post "How I Fixed My Blog Pipeline"
REM   new-post "Plotting Weather Data" -Format ipynb
REM
REM From a PowerShell prompt you can call .\new-post.ps1 directly instead.
powershell.exe -NoProfile -File "%~dp0new-post.ps1" %*
