#!/bin/bash

cd $(dirname $0)

current_dir=$(pwd)

project_root=${current_dir}/../..
webp_root=${project_root}/third_party/libwebp

IOS_MIN_VERSION="12.0"

clean_prev_build_results() {
    cd ${webp_root}
    if [ -d ./build/ios ]
    then
    	echo "remove build/ios"
	    rm -rf ./build/ios
	fi
}

build_libwebp() {
    cd ${webp_root}
    if [ ! -d build/ios/${1} ]
    then
        mkdir -p build/ios/${1}
    fi
    cd build/ios/${1}
    cmake ${webp_root} \
        -DCMAKE_TOOLCHAIN_FILE=${current_dir}/ios.toolchain.cmake \
        -DIOS_PLATFORM=${1} \
        -DIOS_DEPLOYMENT_TARGET=${IOS_MIN_VERSION} \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DWEBP_BUILD_ANIM_UTILS=OFF \
        -DWEBP_BUILD_CWEBP=OFF \
        -DWEBP_BUILD_DWEBP=OFF \
        -DWEBP_BUILD_GIF2WEBP=OFF \
        -DWEBP_BUILD_IMG2WEBP=OFF \
        -DWEBP_BUILD_VWEBP=OFF \
        -DWEBP_BUILD_WEBPINFO=OFF \
        -DWEBP_BUILD_LIBWEBPMUX=OFF \
        -DWEBP_BUILD_WEBPMUX=OFF \
        -DWEBP_BUILD_EXTRAS=OFF
    make -j8
}

if [ "$1" == "clean" ]
then
    clean_prev_build_results
fi

build_libwebp "OS64"
build_libwebp "SIMULATOR64"
# build_libwebp "SIMULATORARM64"

cd ${webp_root}
lipo -create build/ios/OS64/libwebp.a build/ios/SIMULATOR64/libwebp.a -output build/ios/libwebp.a

libs_dir=${current_dir}/third_party_libs
if [ ! -d ${libs_dir} ]
then
    mkdir -p ${libs_dir}
fi
cp build/ios/libwebp.a ${libs_dir}/libwebp.a
