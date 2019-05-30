#!/bin/sh

INIT_DIR="C:/External"
REPO_URL="https://github.com/open-source-parsers/jsoncpp.git"
REPO_VER="1.8.4"
GENERATOR="Visual Studio 15 2017"

# generator with underline
generator_ul=${GENERATOR//' '/'_'}
echo $generator_ul

repo_name=${REPO_URL##*/}
repo_name=${repo_name%%.*}
echo $repo_name

repo_path=$INIT_DIR/$repo_name/$REPO_VER
echo $repo_path

install_prefix=$repo_path/$generator_ul

mkdir -p $repo_path
cd $repo_path
mkdir include
mkdir lib

if [ ! -d $repo_name ]; then
	echo "Try to download source code from $REPO_URL..."
	git clone https://github.com/open-source-parsers/jsoncpp.git
	cd $repo_name
	git checkout -b $REPO_VER $REPO_VER
	cd ..
fi
cd $repo_name
mkdir build 
cd build

rm -rf $generator_ul
mkdir $generator_ul 
cd $generator_ul
cmake -G "$GENERATOR" ../.. -DJSONCPP_WITH_CMAKE_PACKAGE=ON -DCMAKE_INSTALL_PREFIX=$install_prefix
cmake --build . --config Release || goto :error

read -p "Press any key to continue..."