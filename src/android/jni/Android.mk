# Copyright (C) 2012 Corona Labs Inc.
#

LOCAL_PATH := $(call my-dir)

# TARGET_PLATFORM := android-8

ifeq ($(OS),Windows_NT)
	CORONA_ROOT := C:\PROGRA~2\CORONA~1\Corona\Native
else
  CORONA_ROOT := /Applications/CoronaEnterprise
endif

LUA_API_DIR := $(CORONA_ROOT)/Corona/shared/include/lua
LUA_API_CORONA := $(CORONA_ROOT)/Corona/shared/include/Corona

PLUGIN_DIR := ../..

SRC_DIR := $(PLUGIN_DIR)/shared
BR_DIR := $(PLUGIN_DIR)/../third_party/ByteReader

# -----------------------------------------------------------------------------

include $(CLEAR_VARS)
LOCAL_MODULE := liblua
LOCAL_SRC_FILES := ../corona-libs/jni/$(TARGET_ARCH_ABI)/liblua.so
LOCAL_EXPORT_C_INCLUDES := $(LUA_API_DIR)
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libcorona
LOCAL_SRC_FILES := ../corona-libs/jni/$(TARGET_ARCH_ABI)/libcorona.so
LOCAL_EXPORT_C_INCLUDES := $(LUA_API_CORONA)
include $(PREBUILT_SHARED_LIBRARY)

include $(clear_vars)
LOCAL_MODULE := webp
LOCAL_SRC_FILES := ../third_party_libs/$(TARGET_ARCH_ABI)/libwebp.a
LOCAL_EXPORT_C_INCLUDES := $(PLUGIN_DIR)/../third_party/libwebp
include $(PREBUILT_STATIC_LIBRARY)

include $(clear_vars)
LOCAL_MODULE := webpdemux
LOCAL_SRC_FILES := ../third_party_libs/$(TARGET_ARCH_ABI)/libwebpdemux.a
LOCAL_EXPORT_C_INCLUDES := $(PLUGIN_DIR)/../third_party/libwebp
include $(PREBUILT_STATIC_LIBRARY)

# -----------------------------------------------------------------------------

LOCAL_PATH := $(SRC_DIR)

# -----------------------------------------------------------------------------

include $(CLEAR_VARS)
LOCAL_MODULE := libplugin.webp

LOCAL_C_INCLUDES := $(SRC_DIR) $(BR_DIR)

LOCAL_SRC_FILES := plugin.webp.cpp ../../third_party/ByteReader/ByteReader.cpp

LOCAL_CFLAGS := $(WEBP_CFLAGS) \
	-DANDROID_NDK \
	-DNDEBUG \
	-D_REENTRANT \
	-DRtt_ANDROID_ENV

LOCAL_LDLIBS := -llog -landroid -s

# LOCAL_CFLAGS += -fopenmp
# LOCAL_LDFLAGS += -fopenmp

LOCAL_LDFLAGS += "-Wl,-z,max-page-size=16384"
LOCAL_LDFLAGS += "-Wl,-z,common-page-size=16384"

LOCAL_SHARED_LIBRARIES := \
	liblua libcorona

ifeq ($(TARGET_ARCH),arm)
LOCAL_CFLAGS += -D_ARM_ASSEM_ -D_M_ARM
endif

ifeq ($(TARGET_ARCH),armeabi-v7a)
# LOCAL_CFLAGS += -DHAVENEON=1
endif

# LOCAL_WHOLE_STATIC_LIBRARIES += cpufeatures
# LOCAL_CFLAGS += -mfloat-abi=softfp -mfpu=neon -march=armv7 -mthumb
LOCAL_CPPFLAGS += -std=c++11
LOCAL_CPP_FEATURES += exceptions
LOCAL_STATIC_LIBRARIES := webpdemux webp

# Arm vs Thumb.
LOCAL_ARM_MODE := arm
# LOCAL_ARM_NEON := true
include $(BUILD_SHARED_LIBRARY)

$(call import-module, android/cpufeatures)
