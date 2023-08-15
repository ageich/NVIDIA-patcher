@echo off

net session >nul 2>&1
IF %ERRORLEVEL% neq 0 (
	echo Please run as administator!
	pause
	exit
)

@setlocal enableextensions enabledelayedexpansion
@cd /d "%~DP0"

set /P VERSION=Enter driver version:
if not defined VERSION set VERSION=0.0
set DRIVER=%CD%\Display.Driver
set BIN_PATTERN=\xC2\x15\x07\x00\x07\x1B\x07\x00\x87\x1B\x07\x00\xC7\x1B\x07\x00\x07\x1C\x07\x00\x09\x1C\x07\x00\x83\x1D\x07\x00\x84\x1D\x07\x00\xC1\x1D\x07\x00\x09\x1E\x07\x00\x49\x1E\x07\x00\xBC\x1E\x07\x00\xFC\x1E\x07\x00\x0B\x1F\x07\x00\x81\x20\x07\x00\x82\x20\x07\x00\x83\x20\x07\x00\xC2\x20\x07\x00\x89\x21\x07\x00\x0D\x22\x07\x00\x4D\x22\x07\x00\x8A\x24\x07\x00\xCA\x24\x07\x00\x0A\x25\x07\x00
set BIN_PATCH=\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00
set BIN_PATTERN_SLI=\x84\xC0\x75\x05\x0F\xBA\x6B
set BIN_PATCH_SLI=\xC7\x43\x24\x00\x00\x00\x00
set NVENC32_PATCH_URL=https://raw.githubusercontent.com/keylase/nvidia-patch/master/win/win10_x64/%VERSION%/nvencodeapi.1337
set NVENC64_PATCH_URL=https://raw.githubusercontent.com/keylase/nvidia-patch/master/win/win10_x64/%VERSION%/nvencodeapi64.1337

if not exist "%DRIVER%" (
	echo %DRIVER% not found^^! Unpack driver distributive and place unpacked files next to Patch.bat
	pause
	exit
)

if exist "%APPDATA%\TrustAsia\DSignTool" (
	rd "%APPDATA%\TrustAsia\DSignTool" /s /q || echo Failed to delete old CSignTool/DSignTool config^^! Make sure you have write access to the %APPDATA%\TrustAsia\DSignTool directory. && pause && exit
)

certutil -store -user My|find "07e871b66c69f35ae4a3c7d3ad5c44f3497807a1" >nul
if not !ERRORLEVEL!==0 (
	certutil -f -user -p "440" -importpfx Yongyu.pfx NoRoot
		if not !ERRORLEVEL!==0 (
			echo Failed to install Binzhoushi Yongyu Feed Co.,LTd. code signing certificate^^!
			pause
			exit
		)
)

certutil -store -user My|find "579aec4489a2ca8a2a09df5dc0323634bd8b16b7" >nul
if not !ERRORLEVEL!==0 (
	certutil -f -user -p "" -importpfx NVIDIA.pfx NoRoot
		if not !ERRORLEVEL!==0 (
			echo Failed to install NVIDIA Corporation code signing certificate^^!
			pause
			exit
		)
)

md "%APPDATA%\TrustAsia\DSignTool"

echo ^<CONFIG FileExts="*.exe;*.dll;*.ocx;*.sys;*.cat;*.cab;*.msi;*.mui;*.bin;" UUID="{04E99765-8F33-4A9F-9393-35F83CC50E74}"^>^<RULES^>^<RULE Name="Binzhoushi Yongyu Feed Co.,LTd." Cert="07e871b66c69f35ae4a3c7d3ad5c44f3497807a1" Sha2Cert="" Desc="" InfoUrl="" Timestamp="" FileExts="*.exe;*.dll;*.ocx;*.sys;*.cat;*.cab;*.msi;*.mui;*.bin;" EnumSubDir="0" SkipSigned="0" Time="2012-01-31 12:00:25"/^>^<RULE Name="NVIDIA Corporation" Cert="579aec4489a2ca8a2a09df5dc0323634bd8b16b7" Sha2Cert="" Desc="" InfoUrl="" Timestamp="" FileExts="*.exe;*.dll;*.ocx;*.sys;*.cat;*.cab;*.msi;*.mui;*.bin;" EnumSubDir="0" SkipSigned="0" Time="2012-01-31 12:00:25"/^>^</RULES^>^</CONFIG^>>>"%APPDATA%\TrustAsia\DSignTool\Config.xml"

7za e "%DRIVER%\*.bi_" -o"%DRIVER%"
7za e "%DRIVER%\*.dl_" -o"%DRIVER%"
7za e "%DRIVER%\*.ex_" -o"%DRIVER%"
7za e "%DRIVER%\*.ic_" -o"%DRIVER%"
7za e "%DRIVER%\*.sy_" -o"%DRIVER%"

if exist "%DRIVER%\nvd3dum.dll" call jrepl.bat "%BIN_PATTERN%" "%BIN_PATCH%" /m /x /f "%DRIVER%\nvd3dum.dll" /o -
if exist "%DRIVER%\nvd3dum_cfg.dll" call jrepl.bat "%BIN_PATTERN%" "%BIN_PATCH%" /m /x /f "%DRIVER%\nvd3dum_cfg.dll" /o -
if exist "%DRIVER%\nvd3dumx.dll" call jrepl.bat "%BIN_PATTERN%" "%BIN_PATCH%" /m /x /f "%DRIVER%\nvd3dumx.dll" /o -
if exist "%DRIVER%\nvd3dumx_cfg.dll" call jrepl.bat "%BIN_PATTERN%" "%BIN_PATCH%" /m /x /f "%DRIVER%\nvd3dumx_cfg.dll" /o -
if exist "%DRIVER%\nvoglv32.dll" call jrepl.bat "%BIN_PATTERN%" "%BIN_PATCH%" /m /x /f "%DRIVER%\nvoglv32.dll" /o -
if exist "%DRIVER%\nvoglv64.dll" call jrepl.bat "%BIN_PATTERN%" "%BIN_PATCH%" /m /x /f "%DRIVER%\nvoglv64.dll" /o -
if exist "%DRIVER%\nvwgf2um.dll" call jrepl.bat "%BIN_PATTERN%" "%BIN_PATCH%" /m /x /f "%DRIVER%\nvwgf2um.dll" /o -
if exist "%DRIVER%\nvwgf2um_cfg.dll" call jrepl.bat "%BIN_PATTERN%" "%BIN_PATCH%" /m /x /f "%DRIVER%\nvwgf2um_cfg.dll" /o -
if exist "%DRIVER%\nvwgf2umx.dll" call jrepl.bat "%BIN_PATTERN%" "%BIN_PATCH%" /m /x /f "%DRIVER%\nvwgf2umx.dll" /o -
if exist "%DRIVER%\nvwgf2umx_cfg.dll" call jrepl.bat "%BIN_PATTERN%" "%BIN_PATCH%" /m /x /f "%DRIVER%\nvwgf2umx_cfg.dll" /o -
if exist "%DRIVER%\nvlddmkm.sys" call jrepl.bat "%BIN_PATTERN%" "%BIN_PATCH%" /m /x /f "%DRIVER%\nvlddmkm.sys" /o -

findstr /m "446.14" "%DRIVER%\DisplayDriver.nvi"
if %ERRORLEVEL%==0 (
	if exist "%DRIVER%\nvlddmkm.sys" call jrepl.bat "%BIN_PATTERN_SLI%" "%BIN_PATCH_SLI%" /m /x /f "%DRIVER%\nvlddmkm.sys" /o -
)

if exist "%DRIVER%\nvd3dum.dll" CSignTool sign /r "NVIDIA Corporation" /f "%DRIVER%\nvd3dum.dll" -ts 2013-01-01T00:00:00
if exist "%DRIVER%\nvd3dum_cfg.dll" CSignTool sign /r "NVIDIA Corporation" /f "%DRIVER%\nvd3dum_cfg.dll" -ts 2013-01-01T00:00:00
if exist "%DRIVER%\nvd3dumx.dll" CSignTool sign /r "NVIDIA Corporation" /f "%DRIVER%\nvd3dumx.dll" -ts 2013-01-01T00:00:00
if exist "%DRIVER%\nvd3dumx_cfg.dll" CSignTool sign /r "NVIDIA Corporation" /f "%DRIVER%\nvd3dumx_cfg.dll" -ts 2013-01-01T00:00:00
if exist "%DRIVER%\nvoglv32.dll" CSignTool sign /r "NVIDIA Corporation" /f "%DRIVER%\nvoglv32.dll" -ts 2013-01-01T00:00:00
if exist "%DRIVER%\nvoglv64.dll" CSignTool sign /r "NVIDIA Corporation" /f "%DRIVER%\nvoglv64.dll" -ts 2013-01-01T00:00:00
if exist "%DRIVER%\nvwgf2um.dll" CSignTool sign /r "NVIDIA Corporation" /f "%DRIVER%\nvwgf2um.dll" -ts 2013-01-01T00:00:00
if exist "%DRIVER%\nvwgf2um_cfg.dll" CSignTool sign /r "NVIDIA Corporation" /f "%DRIVER%\nvwgf2um_cfg.dll" -ts 2013-01-01T00:00:00
if exist "%DRIVER%\nvwgf2umx.dll" CSignTool sign /r "NVIDIA Corporation" /f "%DRIVER%\nvwgf2umx.dll" -ts 2013-01-01T00:00:00
if exist "%DRIVER%\nvwgf2umx_cfg.dll" CSignTool sign /r "NVIDIA Corporation" /f "%DRIVER%\nvwgf2umx_cfg.dll" -ts 2013-01-01T00:00:00

if exist "%DRIVER%\nvd3dum.dll" signtool timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DRIVER%\nvd3dum.dll"
if exist "%DRIVER%\nvd3dum_cfg.dll" signtool timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DRIVER%\nvd3dum_cfg.dll"
if exist "%DRIVER%\nvd3dumx.dll" signtool timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DRIVER%\nvd3dumx.dll"
if exist "%DRIVER%\nvd3dumx_cfg.dll" signtool timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DRIVER%\nvd3dumx_cfg.dll"
if exist "%DRIVER%\nvoglv32.dll" signtool timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DRIVER%\nvoglv32.dll"
if exist "%DRIVER%\nvoglv64.dll" signtool timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DRIVER%\nvoglv64.dll"
if exist "%DRIVER%\nvwgf2um.dll" signtool timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DRIVER%\nvwgf2um.dll"
if exist "%DRIVER%\nvwgf2um_cfg.dll" signtool timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DRIVER%\nvwgf2um_cfg.dll"
if exist "%DRIVER%\nvwgf2umx.dll" signtool timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DRIVER%\nvwgf2umx.dll"
if exist "%DRIVER%\nvwgf2umx_cfg.dll" signtool timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DRIVER%\nvwgf2umx_cfg.dll"

if exist "%DRIVER%\nvd3dum.dll" makecab "%DRIVER%\nvd3dum.dll" /L "%DRIVER%"
if exist "%DRIVER%\nvd3dum_cfg.dll" makecab "%DRIVER%\nvd3dum_cfg.dll" /L "%DRIVER%"
if exist "%DRIVER%\nvd3dumx.dll" makecab "%DRIVER%\nvd3dumx.dll" /L "%DRIVER%"
if exist "%DRIVER%\nvd3dumx_cfg.dll" makecab "%DRIVER%\nvd3dumx_cfg.dll" /L "%DRIVER%"
if exist "%DRIVER%\nvoglv32.dll" makecab "%DRIVER%\nvoglv32.dll" /L "%DRIVER%"
if exist "%DRIVER%\nvoglv64.dll" makecab "%DRIVER%\nvoglv64.dll" /L "%DRIVER%"
if exist "%DRIVER%\nvwgf2um.dll" makecab "%DRIVER%\nvwgf2um.dll" /L "%DRIVER%"
if exist "%DRIVER%\nvwgf2um_cfg.dll" makecab "%DRIVER%\nvwgf2um.dll" /L "%DRIVER%"
if exist "%DRIVER%\nvwgf2umx.dll" makecab "%DRIVER%\nvwgf2umx.dll" /L "%DRIVER%"
if exist "%DRIVER%\nvwgf2umx_cfg.dll" makecab "%DRIVER%\nvwgf2umx_cfg.dll" /L "%DRIVER%"
if exist "%DRIVER%\nvlddmkm.sys" makecab "%DRIVER%\nvlddmkm.sys" /L "%DRIVER%"

set HTTP=
for /f %%a in ( 'curl -o NUL -s -Iw "%%{http_code}" "%NVENC64_PATCH_URL%"' ) do set HTTP=%%a
if "%HTTP%" neq "200" (
	goto :NONVENC
)

cls
CHOICE /M "Do you want to apply NVENC patch? This may enable NVENC support on some cards."
IF %ERRORLEVEL% equ 1 GOTO NVENC
IF %ERRORLEVEL% equ 2 GOTO NONVENC

:NVENC
curl -s -O %NVENC32_PATCH_URL%
curl -s -O %NVENC64_PATCH_URL%

echo Apply NVENC patch manually now
pause

if exist "%DRIVER%\nvencodeapi.dll" CSignTool sign /r "NVIDIA Corporation" /f "%DRIVER%\nvencodeapi.dll" -ts 2013-01-01T00:00:00
if exist "%DRIVER%\nvencodeapi64.dll" CSignTool sign /r "NVIDIA Corporation" /f "%DRIVER%\nvencodeapi64.dll" -ts 2013-01-01T00:00:00

if exist "%DRIVER%\nvencodeapi.dll" signtool timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DRIVER%\nvencodeapi.dll"
if exist "%DRIVER%\nvencodeapi64.dll" signtool timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DRIVER%\nvencodeapi64.dll"

if exist "%DRIVER%\nvencodeapi.dll" makecab "%DRIVER%\nvencodeapi.dll" /L "%DRIVER%"
if exist "%DRIVER%\nvencodeapi64.dll" makecab "%DRIVER%\nvencodeapi64.dll" /L "%DRIVER%"

:NONVENC
del "%DRIVER%\nv_disp.cat"

inf2cat /driver:"%DRIVER%" /os:10_X64

if not exist "%DRIVER%\nv_disp.cat" (
	echo Failed to generate catalog file^^!
	goto CLEAN
)

CSignTool sign /r "Binzhoushi Yongyu Feed Co.,LTd." /f "%DRIVER%\nv_disp.cat" /ac -ts 2015-01-01T00:00:00
if not %ERRORLEVEL%==0 (
	echo Failed to sign catalog file^^!
	pause
	goto CLEAN
)

signtool timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2015-01-01T00:00:00" "%DRIVER%\nv_disp.cat"
if not %ERRORLEVEL%==0 (
	echo Failed to timestamp catalog file^^!
	pause
	goto CLEAN
)

certutil -store Root|find "e403a1dfc8f377e0f4aa43a83ee9ea079a1f55f2" >nul
if not !ERRORLEVEL!==0 (
	certutil -f -addstore Root EVRootCA.crt
		if not !ERRORLEVEL!==0 (
			echo Failed to install root certificate^^! Download it from pki.jemmylovejenny.tk and install manually into Trusted Root Certification Authorities.
		)
)

:CLEAN
rd "%PROGRAMDATA%\JREPL" /s /q
rd "%LOCALAPPDATA%\DeFconX" /s /q
rd "%APPDATA%\TrustAsia" /s /q
rd "%TEMP%\WST" /s /q
del *.1337

certutil -store -user My|find "07e871b66c69f35ae4a3c7d3ad5c44f3497807a1" >nul
if !ERRORLEVEL!==0 (
	certutil -delstore -user My "07e871b66c69f35ae4a3c7d3ad5c44f3497807a1"
		if not !ERRORLEVEL!==0 (
			echo Failed to uninstall Binzhoushi Yongyu Feed Co.,LTd. code signing certificate^^!
			pause
			exit
		)
)

certutil -store -user My|find "579aec4489a2ca8a2a09df5dc0323634bd8b16b7" >nul
if !ERRORLEVEL!==0 (
	certutil -delstore -user My "579aec4489a2ca8a2a09df5dc0323634bd8b16b7"
		if not !ERRORLEVEL!==0 (
			echo Failed to uninstall NVIDIA Corporation code signing certificate^^!
			pause
			exit
		)
)

exit