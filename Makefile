# Swift command
SWIFT = swift

# Project name (change this to match your package name)
PROJECT_NAME = App

EXECUTABLE_NAME = mock-telegram

# Build configuration
BUILD_CONFIG = release

# Output directory (change this to your desired output folder)
OUT_DIR = ../executables

# Get system architecture
ARCH := $(shell uname -m)
OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')

# Default target
all: build install

# Build the project
build:
	$(SWIFT) build -c $(BUILD_CONFIG)
	@mkdir -p $(OUT_DIR)
	@echo "Copying $(PROJECT_NAME) to $(OUT_DIR) with architecture-specific name"
	@cp -f .build/$(BUILD_CONFIG)/$(PROJECT_NAME) $(OUT_DIR)/$(EXECUTABLE_NAME)-$(OS)-$(ARCH)
	@echo "Built $(EXECUTABLE_NAME)-$(OS)-$(ARCH)"

# Install (copy) the executable to the output directory without architecture-specific name
install:
	$(SWIFT) build -c $(BUILD_CONFIG)
	@mkdir -p $(OUT_DIR)
	@echo "Copying $(PROJECT_NAME) to $(OUT_DIR)"
	@cp -f .build/$(BUILD_CONFIG)/$(PROJECT_NAME) $(OUT_DIR)/$(EXECUTABLE_NAME)
	@echo "Installed $(EXECUTABLE_NAME) to $(OUT_DIR)"

# Clean build artifacts
clean:
	$(SWIFT) package clean
	rm -rf .build

# Phony targets
.PHONY: all build install clean