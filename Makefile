FINALPACKAGE = 1
DEBUG = 0

INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS = arm64 arm64e
TARGET = iphone:clang::13

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AppSwitcherController

$(TWEAK_NAME)_FILES = $(TWEAK_NAME).xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += AppSwitcherControllerSettings
include $(THEOS_MAKE_PATH)/aggregate.mk
