#!/bin/sh

if [ -z "${CMAKE_BIN+x}" ]; then
  CMAKE_BIN=cmake
fi

if [ -z "${CXX+x}" ]; then
  CXX=g++
fi

if [ -z "${CC+x}" ]; then
  CC=gcc
fi

rm -rf build
echo ${CMAKE_BIN}
${CMAKE_BIN} -H. -DCMAKE_INSTALL_PREFIX=dist -DCMAKE_C_COMPIER=${CC} -DCMAKE_CXX_COMPILER=${CXX} -DSURFACE_BUILD_WITH_OPENMP=On -DBUILD_SHARED_LIBS=On -DCMAKE_BUILD_TYPE=Release -Bbuild

#CC=gcc-4.8.4 CXX=g++-4.8.4 ${CMAKE_BIN} -H. -DCMAKE_INSTALL_PREFIX=dist -DSURFACE_BUILD_WITH_OPENMP=On -DBUILD_SHARED_LIBS=On -DCMAKE_BUILD_TYPE=Release -Bbuild
