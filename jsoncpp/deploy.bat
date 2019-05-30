@echo off

SETLOCAL EnableDelayedExpansion

set INIT_DIR=%1
set REPO_URL=%2
set REPO_VER=%3
set GENERATOR=%4
echo INIT_DIR: %INIT_DIR%
echo REPO_URL: %REPO_URL%
echo REPO_VER: %REPO_VER%
echo GENERATOR: %GENERATOR%
pause

rem generator with underline
set generator_ul=%GENERATOR: =_%
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

set install_prefix=%repo_path:"=%/%generator_ul:"=%
set install_prefix_win=%install_prefix:/=\%
echo install_prefix: %install_prefix%
echo install_prefix_win: %install_prefix_win%
pause

mkdir %repo_path_win%
cd /d %repo_path_win%

if not exist %repo_name% (
	echo "Try to download source code from %REPO_URL%..."
	git clone https://github.com/open-source-parsers/jsoncpp.git
	cd %repo_name%
	git checkout -b %REPO_VER% %REPO_VER%
	cd ..
	cd
)
pause
cd
echo cd %repo_name%
cd %repo_name%
pause
mkdir build
pause
cd build
pause

rd /q /s %generator_ul%
:wait_rd_generator_ul
timeout 1
if exist %generator_ul% (
	goto wait_rd_generator_ul
)
mkdir %generator_ul%
cd %generator_ul%
cmake -G %GENERATOR% ../.. -DJSONCPP_WITH_CMAKE_PACKAGE=ON -DCMAKE_INSTALL_PREFIX=%install_prefix%
pause
echo rd /q /s %install_prefix_win%
rd /q /s %install_prefix_win%
pause
cmake --build . --config Debug --target install || goto :error
pause
mkdir %install_prefix_win%\Debug
move %install_prefix_win%\include %install_prefix_win%\Debug\include
move %install_prefix_win%\lib %install_prefix_win%\Debug\lib
pause
cmake --build . --config Release --target install || goto :error
mkdir %install_prefix_win%\Release
move %install_prefix_win%\include %install_prefix_win%\Release\include
move %install_prefix_win%\lib %install_prefix_win%\Release\lib

:error
pause