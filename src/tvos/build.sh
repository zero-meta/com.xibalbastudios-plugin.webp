#!/bin/bash

path=`dirname $0`

OUTPUT_DIR=$1
OUTPUT_SUFFIX=a
CONFIG=Release

./build_libwebp.sh

cd ${path}

#
# Checks exit value for error
# 
checkError() {
    if [ $? -ne 0 ]
    then
        echo "Exiting due to errors (above)"
        exit -1
    fi
}

remove_dir_if_exist() {
    if [ -d ${1} ]
    then
        rm -rf ${1}
    fi
}

# 
# Canonicalize relative paths to absolute paths
# 
pushd $path > /dev/null
dir=`pwd`
path=$dir
popd > /dev/null

if [ -z "$OUTPUT_DIR" ]
then
    OUTPUT_DIR=.
fi

pushd $OUTPUT_DIR > /dev/null
dir=`pwd`
OUTPUT_DIR=$dir
popd > /dev/null

echo "OUTPUT_DIR: $OUTPUT_DIR"

# tvOS
xcodebuild -project "$path/Plugin.xcodeproj" -configuration $CONFIG clean
checkError

xcodebuild -project "$path/Plugin.xcodeproj" -configuration $CONFIG -sdk appletvos
checkError

dst_dir="${path}/../../plugins/2016.2874/appletvos"
remove_dir_if_exist ${dst_dir}/Corona_plugin_webp.framework

cp -r ${path}/build/Release-appletvos/Corona_plugin_webp.framework ${dst_dir}/
