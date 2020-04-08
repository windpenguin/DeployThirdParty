@echo off

SETLOCAL EnableDelayedExpansion

set INIT_DIR=%1
set REPO_URL=%2
set REPO_VER=%3
set COMPILER=%4
set RT=%5
set ARCH=%6
echo INIT_DIR: %INIT_DIR%
echo REPO_URL: %REPO_URL%
echo REPO_VER: %REPO_VER%
echo COMPILER: %COMPILER%
echo RT: %RT%
echo ARCH: %ARCH%

rem compiler with underline
set compiler_ul=%COMPILER: =_%
echo compiler_ul: %compiler_ul%

if defined ARCH (
	set generator="%COMPILER:"=% %ARCH:"=%"
) else (
	set generator="%COMPILER:"=%"
)
set generator_ul=%generator: =_%
echo generator: %generator%
echo generator_ul: %generator_ul%

for /f "tokens=4* delims=/" %%i in (%REPO_URL%) do (
	set repo_name=%%i
)
for /f "tokens=1* delims=." %%i in ("%repo_name%") do (
	set repo_name=%%i
)
echo repo_name: %repo_name%

set repo_path=%INIT_DIR:"=%/%repo_name:"=%/%REPO_VER:"=%
set repo_path_win=%repo_path:/=\%
echo repo_path: %repo_path%
echo repo_path_win: %repo_path_win%

if defined ARCH (
	set install_prefix=%repo_path:"=%/%compiler_ul:"=%/%ARCH:"=%
) else (
	set install_prefix=%repo_path:"=%/%compiler_ul:"=%/Win32
)
set install_prefix=%install_prefix%/%RT:"=%
set install_prefix_win=%install_prefix:/=\%
echo install_prefix: %install_prefix%
echo install_prefix_win: %install_prefix_win%

if not exist %repo_path_win% mkdir %repo_path_win%
cd /d %repo_path_win%

if not exist %repo_name% (
	echo Try to download source code from %REPO_URL%...
	git clone https://github.com/open-source-parsers/jsoncpp.git
	cd %repo_name%
	git checkout -b %REPO_VER% %REPO_VER%
	
	rem add runtime config mt/md to CMakeLists.txt
	ren CMakeLists.txt CMakeListsTemp.txt

	cd ..
)
cd %repo_name%

if exist CMakeLists.txt del /f CMakeLists.txt
%~dp0AddRT.py -r%RT%

if not exist build mkdir build
cd build

if not exist %generator_ul% mkdir %generator_ul%
cd %generator_ul%

if exist %RT% rd /q /s %RT%
:wait_rd_rt
timeout 2
if exist %RT% (
	goto wait_rd_rt
)
mkdir %RT%
cd %RT%

for %%i in (Debug Release) do (
	echo Generate %%i
	
	mkdir %%i
	cd %%i
	cmake -G %GENERATOR% ../../../.. -DJSONCPP_WITH_CMAKE_PACKAGE=ON -DCMAKE_INSTALL_PREFIX=%install_prefix%/%%i
	
	if exist %install_prefix_win%\%%i rd /q /s %install_prefix_win%\%%i
	
	cmake --build . --config %%i --target install || goto :error
	cd ..
)

:error