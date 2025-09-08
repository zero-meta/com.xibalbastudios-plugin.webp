#!/bin/bash

cd $(dirname $0)

current_dir=$(pwd)

ANDROID_NDK_HOME=$HOME/Library/Android/sdk/ndk
ANDROID_NDK_DIR=$ANDROID_NDK_HOME/21.0.6113669

project_root=${current_dir}/../..
webp_root=${project_root}/third_party/libwebp

CPU_CORES=$(sysctl -n hw.ncpu 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)
echo "CPU_CORES: ${CPU_CORES}"

clean_prev_build_results() {
    cd ${webp_root}
    if [ -d ./build/android ]
    then
    	echo "remove build/android"
	    rm -rf ./build/android
	fi
}

build_libwebp() {
    cd ${webp_root}
    if [ ! -d build/android/${1} ]
    then
        mkdir -p build/android/${1}
    fi
    cd build/android/${1}

    cmake ${webp_root} -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_DIR/build/cmake/android.toolchain.cmake \
        -DWEBP_BUILD_ANIM_UTILS=OFF \
        -DWEBP_BUILD_CWEBP=OFF \
        -DWEBP_BUILD_DWEBP=OFF \
        -DWEBP_BUILD_GIF2WEBP=OFF \
        -DWEBP_BUILD_IMG2WEBP=OFF \
        -DWEBP_BUILD_VWEBP=OFF \
        -DWEBP_BUILD_WEBPINFO=OFF \
        -DWEBP_BUILD_LIBWEBPMUX=OFF \
        -DWEBP_BUILD_WEBPMUX=OFF \
        -DWEBP_BUILD_EXTRAS=OFF \
        -DANDROID_ABI=${1} \
        -DCMAKE_BUILD_TYPE=Release \
        -DANDROID_NATIVE_API_LEVEL=16
    make -j${CPU_CORES}

    libs_dir=${current_dir}/third_party_libs
    if [ ! -d ${libs_dir}/${1} ]
    then
        mkdir -p ${libs_dir}/${1}
    fi
    cp libwebp.a ${libs_dir}/${1}/libwebp.a
    cp libwebpdemux.a ${libs_dir}/${1}/libwebpdemux.a
}

if [ "$1" == "clean" ]
then
    clean_prev_build_results
fi

build_libwebp arm64-v8a
build_libwebp armeabi-v7a
build_libwebp x86_64
build_libwebp x86
