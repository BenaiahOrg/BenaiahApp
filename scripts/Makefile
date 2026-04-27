.PHONY: help clean get test build-dev build-qa build-prod build-all bundle-dev bundle-qa bundle-prod bundle-all install-dev install-qa install-prod run-dev run-qa run-prod gen assets

# Project root (one level up from scripts/)
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/..

# All Flutter/Dart commands go through FVM (pinned SDK in .fvm/ / .fvmrc).
# Widen PATH so `make` finds fvm when invoked from IDEs or CI with a minimal environment.
export PATH := $(HOME)/.pub-cache/bin:/opt/homebrew/bin:/usr/local/bin:$(PATH)

# Detect SDK Manager (Puro > FVM > Global)
PURO := $(shell command -v puro 2>/dev/null)
FVM := $(shell command -v fvm 2>/dev/null)

ifneq ($(PURO),)
FLUTTER := puro flutter
DART := puro dart
$(info ▸ Using Puro for Flutter/Dart)
else ifneq ($(FVM),)
FLUTTER := fvm flutter
DART := fvm dart
$(info ▸ Using FVM for Flutter/Dart)
else
FLUTTER := flutter
DART := dart
$(info ▸ Using Global Flutter/Dart)
endif

FLUTTERGEN := $(DART) pub global run flutter_gen:flutter_gen_command

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

clean: ## Clean build artifacts
	cd $(ROOT_DIR) && $(FLUTTER) clean

get: ## Get dependencies
	cd $(ROOT_DIR) && $(FLUTTER) pub get

test: ## Run unit/widget tests
	cd $(ROOT_DIR) && $(FLUTTER) test

# --- APK Builds ---

build-dev: ## Build APK for dev flavor
	cd $(ROOT_DIR) && $(FLUTTER) build apk --flavor dev -t lib/main.dart

build-qa: ## Build APK for qa flavor
	cd $(ROOT_DIR) && $(FLUTTER) build apk --flavor qa -t lib/main.dart

build-prod: ## Build APK for prod flavor
	cd $(ROOT_DIR) && $(FLUTTER) build apk --flavor prod -t lib/main.dart

build-all: build-dev build-qa build-prod ## Build APKs for all flavors

# --- App Bundles (AAB) ---

bundle-dev: ## Build AAB for dev flavor
	cd $(ROOT_DIR) && $(FLUTTER) build appbundle --flavor dev -t lib/main.dart

bundle-qa: ## Build AAB for qa flavor
	cd $(ROOT_DIR) && $(FLUTTER) build appbundle --flavor qa -t lib/main.dart

bundle-prod: ## Build AAB for prod flavor
	cd $(ROOT_DIR) && $(FLUTTER) build appbundle --flavor prod -t lib/main.dart

bundle-all: bundle-dev bundle-qa bundle-prod ## Build AABs for all flavors

# --- Install & Run ---

install-dev: ## Install dev APK on connected device
	cd $(ROOT_DIR) && $(FLUTTER) install --flavor dev -t lib/main.dart

install-qa: ## Install qa APK on connected device
	cd $(ROOT_DIR) && $(FLUTTER) install --flavor qa -t lib/main.dart

install-prod: ## Install prod APK on connected device
	cd $(ROOT_DIR) && $(FLUTTER) install --flavor prod -t lib/main.dart

run-dev: ## Run dev flavor
	cd $(ROOT_DIR) && $(FLUTTER) run --flavor dev -t lib/main.dart

run-qa: ## Run qa flavor
	cd $(ROOT_DIR) && $(FLUTTER) run --flavor qa -t lib/main.dart

run-prod: ## Run prod flavor
	cd $(ROOT_DIR) && $(FLUTTER) run --flavor prod -t lib/main.dart

# --- Code Generation ---

gen: ## Run build_runner + fluttergen (all code generation)
	cd $(ROOT_DIR) && $(DART) run build_runner build --delete-conflicting-outputs && $(FLUTTERGEN)

assets: ## Regenerate asset constants only
	cd $(ROOT_DIR) && $(FLUTTERGEN)