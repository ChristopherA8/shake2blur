TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e
# DEBUG = 0
# FINALPACKAGE = 1


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Shake2Blur

Shake2Blur_FILES = Tweak.xm
Shake2Blur_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
