@echo off
title Criar CyberOtimizador.exe  -  by F-18
color 0B
echo ============================================================
echo   CONSTRUTOR:  CyberOtimizador.bat  --^>  CyberOtimizador.exe
echo   Gera um unico .exe com icone (DLLs ja embutidas).
echo   Na primeira vez precisa de Internet (instala o PS2EXE).
echo ============================================================
echo.
echo   A trabalhar... aguarde (pode demorar um pouco).
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "try { $bat='%~dp0CyberOtimizador.bat'; $ico='%~dp0OTIMIZADOR.ico'; $tmp=Join-Path $env:TEMP 'cyber_build.ps1'; $c=Get-Content -Raw -LiteralPath $bat; $m=('#PSPAYLOAD'+'START'); $i=$c.IndexOf($m); if($i -lt 0){ throw 'marcador do payload nao encontrado' }; Set-Content -LiteralPath $tmp -Value $c.Substring($i + $m.Length) -Encoding UTF8; if (-not (Get-Module -ListAvailable -Name ps2exe)) { Write-Host 'A instalar PS2EXE...'; try { Install-PackageProvider -Name NuGet -Force -Scope CurrentUser -EA SilentlyContinue | Out-Null } catch {}; Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -EA SilentlyContinue; Install-Module ps2exe -Scope CurrentUser -Force -AllowClobber }; Import-Module ps2exe; Invoke-ps2exe -InputFile $tmp -OutputFile '%~dp0CyberOtimizador.exe' -iconFile $ico -noConsole -STA -requireAdmin -title 'Cyber Otimizador do Sistema' -product 'Cyber Otimizador' -company 'F-18' -description 'Cyber Otimizador do Sistema by F-18'; Remove-Item $tmp -Force -EA SilentlyContinue; if (Test-Path '%~dp0CyberOtimizador.exe') { Write-Host ''; Write-Host 'FEITO! Criado CyberOtimizador.exe com o teu icone (ficheiro unico).' -ForegroundColor Green } else { Write-Host 'Nao foi criado o exe.' -ForegroundColor Red } } catch { Write-Host ('ERRO: ' + $_.Exception.Message) -ForegroundColor Red }"

echo.
pause
