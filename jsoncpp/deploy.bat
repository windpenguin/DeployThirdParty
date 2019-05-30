@echo off

SETLOCAL EnableDelayedExpansion

set INIT_DIR=%1
set REPO_URL=%2
set REPO_VER=%3
set COMPILER=%4
set ARCH=%5
echo INIT_DIR: %INIT_DIR%
echo REPO_URL: %REPO_URL%
echo REPO_VER: %REPO_VER%
echo COMPILER: %COMPILER%
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
set install_prefix_win=%install_prefix:/=\%
echo install_prefix: %install_prefix%
echo install_prefix_win: %install_prefix_win%

if not exist %repo_path_win% mkdir %repo_path_win%
cd /d %repo_path_win%

if not exist %repo_name% (
	echo "Try to download source code from %REPO_URL%..."
	git clone https://github.com/open-source-parsers/jsoncpp.git
	cd %repo_name%
	git checkout -b %REPO_VER% %REPO_VER%
	cd ..
)
cd %repo_name%
if not exist build mkdir build
cd build

if exist %generator_ul% rd /q /s %generator_ul%
:wait_rd_generator_ul
timeout 2
if exist %generator_ul% (
	goto wait_rd_generator_ul
)
if not exist %generator_ul% mkdir %generator_ul%
cd %generator_ul%
cmake -G %GENERATOR% ../.. -DJSONCPP_WITH_CMAKE_PACKAGE=ON -DCMAKE_INSTALL_PREFIX=%install_prefix%

if exist %install_prefix_win% rd /q /s %install_prefix_win%

cmake --build . --config Debug --target install || goto :error
if not exist %install_prefix_win%\Debug mkdir %install_prefix_win%\Debug
move %install_prefix_win%\include %install_prefix_win%\Debug\include
move %install_prefix_win%\lib %install_prefix_win%\Debug\lib
timeout 2

cmake --build . --config Release --target install || goto :error
if not exist %install_prefix_win%\Release mkdir %install_prefix_win%\Release
move %install_prefix_win%\include %install_prefix_win%\Release\include
move %install_prefix_win%\lib %install_prefix_win%\Release\lib
timeout 2

:error
pause