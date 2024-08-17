# Swift command
SWIFT = swift

# Project name (change this to match your package name)
PROJECT_NAME = App

EXECUTABLE_NAME = mock-telegram

# Build configuration
BUILD_CONFIG = release

# Output directory (change this to your desired output folder)
OUT_DIR = ../executables

# Default target
all: build install

# Build the project
build:
	$(SWIFT) build -c $(BUILD_CONFIG)

# Install (copy) the executable to the output directory
install: build
	@mkdir -p $(OUT_DIR)
	@echo "Copying $(PROJECT_NAME) to $(OUT_DIR)"
	@cp -f .build/$(BUILD_CONFIG)/$(PROJECT_NAME) $(OUT_DIR)/$(EXECUTABLE_NAME)
	@echo "Installed $(PROJECT_NAME) to $(OUT_DIR)"

# Clean build artifacts
clean:
	$(SWIFT) package clean
	rm -rf .build

# Phony targets
.PHONY: all build install clean