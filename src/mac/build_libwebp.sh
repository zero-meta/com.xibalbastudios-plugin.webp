#!/bin/bash

cd $(dirname $0)

current_dir=$(pwd)

project_root=${current_dir}/../..
webp_root=${project_root}/third_party/libwebp

clean_prev_build_results() {
    cd ${webp_root}
    if [ -d ./build/mac ]
    then
    	echo "remove build/mac"
	    rm -rf ./build/mac
	fi
}

build_libwebp() {
    cd ${webp_root}
    if [ ! -d build/mac/${1} ]
    then
        mkdir -p build/mac/${1}
    fi
    cd build/mac/${1}
    cmake ${webp_root} -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF \
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
        -DCMAKE_OSX_ARCHITECTURES=${1}
    make -j8
}

if [ "$1" == "clean" ]
then
    clean_prev_build_results
fi

build_libwebp x86_64
build_libwebp arm64

cd ${webp_root}
lipo -create build/mac/x86_64/libwebp.a build/mac/arm64/libwebp.a -output build/mac/libwebp.a

libs_dir=${current_dir}/third_party_libs
if [ ! -d ${libs_dir} ]
then
    mkdir -p ${libs_dir}
fi
cp build/mac/libwebp.a ${libs_dir}/libwebp.a
