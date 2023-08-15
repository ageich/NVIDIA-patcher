@echo off
@setlocal EnableExtensions EnableDelayedExpansion

:CheckAdminRights
net session >nul 2>&1
if not %ErrorLevel% == 0 (
	echo Please run as administator^^!
	pause
	exit /b 1
)

@cd /d "%~dp0"

:SetVariables
set /p "Version=Enter driver version:"
if not defined Version set "Version=0.0"
set "DriverPath=%CD%\Display.Driver"
set "Nvenc32PatchUrl=https://raw.githubusercontent.com/keylase/nvidia-patch/master/win/win10_x64/%Version%/nvencodeapi.1337"
set "Nvenc64PatchUrl=https://raw.githubusercontent.com/keylase/nvidia-patch/master/win/win10_x64/%Version%/nvencodeapi64.1337"
set "Pattern=\xC2\x15\x07\x00\x07\x1B\x07\x00\x87\x1B\x07\x00\xC7\x1B\x07\x00\x07\x1C\x07\x00\x09\x1C\x07\x00\x83\x1D\x07\x00\x84\x1D\x07\x00\xC1\x1D\x07\x00\x09\x1E\x07\x00\x49\x1E\x07\x00\xBC\x1E\x07\x00\xFC\x1E\x07\x00\x0B\x1F\x07\x00\x81\x20\x07\x00\x82\x20\x07\x00\x83\x20\x07\x00\xC2\x20\x07\x00\x89\x21\x07\x00\x0D\x22\x07\x00\x4D\x22\x07\x00\x8A\x24\x07\x00\xCA\x24\x07\x00\x0A\x25\x07\x00"
set "Patch=\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00"
set "PatternSli=\x84\xC0\x75\x05\x0F\xBA\x6B"
set "PatchSli=\xC7\x43\x24\x00\x00\x00\x00"

:CheckDriverPresence
if not exist "%DriverPath%" (
	echo %DriverPath% not found^^! Unpack driver distributive and place unpacked files next to Patch.bat
	pause
	exit /b 1
)

:ImportCustomSigningCertificate
certutil -store -user My|find "07e871b66c69f35ae4a3c7d3ad5c44f3497807a1" >nul
if not %ErrorLevel% == 0 (
	certutil -f -user -p "440" -importpfx "Yongyu.pfx" NoRoot
		if not !ErrorLevel! == 0 (
			echo Failed to install Binzhoushi Yongyu Feed Co.,LTd. code signing certificate^^!
			pause
			exit /b 1
		)
)

:ImportNvidiaSigningCertificate
certutil -store -user My|find "579aec4489a2ca8a2a09df5dc0323634bd8b16b7" >nul
if not %ErrorLevel% == 0 (
	certutil -f -user -p "" -importpfx NVIDIA.pfx NoRoot
		if not !ErrorLevel! == 0 (
			echo Failed to install NVIDIA Corporation code signing certificate^^!
			pause
			goto Clean
			exit /b 1
		)
)

:RemoveDsigntoolConfig
if exist "%AppData%\TrustAsia\DSignTool" rd "%AppData%\TrustAsia\DSignTool" /s /q || echo Failed to delete old CSigntool/DSignTool config^^! Make sure you have write access to the %AppData%\TrustAsia\DSignTool directory. && pause && goto Clean && exit /b 1

:CreateDsigntoolConfig
md "%AppData%\TrustAsia\DSignTool"
echo ^<CONFIG FileExts="*.exe;*.dll;*.ocx;*.sys;*.cat;*.cab;*.msi;*.mui;*.bin;" UUID="{04E99765-8F33-4A9F-9393-35F83CC50E74}"^>^<RULES^>^<RULE Name="Binzhoushi Yongyu Feed Co.,LTd." Cert="07e871b66c69f35ae4a3c7d3ad5c44f3497807a1" Sha2Cert="" Desc="" InfoUrl="" Timestamp="" FileExts="*.exe;*.dll;*.ocx;*.sys;*.cat;*.cab;*.msi;*.mui;*.bin;" EnumSubDir="0" SkipSigned="0" Time="2012-01-31 12:00:25"/^>^<RULE Name="NVIDIA Corporation" Cert="579aec4489a2ca8a2a09df5dc0323634bd8b16b7" Sha2Cert="" Desc="" InfoUrl="" Timestamp="" FileExts="*.exe;*.dll;*.ocx;*.sys;*.cat;*.cab;*.msi;*.mui;*.bin;" EnumSubDir="0" SkipSigned="0" Time="2012-01-31 12:00:25"/^>^</RULES^>^</CONFIG^>>>"%AppData%\TrustAsia\DSignTool\Config.xml"

:UnpackDriverFiles
7za.exe e "%DriverPath%\*.bi_" -o"%DriverPath%"
7za.exe e "%DriverPath%\*.dl_" -o"%DriverPath%"
7za.exe e "%DriverPath%\*.ex_" -o"%DriverPath%"
7za.exe e "%DriverPath%\*.ic_" -o"%DriverPath%"
7za.exe e "%DriverPath%\*.sy_" -o"%DriverPath%"

:Patch3dAcceleration
if exist "%DriverPath%\nvd3dum.dll" call JREPL.bat "%Pattern%" "%Patch%" /m /x /f "%DriverPath%\nvd3dum.dll" /o -
if exist "%DriverPath%\nvd3dum_cfg.dll" call JREPL.bat "%Pattern%" "%Patch%" /m /x /f "%DriverPath%\nvd3dum_cfg.dll" /o -
if exist "%DriverPath%\nvd3dumx.dll" call JREPL.bat "%Pattern%" "%Patch%" /m /x /f "%DriverPath%\nvd3dumx.dll" /o -
if exist "%DriverPath%\nvd3dumx_cfg.dll" call JREPL.bat "%Pattern%" "%Patch%" /m /x /f "%DriverPath%\nvd3dumx_cfg.dll" /o -
if exist "%DriverPath%\nvoglv32.dll" call JREPL.bat "%Pattern%" "%Patch%" /m /x /f "%DriverPath%\nvoglv32.dll" /o -
if exist "%DriverPath%\nvoglv64.dll" call JREPL.bat "%Pattern%" "%Patch%" /m /x /f "%DriverPath%\nvoglv64.dll" /o -
if exist "%DriverPath%\nvwgf2um.dll" call JREPL.bat "%Pattern%" "%Patch%" /m /x /f "%DriverPath%\nvwgf2um.dll" /o -
if exist "%DriverPath%\nvwgf2um_cfg.dll" call JREPL.bat "%Pattern%" "%Patch%" /m /x /f "%DriverPath%\nvwgf2um_cfg.dll" /o -
if exist "%DriverPath%\nvwgf2umx.dll" call JREPL.bat "%Pattern%" "%Patch%" /m /x /f "%DriverPath%\nvwgf2umx.dll" /o -
if exist "%DriverPath%\nvwgf2umx_cfg.dll" call JREPL.bat "%Pattern%" "%Patch%" /m /x /f "%DriverPath%\nvwgf2umx_cfg.dll" /o -
if exist "%DriverPath%\nvlddmkm.sys" call JREPL.bat "%Pattern%" "%Patch%" /m /x /f "%DriverPath%\nvlddmkm.sys" /o -

:PatchSliSupport
if %Version% == 446.14 call JREPL.bat "%PatternSli%" "%PatchSli%" /m /x /f "%DriverPath%\nvlddmkm.sys" /o -

:Sign3dBinaries
if exist "%DriverPath%\nvd3dum.dll" CSigntool.exe sign /r "NVIDIA Corporation" /f "%DriverPath%\nvd3dum.dll" -ts 2013-01-01T00:00:00
if exist "%DriverPath%\nvd3dum_cfg.dll" CSigntool.exe sign /r "NVIDIA Corporation" /f "%DriverPath%\nvd3dum_cfg.dll" -ts 2013-01-01T00:00:00
if exist "%DriverPath%\nvd3dumx.dll" CSigntool.exe sign /r "NVIDIA Corporation" /f "%DriverPath%\nvd3dumx.dll" -ts 2013-01-01T00:00:00
if exist "%DriverPath%\nvd3dumx_cfg.dll" CSigntool.exe sign /r "NVIDIA Corporation" /f "%DriverPath%\nvd3dumx_cfg.dll" -ts 2013-01-01T00:00:00
if exist "%DriverPath%\nvoglv32.dll" CSigntool.exe sign /r "NVIDIA Corporation" /f "%DriverPath%\nvoglv32.dll" -ts 2013-01-01T00:00:00
if exist "%DriverPath%\nvoglv64.dll" CSigntool.exe sign /r "NVIDIA Corporation" /f "%DriverPath%\nvoglv64.dll" -ts 2013-01-01T00:00:00
if exist "%DriverPath%\nvwgf2um.dll" CSigntool.exe sign /r "NVIDIA Corporation" /f "%DriverPath%\nvwgf2um.dll" -ts 2013-01-01T00:00:00
if exist "%DriverPath%\nvwgf2um_cfg.dll" CSigntool.exe sign /r "NVIDIA Corporation" /f "%DriverPath%\nvwgf2um_cfg.dll" -ts 2013-01-01T00:00:00
if exist "%DriverPath%\nvwgf2umx.dll" CSigntool.exe sign /r "NVIDIA Corporation" /f "%DriverPath%\nvwgf2umx.dll" -ts 2013-01-01T00:00:00
if exist "%DriverPath%\nvwgf2umx_cfg.dll" CSigntool.exe sign /r "NVIDIA Corporation" /f "%DriverPath%\nvwgf2umx_cfg.dll" -ts 2013-01-01T00:00:00
if exist "%DriverPath%\nvlddmkm.sys" CSigntool.exe sign /r "NVIDIA Corporation" /f "%DriverPath%\nvlddmkm.sys" -ts 2013-01-01T00:00:00

:Timestamp3dBinaries
if exist "%DriverPath%\nvd3dum.dll" signtool.exe timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DriverPath%\nvd3dum.dll"
if exist "%DriverPath%\nvd3dum_cfg.dll" signtool.exe timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DriverPath%\nvd3dum_cfg.dll"
if exist "%DriverPath%\nvd3dumx.dll" signtool.exe timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DriverPath%\nvd3dumx.dll"
if exist "%DriverPath%\nvd3dumx_cfg.dll" signtool.exe timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DriverPath%\nvd3dumx_cfg.dll"
if exist "%DriverPath%\nvoglv32.dll" signtool.exe timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DriverPath%\nvoglv32.dll"
if exist "%DriverPath%\nvoglv64.dll" signtool.exe timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DriverPath%\nvoglv64.dll"
if exist "%DriverPath%\nvwgf2um.dll" signtool.exe timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DriverPath%\nvwgf2um.dll"
if exist "%DriverPath%\nvwgf2um_cfg.dll" signtool.exe timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DriverPath%\nvwgf2um_cfg.dll"
if exist "%DriverPath%\nvwgf2umx.dll" signtool.exe timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DriverPath%\nvwgf2umx.dll"
if exist "%DriverPath%\nvwgf2umx_cfg.dll" signtool.exe timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DriverPath%\nvwgf2umx_cfg.dll"
if exist "%DriverPath%\nvlddmkm.sys" signtool.exe timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DriverPath%\nvlddmkm.sys"

:Pack3dBinaries
if exist "%DriverPath%\nvd3dum.dll" makecab "%DriverPath%\nvd3dum.dll" /l "%DriverPath%"
if exist "%DriverPath%\nvd3dum_cfg.dll" makecab "%DriverPath%\nvd3dum_cfg.dll" /l "%DriverPath%"
if exist "%DriverPath%\nvd3dumx.dll" makecab "%DriverPath%\nvd3dumx.dll" /l "%DriverPath%"
if exist "%DriverPath%\nvd3dumx_cfg.dll" makecab "%DriverPath%\nvd3dumx_cfg.dll" /l "%DriverPath%"
if exist "%DriverPath%\nvoglv32.dll" makecab "%DriverPath%\nvoglv32.dll" /l "%DriverPath%"
if exist "%DriverPath%\nvoglv64.dll" makecab "%DriverPath%\nvoglv64.dll" /l "%DriverPath%"
if exist "%DriverPath%\nvwgf2um.dll" makecab "%DriverPath%\nvwgf2um.dll" /l "%DriverPath%"
if exist "%DriverPath%\nvwgf2um_cfg.dll" makecab "%DriverPath%\nvwgf2um.dll" /l "%DriverPath%"
if exist "%DriverPath%\nvwgf2umx.dll" makecab "%DriverPath%\nvwgf2umx.dll" /l "%DriverPath%"
if exist "%DriverPath%\nvwgf2umx_cfg.dll" makecab "%DriverPath%\nvwgf2umx_cfg.dll" /l "%DriverPath%"
if exist "%DriverPath%\nvlddmkm.sys" makecab "%DriverPath%\nvlddmkm.sys" /l "%DriverPath%"

:CheckNvencPatchPresence
for /f %%a in ( 'curl -o nul -s -Iw "%%{http_code}" "%Nvenc64PatchUrl%"' ) do set http=%%a
if not %http% == 200 goto GenerateCatalogFile

:AskUserAboutNvenc
echo.
choice /m "Do you want to apply NVENC patch? This may enable NVENC support on some cards"
if %ErrorLevel% == 1 goto DownloadNvencPatches
if %ErrorLevel% == 2 goto GenerateCatalogFile

:DownloadNvencPatches
curl -s -O %Nvenc32PatchUrl%
curl -s -O %Nvenc64PatchUrl%

:PromptUserAboutNvenc
echo Apply NVENC patch manually now
pause

:SignNvencBinaries
if exist "%DriverPath%\nvencodeapi.dll" CSigntool.exe sign /r "NVIDIA Corporation" /f "%DriverPath%\nvencodeapi.dll" -ts 2013-01-01T00:00:00
if exist "%DriverPath%\nvencodeapi64.dll" CSigntool.exe sign /r "NVIDIA Corporation" /f "%DriverPath%\nvencodeapi64.dll" -ts 2013-01-01T00:00:00

:TimestampNvencBinaries
if exist "%DriverPath%\nvencodeapi.dll" signtool.exe timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DriverPath%\nvencodeapi.dll"
if exist "%DriverPath%\nvencodeapi64.dll" signtool.exe timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2013-01-01T00:00:00" "%DriverPath%\nvencodeapi64.dll"

:PackNvencBinaries
if exist "%DriverPath%\nvencodeapi.dll" makecab "%DriverPath%\nvencodeapi.dll" /l "%DriverPath%"
if exist "%DriverPath%\nvencodeapi64.dll" makecab "%DriverPath%\nvencodeapi64.dll" /l "%DriverPath%"

:GenerateCatalogFile
del "%DriverPath%\nv_disp.cat"
Inf2Cat.exe /driver:"%DriverPath%" /os:10_x64

:CheckCatalogFile
if not exist "%DriverPath%\nv_disp.cat" (
	echo Failed to generate catalog file^^!
	pause
	goto Clean
)

:SignCatalogFile
CSigntool.exe sign /r "Binzhoushi Yongyu Feed Co.,LTd." /f "%DriverPath%\nv_disp.cat" /ac -ts 2015-01-01T00:00:00
if not %ErrorLevel% == 0 (
	echo Failed to sign catalog file^^!
	pause
	goto Clean
)

:TimestampCatalogFile
signtool.exe timestamp /t "http://tsa.pki.jemmylovejenny.tk/SHA1/2015-01-01T00:00:00" "%DriverPath%\nv_disp.cat"
if not %ErrorLevel% == 0 (
	echo Failed to timestamp catalog file^^!
	pause
	goto Clean
)

:InstallTimestampCertificate
certutil -store Root|find "e403a1dfc8f377e0f4aa43a83ee9ea079a1f55f2" >nul
if not %ErrorLevel% == 0 (
	certutil -f -addstore Root EVRootCA.crt
		if not !ErrorLevel! == 0 echo Failed to install root certificate^^! Download it from pki.jemmylovejenny.tk and install manually into Trusted Root Certification Authorities.
)

:Clean
rd "%ProgramData%\JREPL" /s /q
rd "%LocalAppData%\DeFconX" /s /q
rd "%AppData%\TrustAsia" /s /q
rd "%Temp%\WST" /s /q
del *.1337
certutil -store -user My|find "07e871b66c69f35ae4a3c7d3ad5c44f3497807a1" >nul
if %ErrorLevel% == 0 certutil -delstore -user My "07e871b66c69f35ae4a3c7d3ad5c44f3497807a1"
certutil -store -user My|find "579aec4489a2ca8a2a09df5dc0323634bd8b16b7" >nul
if %ErrorLevel% == 0 certutil -delstore -user My "579aec4489a2ca8a2a09df5dc0323634bd8b16b7"
goto :eof

exit /b 0