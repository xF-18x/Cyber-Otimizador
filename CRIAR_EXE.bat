@echo off
title Criar CyberOtimizador.exe  -  by F-18
color 0B
echo ============================================================
echo   CONSTRUTOR:  CyberOtimizador.ps1  --^>  CyberOtimizador.exe
echo   Junta tudo (DLLs ja embutidas) num unico .exe com icone.
echo   Precisa de Internet na primeira vez (instala o PS2EXE).
echo ============================================================
echo.
echo   A trabalhar... aguarde (pode demorar um pouco).
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "try { if (-not (Get-Module -ListAvailable -Name ps2exe)) { Write-Host 'A instalar PS2EXE...'; try { Install-PackageProvider -Name NuGet -Force -Scope CurrentUser -EA SilentlyContinue | Out-Null } catch {}; Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -EA SilentlyContinue; Install-Module ps2exe -Scope CurrentUser -Force -AllowClobber }; Import-Module ps2exe; Invoke-ps2exe -InputFile '%~dp0CyberOtimizador.ps1' -OutputFile '%~dp0CyberOtimizador.exe' -iconFile '%~dp0OTIMIZADOR.ico' -noConsole -STA -requireAdmin -title 'Cyber Otimizador do Sistema' -product 'Cyber Otimizador' -company 'F-18' -description 'Cyber Otimizador do Sistema by F-18'; if (Test-Path '%~dp0CyberOtimizador.exe') { Write-Host ''; Write-Host 'FEITO! Criado CyberOtimizador.exe com o teu icone (ficheiro unico).' -ForegroundColor Green } else { Write-Host 'Nao foi criado o exe.' -ForegroundColor Red } } catch { Write-Host ('ERRO: ' + $_.Exception.Message) -ForegroundColor Red }"

echo.
pause
