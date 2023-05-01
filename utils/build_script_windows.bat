SET QT_PREFIX_PATH=D:\Qt\Qt5.11.2\5.11.2\msvc2017_64
SET INNOSETUP_PATH=C:\Program Files (x86)\Inno Setup 6\ISCC.exe
SET ETC_BINARIES_PATH=C:\Users\cosmos\Documents\GitHub\EvoX\build\etc-binaries
SET BUILDS_PATH=C:\Users\cosmos\Documents\GitHub\EvoX\build\evox
SET ACHIVE_NAME_PREFIX=evox-win-x64
SET LOCAL_BOOST_PATH=C:\local\boost_1_70_0\lib64-msvc-14.1
SET LOCAL_BOOST_LIB_PATH=C:\local\boost_1_70_0\lib64-msvc-14.1
SET MY_PATH=%~dp0
SET SOURCES_PATH=%MY_PATH:~0,-7%

IF NOT [%build_prefix%] == [] (
  SET ACHIVE_NAME_PREFIX=%ACHIVE_NAME_PREFIX%%build_prefix%-
)

IF "%testnet%" == "true" (
  SET TESTNET_DEF=-D TESTNET=TRUE
  SET TESTNET_LABEL=testnet 
  SET ACHIVE_NAME_PREFIX=%ACHIVE_NAME_PREFIX%testnet-
)

SET PARAM=%~1
IF "%PARAM%"=="--skip-build" ( GOTO skip_build )

@echo on

set BOOST_ROOT=%LOCAL_BOOST_PATH%
set BOOST_LIBRARYDIR=%LOCAL_BOOST_LIB_PATH%



@echo "---------------- PREPARING BINARIES ---------------------------"
@echo "---------------------------------------------------------------"



cd %SOURCES_PATH%

@echo "---------------- BUILDING APPLICATIONS ------------------------"
@echo "---------------------------------------------------------------"




rmdir build /s /q
mkdir build
cd build
cmake %TESTNET_DEF% -D CMAKE_PREFIX_PATH="%QT_PREFIX_PATH%" -D BUILD_GUI=TRUE -D STATIC=FALSE -G "Visual Studio 15 2017 Win64" -T host=x64 ..
IF %ERRORLEVEL% NEQ 0 (
  goto error
)

call "D:\Program Files\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat" x86_amd64
echo on
cd %SOURCES_PATH%\build

msbuild version.vcxproj /p:SubSystem="CONSOLE,5.02"  /p:Configuration=Release /t:Build
IF %ERRORLEVEL% NEQ 0 (
  goto error
)

msbuild src/daemon.vcxproj /p:SubSystem="CONSOLE,5.02"  /p:Configuration=Release /t:Build
IF %ERRORLEVEL% NEQ 0 (
  goto error
)

msbuild src/simplewallet.vcxproj /p:SubSystem="CONSOLE,5.02"  /p:Configuration=Release /t:Build
IF %ERRORLEVEL% NEQ 0 (
  goto error
)

msbuild src/Evox.vcxproj /p:SubSystem="WINDOWS,5.02" /p:Configuration=Release /t:Build

IF %ERRORLEVEL% NEQ 0 (
  goto error
)


@echo on
echo "sources are built successfully"




:skip_build
cd %SOURCES_PATH%/build

set cmd=src\Release\simplewallet.exe --version
FOR /F "tokens=3" %%a IN ('%cmd%') DO set version=%%a  
set version=%version:~0,-2%
echo '%version%'

set build_zip_filename=%ACHIVE_NAME_PREFIX%%version%.zip
set build_zip_path=%BUILDS_PATH%\builds\%build_zip_filename%

del /F /Q %build_zip_path%

cd src\release



@echo on


mkdir bunch

copy /Y Evox.exe bunch
copy /Y evoxd.exe bunch
copy /Y simplewallet.exe bunch
copy /Y *.pdb bunch

%QT_PREFIX_PATH%\bin\windeployqt.exe bunch\Evox.exe

cd bunch

zip -r %build_zip_path% *.*
IF %ERRORLEVEL% NEQ 0 (
  goto error
)


@echo "Add html"

cd %SOURCES_PATH%\src\gui\qt-daemon\layout
zip -x html/package.json html/gulpfile.js html/less/* -r %build_zip_path% html
IF %ERRORLEVEL% NEQ 0 (
  goto error
)


@echo "Add runtime stuff"


cd %ETC_BINARIES_PATH%
zip -r %build_zip_path% *.*
IF %ERRORLEVEL% NEQ 0 (
  goto error
)


cd %SOURCES_PATH%\build
IF %ERRORLEVEL% NEQ 0 (
  goto error
)


@echo "---------------------------------------------------------------"
@echo "-------------------Building installer--------------------------"
@echo "---------------------------------------------------------------"

mkdir installer_src


unzip -o %build_zip_path% -d installer_src
IF %ERRORLEVEL% NEQ 0 (
  goto error
)


"%INNOSETUP_PATH%"  /dBinariesPath=../build/installer_src /DMyAppVersion=%version% /o%BUILDS_PATH%\builds\ /f%ACHIVE_NAME_PREFIX%%version%-installer ..\utils\setup_64.iss 
IF %ERRORLEVEL% NEQ 0 (
  goto error
)


@echo "---------------------------------------------------------------"
@echo "---------------------------------------------------------------"

set installer_file=%ACHIVE_NAME_PREFIX%%version%-installer.exe
set installer_path=%BUILDS_PATH%\builds\%installer_file%

@echo "   SIGNING ...."

%EVOX_SIGN_CMD% %installer_path%
IF %ERRORLEVEL% NEQ 0 (
  @echo "failed to sign installer"
  goto error
)

@echo "   UPLOADING TO SERVER ...."

pscp -load evox_build_server %installer_path% build.evox.org:/var/www/html/builds
IF %ERRORLEVEL% NEQ 0 (
  @echo "FAILED TO UPLOAD EXE TO SERVER"
  goto error
)
call :sha256 %installer_path% installer_checksum

pscp -load evox_build_server %build_zip_path% build.evox.org:/var/www/html/builds
IF %ERRORLEVEL% NEQ 0 (
  @echo "FAILED TO UPLOAD ZIP TO SERVER"
  goto error
)
call :sha256 %build_zip_path% build_zip_checksum

set mail_msg="New %build_prefix% %TESTNET_LABEL%build for win-x64:<br>INST: https://build.evox.org/builds/%installer_file% <br>sha256: %installer_checksum%<br><br>ZIP:  https://build.evox.org/builds/%build_zip_filename% <br>sha256: %build_zip_checksum%<br>"

echo %mail_msg%

senditquiet.exe  -t %emails% -subject "Evox win-x64 %build_prefix% %TESTNET_LABEL%build %version%" -body %mail_msg%


goto success

:error
echo "BUILD FAILED"
exit /B %ERRORLEVEL%

:success
echo "BUILD SUCCESS"

cd ..

EXIT /B %ERRORLEVEL%


:: functions

:sha256
@setlocal enabledelayedexpansion
@set /a count=1 
@for /f "skip=1 delims=:" %%a in ('CertUtil -hashfile %1 SHA256') do @(
  @if !count! equ 1 set "hash=%%a"
  @set /a count+=1
)
@(
 @endlocal
 @set "%2=%hash: =%
)
@exit /B 0
