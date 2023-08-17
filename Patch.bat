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
set /p "Version=Enter driver version (e.g. 330.67):"
if not defined Version set "Version=0.0"
set "DriverPath=%CD%\Display.Driver"
set "Nvenc32PatchUrl=https://raw.githubusercontent.com/keylase/nvidia-patch/master/win/win10_x64/%Version%/nvencodeapi.1337"
set "Nvenc64PatchUrl=https://raw.githubusercontent.com/keylase/nvidia-patch/master/win/win10_x64/%Version%/nvencodeapi64.1337"
set "NewPatternP=\x07\x1B\x07\x00\x87\x1B\x07\x00\xC7\x1B\x07\x00\x07\x1C\x07\x00\x09\x1C\x07"
set "NewPatchP=\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07"
set "OldPatternP=\x07\x1B\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\x87\x1B\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\xC7\x1B\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\x07\x1C\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\x09\x1C"
set "OldPatchP=\xFF\xFF\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\xFF\xFF\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\xFF\xFF\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\xFF\xFF\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\xFF\xFF"
set "PatternCmp=\x09\x1E\x07\x00\x49\x1E\x07\x00\xBC\x1E\x07\x00\xFC\x1E\x07\x00\x0B\x1F\x07\x00\x81\x20\x07\x00\x82\x20\x07\x00\x83\x20\x07\x00\xC2\x20\x07\x00\x89\x21\x07\x00\x0D\x22\x07\x00\x4D\x22\x07\x00\x8A\x24\x07"
set "PatchCmp=\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07\x00\xFF\xFF\x07"
set "PatternSli=\x84\xC0\x75\x05\x0F\xBA\x6B"
set "PatchSli=\xC7\x43\x24\x00\x00\x00\x00"

:CheckDriverPresence
if not exist "%DriverPath%" (
	echo %DriverPath% not found^^! Unpack driver distributive and place unpacked files next to Patch.bat
	pause
	exit /b 1
)

:InstallTimestampCertificate
reg add HKLM\SOFTWARE\Microsoft\SystemCertificates\ROOT\Certificates\E403A1DFC8F377E0F4AA43A83EE9EA079A1F55F2 /v Blob /t REG_BINARY /d 09000000010000004c000000304a060a2b0601040182370a0602060a2b0601040182370a060106082b0601050507030806082b0601050507030406082b0601050507030306082b0601050507030206082b060105050703015c000000010000000400000000100000030000000100000014000000e403a1dfc8f377e0f4aa43a83ee9ea079a1f55f219000000010000001000000079d8e39856b0540913defb485e73ed621400000001000000140000000525862f6536a1e59d9eca5c0919ad0e3d96261d0f000000010000001400000052bf462203121ab271f48ff1a32d373fd9f12399040000000100000010000000dc911e8da3a186bb4d52eec0e57b51555300000001000000230000003021301f060960864801a4a227020130123010060a2b0601040182373c0101030200c02000000001000000d3050000308205cf308203b7a00302010202041eb132d5300d06092a864886f70d01010505003076310b300906035504061302434e31233021060355040a0c1a4a656d6d794c6f76654a656e6e7920504b492053657276696365311e301c060355040b0c15706b692e6a656d6d796c6f76656a656e6e792e746b3122302006035504030c194a656d6d794c6f76654a656e6e7920455620526f6f742043413020170d3030303130313030303030305a180f32303939313233313233353935395a3076310b300906035504061302434e31233021060355040a0c1a4a656d6d794c6f76654a656e6e7920504b492053657276696365311e301c060355040b0c15706b692e6a656d6d796c6f76656a656e6e792e746b3122302006035504030c194a656d6d794c6f76654a656e6e7920455620526f6f7420434130820222300d06092a864886f70d01010105000382020f003082020a0282020100b5bf164ce267332d80ffed87e949041ea0b8dd6e4389cc2ece1e2606c7dc4085d75631f5bf99e3b60a4dbe48dc7337e8edc95dd02aca568a119c2884dd8cecd0c174585e1b6ec89e47f37f28626bb42abb0f7cb0ee0f25d11e268026937bfc4587de5d7cd89d9cd3fee634120724a3771d3dec3ba265398f84274bc72d683be7982706d99e24f4ffe84370fb7b0c8d56449c1bdb2d53ca85a55ea12b4cb65aa691fbbceb57c3cb924ded732c252a968069030dbd3a2bf0c8fa027b7ab6afc325b439d4edc7bad1d3e57dfa244705d36bae516daa94378ea3a87e54aad21deb547b1bc659ca611b05da6f473f6dedfc7616bb9a86838cb2b1be86ff2169d4bcc9078527fa4e579acfc1d649339751c2e6521432cf6b5f26666f2c732ec567a2f5c89f62a34b4a73352238b02d981eaf905c6a66ebe570b20d6ae57d978420f34ab679268d8910217031fa6c69831f485eab30c445789242977e2c9d2df3f0f1aa4ec0cae5612418ffdf0127b7d5809e7a1803121d5b0ff82537ab112a49d7946a51ec8c4691332d5ffa415471f2d95e104400776c21250ae00d587b233b22a596db169e0583c0027c59814544963e66a5eb293ea11523e338d924244bd36b6d27227eecf848c3aef39b756123595c646d36d6cdf570b72fe9fbef779e0afa1db7cf4cc81964b366441f8032337a328f3c988997d0a27d2d8dce891c221a514ab30203010001a3633061300e0603551d0f0101ff040403020186300f0603551d130101ff040530030101ff301d0603551d0e041604140525862f6536a1e59d9eca5c0919ad0e3d96261d301f0603551d230418301680140525862f6536a1e59d9eca5c0919ad0e3d96261d300d06092a864886f70d01010505000382020100ad21caaf24b3bfa5ae380783453b61419a4625b1adf976ca6ee77f802063842fd2ca4879ddf39df1a0ca779bb313fb86d1241607b6df5e868ad9cddb69e19baf3107c22cf951569dc8d5f89db4b4ab7b859b61482b10df9bfcce81c4f1b86c77d40a5ee2805a460dd0d6ea165f86e67085097d159090416b07de58ece97764bd1ab9d3c197d1e52aa132182f68fe1962f194b22e1a5a9d4d25c46c9e97a8a6fde4ec57296b4a509eb6dcc8be7b25ff104ef9892d413c93662351b7f3bab4725aaadd18adf65efba74224dbd1dd718356d68e205046d648ac74e11d3be7494d0dba37c51a467af57c721a25968ab1e6a48416009cfb2ac1c063245d93ec2459ac262778e907e4b9aa5bf666db808344c83857d632ae46fe2daba83d1497a155bb9da767ca7fe567b218dffda7aa61055501b2f515cd0fd8b830a67c82b765f52cf80f077ea177480395a29c8dbe9cd572715257a7cef58ad63218e05d16f0096bd496e12d17bf7790b9ddb6318fb91a2a3f3395dd55e4ba739c2c8d15442fbc8de41bade132d1a23fb5a2844e6b08062208f9191e1f3ca0a5504e07cf4b3f2baa683bdc0dc10a8a6631b3d46481641798a4a37b35ada800104d8bc70c0fc31f6615284cb1229592ee072139b6a15a8ad9e1a8135bb4fe7b426d5e69ca1a9a420d7ce3612490d4d9421835a89a05f14e3ca3fd987c51cd62f2926945cfbff32caa /f >nul

:UnpackDriverFiles
if %Version% lss 535 (
	title Unpacking driver...
	7z.exe e "%DriverPath%\*.bi_" -o"%DriverPath%"
	7z.exe e "%DriverPath%\*.dl_" -o"%DriverPath%"
	7z.exe e "%DriverPath%\*.ex_" -o"%DriverPath%"
	7z.exe e "%DriverPath%\*.ic_" -o"%DriverPath%"
	7z.exe e "%DriverPath%\*.sy_" -o"%DriverPath%"
)

:Patch3dAcceleration
title Patching 3D acceleration support...

if %Version% == 446.14 (
	call JREPL.bat "%OldPatternP%" "%OldPatchP%" /m /x /f "%DriverPath%\nvd3dum.dll" /o -
	call JREPL.bat "%OldPatternP%" "%OldPatchP%" /m /x /f "%DriverPath%\nvd3dum_cfg.dll" /o -
	call JREPL.bat "%OldPatternP%" "%OldPatchP%" /m /x /f "%DriverPath%\nvd3dumx.dll" /o -
	call JREPL.bat "%OldPatternP%" "%OldPatchP%" /m /x /f "%DriverPath%\nvd3dumx_cfg.dll" /o -
	call JREPL.bat "%OldPatternP%" "%OldPatchP%" /m /x /f "%DriverPath%\nvoglv32.dll" /o -
	call JREPL.bat "%OldPatternP%" "%OldPatchP%" /m /x /f "%DriverPath%\nvoglv64.dll" /o -
	call JREPL.bat "%OldPatternP%" "%OldPatchP%" /m /x /f "%DriverPath%\nvwgf2um.dll" /o -
	call JREPL.bat "%OldPatternP%" "%OldPatchP%" /m /x /f "%DriverPath%\nvwgf2um_cfg.dll" /o -
	call JREPL.bat "%OldPatternP%" "%OldPatchP%" /m /x /f "%DriverPath%\nvwgf2umx.dll" /o -
	call JREPL.bat "%OldPatternP%" "%OldPatchP%" /m /x /f "%DriverPath%\nvwgf2umx_cfg.dll" /o -
	call JREPL.bat "%OldPatternP%" "%OldPatchP%" /m /x /f "%DriverPath%\nvlddmkm.sys" /o -
	title Patching SLI support...
	call JREPL.bat "%PatternSli%" "%PatchSli%" /m /x /f "%DriverPath%\nvlddmkm.sys" /o -
	goto RunTimestampServer
)

if exist "%DriverPath%\nvd3dum.dll" call JREPL.bat "%NewPatternP%" "%NewPatchP%" /m /x /f "%DriverPath%\nvd3dum.dll" /o -
if exist "%DriverPath%\nvd3dum_cfg.dll" call JREPL.bat "%NewPatternP%" "%NewPatchP%" /m /x /f "%DriverPath%\nvd3dum_cfg.dll" /o -
if exist "%DriverPath%\nvd3dumx.dll" call JREPL.bat "%NewPatternP%" "%NewPatchP%" /m /x /f "%DriverPath%\nvd3dumx.dll" /o -
if exist "%DriverPath%\nvd3dumx_cfg.dll" call JREPL.bat "%NewPatternP%" "%NewPatchP%" /m /x /f "%DriverPath%\nvd3dumx_cfg.dll" /o -
if exist "%DriverPath%\nvoglv32.dll" call JREPL.bat "%NewPatternP%" "%NewPatchP%" /m /x /f "%DriverPath%\nvoglv32.dll" /o -
if exist "%DriverPath%\nvoglv64.dll" call JREPL.bat "%NewPatternP%" "%NewPatchP%" /m /x /f "%DriverPath%\nvoglv64.dll" /o -
if exist "%DriverPath%\nvwgf2um.dll" call JREPL.bat "%NewPatternP%" "%NewPatchP%" /m /x /f "%DriverPath%\nvwgf2um.dll" /o -
if exist "%DriverPath%\nvwgf2um_cfg.dll" call JREPL.bat "%NewPatternP%" "%NewPatchP%" /m /x /f "%DriverPath%\nvwgf2um_cfg.dll" /o -
if exist "%DriverPath%\nvwgf2umx.dll" call JREPL.bat "%NewPatternP%" "%NewPatchP%" /m /x /f "%DriverPath%\nvwgf2umx.dll" /o -
if exist "%DriverPath%\nvwgf2umx_cfg.dll" call JREPL.bat "%NewPatternP%" "%NewPatchP%" /m /x /f "%DriverPath%\nvwgf2umx_cfg.dll" /o -
if exist "%DriverPath%\nvlddmkm.sys" call JREPL.bat "%NewPatternP%" "%NewPatchP%" /m /x /f "%DriverPath%\nvlddmkm.sys" /o -

if exist "%DriverPath%\nvd3dum.dll" call JREPL.bat "%PatternCmp%" "%PatchCmp%" /m /x /f "%DriverPath%\nvd3dum.dll" /o -
if exist "%DriverPath%\nvd3dum_cfg.dll" call JREPL.bat "%PatternCmp%" "%PatchCmp%" /m /x /f "%DriverPath%\nvd3dum_cfg.dll" /o -
if exist "%DriverPath%\nvd3dumx.dll" call JREPL.bat "%PatternCmp%" "%PatchCmp%" /m /x /f "%DriverPath%\nvd3dumx.dll" /o -
if exist "%DriverPath%\nvd3dumx_cfg.dll" call JREPL.bat "%PatternCmp%" "%PatchCmp%" /m /x /f "%DriverPath%\nvd3dumx_cfg.dll" /o -
if exist "%DriverPath%\nvoglv32.dll" call JREPL.bat "%PatternCmp%" "%PatchCmp%" /m /x /f "%DriverPath%\nvoglv32.dll" /o -
if exist "%DriverPath%\nvoglv64.dll" call JREPL.bat "%PatternCmp%" "%PatchCmp%" /m /x /f "%DriverPath%\nvoglv64.dll" /o -
if exist "%DriverPath%\nvwgf2um.dll" call JREPL.bat "%PatternCmp%" "%PatchCmp%" /m /x /f "%DriverPath%\nvwgf2um.dll" /o -
if exist "%DriverPath%\nvwgf2um_cfg.dll" call JREPL.bat "%PatternCmp%" "%PatchCmp%" /m /x /f "%DriverPath%\nvwgf2um_cfg.dll" /o -
if exist "%DriverPath%\nvwgf2umx.dll" call JREPL.bat "%PatternCmp%" "%PatchCmp%" /m /x /f "%DriverPath%\nvwgf2umx.dll" /o -
if exist "%DriverPath%\nvwgf2umx_cfg.dll" call JREPL.bat "%PatternCmp%" "%PatchCmp%" /m /x /f "%DriverPath%\nvwgf2umx_cfg.dll" /o -
if exist "%DriverPath%\nvlddmkm.sys" call JREPL.bat "%PatternCmp%" "%PatchCmp%" /m /x /f "%DriverPath%\nvlddmkm.sys" /o -

:RunTimestampServer
start "" TimestampServer.exe

:Sign3dBinaries
title Signind 3D acceleration binaries...
date 01-01-2013
if exist "%DriverPath%\nvd3dum.dll" (
	signtool remove /s "%DriverPath%\nvd3dum.dll"
	signtool.exe sign /f NVIDIA.pfx /p "" /ac "VeriSign Class 3 Public Primary Certification Authority - G5.cer" /t "http://localhost/TSA/2013-01-01T00:00:00" "%DriverPath%\nvd3dum.dll"
)
if exist "%DriverPath%\nvd3dum_cfg.dll" (
	signtool remove /s "%DriverPath%\nvd3dum_cfg.dll"
	signtool.exe sign /f NVIDIA.pfx /p "" /ac "VeriSign Class 3 Public Primary Certification Authority - G5.cer" /t "http://localhost/TSA/2013-01-01T00:00:00" "%DriverPath%\nvd3dum_cfg.dll"
)
if exist "%DriverPath%\nvd3dumx.dll" (
	signtool remove /s "%DriverPath%\nvd3dumx.dll"
	signtool.exe sign /f NVIDIA.pfx /p "" /ac "VeriSign Class 3 Public Primary Certification Authority - G5.cer" /t "http://localhost/TSA/2013-01-01T00:00:00" "%DriverPath%\nvd3dumx.dll"
)
if exist "%DriverPath%\nvd3dumx_cfg.dll" (
	signtool remove /s "%DriverPath%\nvd3dumx_cfg.dll"
	signtool.exe sign /f NVIDIA.pfx /p "" /ac "VeriSign Class 3 Public Primary Certification Authority - G5.cer" /t "http://localhost/TSA/2013-01-01T00:00:00" "%DriverPath%\nvd3dumx_cfg.dll"
)
if exist "%DriverPath%\nvoglv32.dll" (
	signtool remove /s "%DriverPath%\nvoglv32.dll"
	signtool.exe sign /f NVIDIA.pfx /p "" /ac "VeriSign Class 3 Public Primary Certification Authority - G5.cer" /t "http://localhost/TSA/2013-01-01T00:00:00" "%DriverPath%\nvoglv32.dll"
)
if exist "%DriverPath%\nvoglv64.dll" (
	signtool remove /s "%DriverPath%\nvoglv64.dll"
	signtool.exe sign /f NVIDIA.pfx /p "" /ac "VeriSign Class 3 Public Primary Certification Authority - G5.cer" /t "http://localhost/TSA/2013-01-01T00:00:00" "%DriverPath%\nvoglv64.dll"
)
if exist "%DriverPath%\nvwgf2um.dll" (
	signtool remove /s "%DriverPath%\nvwgf2um.dll"
	signtool.exe sign /f NVIDIA.pfx /p "" /ac "VeriSign Class 3 Public Primary Certification Authority - G5.cer" /t "http://localhost/TSA/2013-01-01T00:00:00" "%DriverPath%\nvwgf2um.dll"
)
if exist "%DriverPath%\nvwgf2um_cfg.dll" (
	signtool remove /s "%DriverPath%\nvwgf2um_cfg.dll"
	signtool.exe sign /f NVIDIA.pfx /p "" /ac "VeriSign Class 3 Public Primary Certification Authority - G5.cer" /t "http://localhost/TSA/2013-01-01T00:00:00" "%DriverPath%\nvwgf2um_cfg.dll"
)
if exist "%DriverPath%\nvwgf2umx.dll" (
	signtool remove /s "%DriverPath%\nvwgf2umx.dll"
	signtool.exe sign /f NVIDIA.pfx /p "" /ac "VeriSign Class 3 Public Primary Certification Authority - G5.cer" /t "http://localhost/TSA/2013-01-01T00:00:00" "%DriverPath%\nvwgf2umx.dll"
)
if exist "%DriverPath%\nvwgf2umx_cfg.dll" (
	signtool remove /s "%DriverPath%\nvwgf2umx_cfg.dll"
	signtool.exe sign /f NVIDIA.pfx /p "" /ac "VeriSign Class 3 Public Primary Certification Authority - G5.cer" /t "http://localhost/TSA/2013-01-01T00:00:00" "%DriverPath%\nvwgf2umx_cfg.dll"
)
w32tm /resync /nowait >nul

:Pack3dBinaries
if %Version% lss 535 (
	title Packing 3D acceleration binaries...
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
)

:CheckNvencPatchPresence
for /f %%a in ( 'curl -o nul -s -Iw "%%{http_code}" "%Nvenc64PatchUrl%"' ) do set http=%%a
if not %http% == 200 goto GenerateCatalogFile

:AskUserAboutNvenc
echo.
choice /m "Do you want to apply NVENC patch? This may enable NVENC support on some cards. Attention: if your card does not have hardware NVENC support, the patch will cause problems (crashes) in applications using NVENC"
if %ErrorLevel% == 1 goto DownloadNvencPatches
if %ErrorLevel% == 2 goto GenerateCatalogFile

:DownloadNvencPatches
title Downloading NVENC patches...
curl -s -O %Nvenc32PatchUrl%
curl -s -O %Nvenc64PatchUrl%

:PromptUserAboutNvenc
echo Apply NVENC patch manually now
pause

:SignNvencBinaries
title Signind NVENC binaries...
date 01-01-2013
if exist "%DriverPath%\nvencodeapi.dll" signtool.exe sign /f NVIDIA.pfx /p "" /ac "VeriSign Class 3 Public Primary Certification Authority - G5.cer" /t "http://localhost/TSA/2013-01-01T00:00:00" "%DriverPath%\nvencodeapi.dll"
if exist "%DriverPath%\nvencodeapi64.dll" signtool.exe sign /f NVIDIA.pfx /p "" /ac "VeriSign Class 3 Public Primary Certification Authority - G5.cer" /t "http://localhost/TSA/2013-01-01T00:00:00" "%DriverPath%\nvencodeapi64.dll"
w32tm /resync /nowait >nul

:PackNvencBinaries
if %Version% lss 535 (
	title Packing NVENC binaries...
	if exist "%DriverPath%\nvencodeapi.dll" makecab "%DriverPath%\nvencodeapi.dll" /l "%DriverPath%"
	if exist "%DriverPath%\nvencodeapi64.dll" makecab "%DriverPath%\nvencodeapi64.dll" /l "%DriverPath%"
)

:GenerateCatalogFile
title Generating catalog file...
del "%DriverPath%\nv_disp.cat"
Inf2Cat.exe /driver:"%DriverPath%" /os:10_x64

:CheckCatalogFile
if not exist "%DriverPath%\nv_disp.cat" (
	echo Failed to generate catalog file^^!
	pause
	goto Clean
)

:SignCatalogFile
title Signing catalog file...
date 01-01-2015
signtool.exe sign /f "Yongyu.pfx" /p "440" /ac "thawte Primary Root CA.cer" /t "http://localhost/TSA/2015-01-01T00:00:00" "%DriverPath%\nv_disp.cat"
if not %ErrorLevel% == 0 (
	echo Failed to sign catalog file^^!
	pause
	goto Clean
)

:Clean
w32tm /resync /nowait >nul
Taskkill /f /im TimestampServer.exe
rd "%ProgramData%\JREPL" /s /q
rd "%LocalAppData%\DeFconX" /s /q
rd "%Temp%\WST" /s /q
del *.1337
goto :eof

exit /b 0