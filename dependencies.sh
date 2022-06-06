#!/bin/bash

curl -OL https://boostorg.jfrog.io/artifactory/main/release/1.70.0/source/boost_1_70_0.tar.bz2
tar -xjf boost_1_70_0.tar.bz2
cd boost_1_70_0
./bootstrap.sh --with-libraries=system,filesystem,thread,date_time,chrono,regex,serialization,atomic,program_options,locale,timer,log
./b2


cd ..


curl -OL https://www.openssl.org/source/openssl-1.1.1n.tar.gz
tar xaf openssl-1.1.1n.tar.gz 
cd openssl-1.1.1n/
./config --prefix=/home/user/openssl --openssldir=/home/user/openssl shared zlib
make
make test
make install

cd ..


wget https://download.qt.io/new_archive/qt/5.11/5.11.2/qt-opensource-linux-x64-5.11.2.run
chmod +x qt-opensource-linux-x64-5.11.2.run
./qt-opensource-linux-x64-5.11.2.run


cd ..


export BOOST_ROOT=/home/zano/boost_1_70_0  
export OPENSSL_ROOT_DIR=/home/zano/openssl
export QT_PREFIX_PATH=/home/zano/Qt5.11.2/5.11.2/gcc_64