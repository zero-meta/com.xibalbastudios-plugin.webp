#!/bin/bash

cd $(dirname $0)

current_dir=$(pwd)

project_root=${current_dir}/../..
webp_root=${project_root}/third_party/libwebp
INSTALL_DIR=${webp_root}/build/tvos/install

TVOS_MIN_VERSION="12.0"

clean_prev_build_results() {
    cd ${webp_root}
    if [ -d ./build/tvos ]
    then
    	echo "remove build/tvos"
	    rm -rf ./build/tvos
	fi
}

remove_dir_if_exist() {
    if [ -d ${1} ]
    then
        rm -rf ${1}
    fi
}

build_libwebp() {
    PLATFORM=${1}
    # ARCH_DIR=${2}

    cd ${webp_root}
    if [ ! -d build/tvos/${PLATFORM} ]
    then
        mkdir -p build/tvos/${PLATFORM}
    fi

    # if [ ! -d ${INSTALL_DIR} ]
    # then
    #     mkdir -p ${INSTALL_DIR}
    # fi
    # -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}/${ARCH_DIR}" \

    cd build/tvos/${PLATFORM}
    cmake ${webp_root} \
        -DCMAKE_TOOLCHAIN_FILE=${current_dir}/tvos.toolchain.cmake \
        -DTVOS_PLATFORM=${PLATFORM} \
        -DTVOS_DEPLOYMENT_TARGET=${TVOS_MIN_VERSION} \
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

build_libwebp "OS64" "tvos-arm64"
build_libwebp "SIMULATOR64" "simulator-x86_64"
# build_libwebp "SIMULATORARM64" "simulator-arm64"

cd ${webp_root}
lipo -create build/tvos/OS64/libwebp.a build/tvos/SIMULATOR64/libwebp.a -output build/tvos/libwebp.a

if [ ! -d ${current_dir}/third_party_libs ]
then
    mkdir -p ${current_dir}/third_party_libs
fi
cp build/tvos/libwebp.a ${current_dir}/third_party_libs/libwebp.a

# XCFRAMEWORK_PATH="${project_root}/libs/tvos/libwebp.xcframework"
# if [ -d ${XCFRAMEWORK_PATH} ]
# then
#     rm -rf ${XCFRAMEWORK_PATH}
# fi

# if [ -d build/tvos/OS64/libwebp.framework]
# then
#     rm -rf build/tvos/OS64/libwebp.framework
# fi
# xcodebuild -create-framework \
#     -library build/tvos/OS64/libwebp.a \
#     -output build/tvos/OS64/libwebp.framework

# if [ -d build/tvos/libwebp.framework]
# then
#     rm -rf build/tvos/libwebp.framework
# fi
# xcodebuild -create-framework \
#     -library build/tvos/libwebp.a \
#     -output build/tvos/libwebp.framework

# xcodebuild -create-xcframework \
#     -framework build/tvos/OS64/libwebp.framework \
#     -framework build/tvos/libwebp.framework \
#     -output ${XCFRAMEWORK_PATH}

# xcodebuild -create-xcframework \
#     -library build/tvos/OS64/libwebp.a \
#     -library build/tvos/SIMULATOR64/libwebp.a \
#     -output ${XCFRAMEWORK_PATH}

