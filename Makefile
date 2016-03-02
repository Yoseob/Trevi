## USER CONFIGURABLE SETTINGS ##
PROJECT_NAME = HelloTrevi
COMPILE_MODE = Debug
PLATFORM     = $(shell uname -s)
ARCH         = $(shell uname -m)
SOURCE_DIR   = Trevi_ver_lime

## LOCATIONS ##
ROOT_DIR            = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
TREVI_DIR           = $(ROOT_DIR)/Trevi
LIME_DIR            = $(ROOT_DIR)/Lime
SRC_DIR             = $(ROOT_DIR)/$(SOURCE_DIR)
BUILD_DIR           = $(ROOT_DIR)/build
PLATFORM_DIR        = $(BUILD_DIR)/$(PROJECT_NAME)/$(COMPILE_MODE)/$(PLATFORM)/$(ARCH)
PLATFORM_BUILD_DIR  = $(PLATFORM_DIR)/bin
PLATFORM_LIB_DIR    = $(PLATFORM_DIR)/lib
PLATFORM_OBJ_DIR    = $(PLATFORM_DIR)/obj
PLATFORM_TEMP_DIR   = $(PLATFORM_DIR)/tmp

## LIBUV SETTING ##
UV_PATH    = $(BUILD_DIR)/libuv
UV_LIB     = $(UV_PATH)/out/Debug/libuv.a
define UV_MMAP_STR
module Libuv [system] {
    header "uv.h"
    link "uv"
    export *
}
endef
export UV_MMAP_STR

## COMPILER SETTINGS ##
SWIFT        = swift -frontend -c -color-diagnostics 
SWIFTC       = swiftc
ifeq ($(COMPILE_MODE), Debug)
   CFLAGS    = -Onone -g
else
   CFLAGS    = -O3
endif

TARGET        = Trevi Lime
SOURCE_FILES  = $(shell find $(SRC_DIR) \( -name "*.swift" ! -name "AppDelegate.swift" ! -name "ViewController.swift" \))

## BUILD TARGETS ##
all: clean setup $(TARGET) build

setup:
	$(shell mkdir -p $(BUILD_DIR))
	$(shell mkdir -p $(PLATFORM_BUILD_DIR))
	$(shell mkdir -p $(PLATFORM_LIB_DIR))
	$(shell mkdir -p $(PLATFORM_OBJ_DIR))
	$(shell mkdir -p $(PLATFORM_TEMP_DIR))

$(UV_LIB):
	@echo "\n\033[1;33m>>> Download Libuv & Make\033[0m"
	git clone "https://github.com/libuv/libuv.git" $(UV_PATH) && \
		test -d $(UV_PATH)/build/gyp || \
			(mkdir -p ./build && git clone https://chromium.googlesource.com/external/gyp.git $(UV_PATH)/build/gyp) && \
		cd $(UV_PATH) && \
		./gyp_uv.py -f make && \
		$(MAKE) -C ./out && \
		cp "$(UV_LIB)" $(PLATFORM_LIB_DIR) && \
		cp $(UV_PATH)/include/uv*.h $(PLATFORM_LIB_DIR) && \
		echo "$$UV_MMAP_STR" > $(PLATFORM_LIB_DIR)/module.modulemap
	@echo "\n\033[1;33m<<<\033[0m\n"

$(TARGET): .PHONY $(UV_LIB)
	@echo "\n\033[1;33m>>> Framework : $@ \033[0m"
	$(SWIFTC) $(CFLAGS) \
		-emit-library \
		-o $(PLATFORM_LIB_DIR)/lib$@.dylib \
		-Xlinker -install_name -Xlinker @rpath/../lib/lib$@.dylib \
		-emit-module \
		-emit-module-path $(PLATFORM_LIB_DIR)/$@.swiftmodule \
		-module-name $@ \
		-module-link-name $@ \
		-I$(PLATFORM_LIB_DIR) \
		-L$(PLATFORM_LIB_DIR) \
		-v \
		$(shell find '$(ROOT_DIR)/$@' -name '*.swift')
	@echo "\n\033[1;33m<<<\033[0m\n"

build: .PHONY
	@echo "\n\033[1;33m>>> Build user source codes\033[0m"
	$(SWIFTC) $(CFLAGS) $(SOURCE_FILES) \
		-o $(PLATFORM_BUILD_DIR)/$(PROJECT_NAME) \
		-Xlinker -rpath \
		-Xlinker @executable_path/../lib \
		-I$(PLATFORM_LIB_DIR) \
		-L$(PLATFORM_LIB_DIR) \
		-v
	@echo "\n\033[1;33m<<<\033[0m\n"
	@echo "\033[1;33mBuild complete!\033[0m"
	@echo "\033[1;33mAn executable is created on \"\033[1;36m$(PLATFORM_BUILD_DIR)/$(PROJECT_NAME)\033[1;33m\"!\033[0m\n"

clean:
	@echo "\n\033[1;33m>>> Clean\033[0m"
	rm -rf $(BUILD_DIR)
	@echo "\n\033[1;33m<<<\033[0m\n"

.PHONY: