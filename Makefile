# Swift command
SWIFT = swift

# Project name (change this to match your package name)
PROJECT_NAME = App

EXECUTABLE_NAME = mock-telegram

# Build configuration
BUILD_CONFIG = release

# Output directory (change this to your desired output folder)
OUT_DIR = ../executables

# Get system architecture and OS
ARCH := $(shell uname -m)
OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')

# Set Swift build flags
SWIFT_BUILD_FLAGS = -c $(BUILD_CONFIG)

# Add Linux-specific flags
ifeq ($(OS),linux)
    SWIFT_BUILD_FLAGS += --static-swift-stdlib -Xlinker -ljemalloc
endif

# Default target
all: build install

# Build the project
build:
	$(SWIFT) build $(SWIFT_BUILD_FLAGS)
	@mkdir -p $(OUT_DIR)
	@echo "Copying $(PROJECT_NAME) to $(OUT_DIR) with architecture-specific name"
	@cp -f .build/$(BUILD_CONFIG)/$(PROJECT_NAME) $(OUT_DIR)/$(EXECUTABLE_NAME)-$(OS)-$(ARCH)
	@echo "Built $(EXECUTABLE_NAME)-$(OS)-$(ARCH)"

# Special command for building Linux x86_64 with MUSL
build-linux-64:
	$(SWIFT) build --swift-sdk x86_64-swift-linux-musl -c $(BUILD_CONFIG)
	@echo "Built $(EXECUTABLE_NAME)-linux-x86_64-musl"
	@mkdir -p $(OUT_DIR)
	@cp -f .build/$(BUILD_CONFIG)/$(PROJECT_NAME) $(OUT_DIR)/$(EXECUTABLE_NAME)-linux-x86_64-musl
	@echo "Copying $(PROJECT_NAME) to $(OUT_DIR) with architecture-specific name"

# Install (copy) the executable to the output directory without architecture-specific name
install:
	$(SWIFT) build $(SWIFT_BUILD_FLAGS)
	@mkdir -p $(OUT_DIR)
	@echo "Copying $(PROJECT_NAME) to $(OUT_DIR)"
	@cp -f .build/$(BUILD_CONFIG)/$(PROJECT_NAME) $(OUT_DIR)/$(EXECUTABLE_NAME)
	@echo "Installed $(EXECUTABLE_NAME) to $(OUT_DIR)"

# Clean build artifacts
clean:
	$(SWIFT) package clean
	rm -rf .build

# Phony targets
.PHONY: all build install clean build-linux-64