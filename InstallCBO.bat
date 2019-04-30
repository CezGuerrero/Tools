@echo off
rem Agregar al path de windows la siguiente ruta para poder bajar version.
rem c:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\
SET CBO=\prj\TFS_Platform_CBO\main\src\
SET WEB_CBO=\prj\TFS_Platform_CBO\main\src\web\
SET WEB_SEC=\prj\TFS_Platform_Infrastructure\Security\src\Kapsch-Web\Security\
SET MSBUILD="C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"

pushd "%~dp0"
echo [36m==============================================================================
echo CBO INSTALLATION
echo The installation will STOP ALL the Service before begin...
pause
echo.
echo [36m==============================================================================
echo [36mSTOPPING ALL SERVICES...[0m
Powershell.exe -Command "Get-Service | Where-Object {$_.displayName.StartsWith(\"Kapsch\")} | Stop-Service"

echo.
echo [36m==============================================================================
echo [36mGET LASTEST VERSION...[0m

tf get $/TFS_Platform_CBO/main/src /recursive

echo.
echo [36m==============================================================================
echo [36mBUILDING ON RELEASE:[33m %CBO%...[0m

cd %CBO%
call 00-build.cmd -y

echo.
echo [36m==============================================================================
echo [36mDEPLOYING DATABASE AT:[33m %CBO%...[0m

call %MSBUILD% /t:Publish /p:SqlPublishProfilePath="Kapsch.Database.CBO.publish.xml" cboDatabase\cbo\CBO.sqlproj

echo.
echo [36m==============================================================================
echo [36mYARNING:[33m %WEB_CBO%CRM...[0m

cd %WEB_CBO%\CRM
call yarn

echo.
echo [36mYARNING:[33m %WEB_CBO%Configuration...[0m

cd %WEB_CBO%\Configuration
call yarn

echo.
echo [36mYARNING:[33m %WEB_SEC%...[0m

cd %WEB_SEC%
call yarn

echo [36m==============================================================================
echo [36mLOADING SERVICES...[0m
echo.
Powershell.exe -Command "Get-Service | Where-Object {$_.displayName.StartsWith(\"Kapsch\")} | Start-Service"

echo.
echo [36m==============================================================================
echo [36mINSTALL FINISH !
echo [33m %date% %time%[0m

popd
powershell -c (New-Object Media.SoundPlayer "C:\Windows\Media\tada.wav").PlaySync();
pause
