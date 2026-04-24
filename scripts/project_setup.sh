#!/usr/bin/env bash
# Benaiah — one-shot development environment setup (FVM + Flutter + iOS pods + Mason).
# Run from anywhere:  bash scripts/project_setup.sh
# Non-interactive (CI):  FVM_SETUP_NONINTERACTIVE=1 bash scripts/project_setup.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Ensure pub global binaries (fvm, mason, fluttergen) resolve consistently
export PATH="${HOME}/.pub-cache/bin:${PATH}"

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
NC=$'\033[0m'

die() {
  echo "${RED}Error:${NC} $*" >&2
  exit 1
}

info() { echo "${BLUE}▸${NC} $*"; }
warn() { echo "${YELLOW}▸${NC} $*" >&2; }
ok() { echo "${GREEN}✓${NC} $*"; }

detect_sdk_manager() {
  if command -v puro &>/dev/null; then
    echo "puro"
  elif command -v fvm &>/dev/null; then
    echo "fvm"
  else
    echo "none"
  fi
}

resolve_fvm_bin() {
  if command -v fvm &>/dev/null; then
    echo "fvm"
    return 0
  fi
  local pub_fvm="${HOME}/.pub-cache/bin/fvm"
  if [[ -x "${pub_fvm}" ]]; then
    echo "${pub_fvm}"
    return 0
  fi
  return 1
}

install_fvm_pub_global() {
  command -v dart &>/dev/null || die "Dart SDK not found. Install Flutter/Dart first, then re-run this script."
  info "Installing FVM via dart pub global activate..."
  dart pub global activate fvm
}

ensure_fvm() {
  if FVM_BIN="$(resolve_fvm_bin)"; then
    export FVM_BIN
    ok "FVM found (${FVM_BIN})"
    return 0
  fi

  warn "FVM is not installed. Installing automatically..."

  if command -v brew &>/dev/null; then
    info "Installing FVM via Homebrew..."
    brew install fvm || {
      warn "Homebrew install failed, falling back to dart pub global..."
      install_fvm_pub_global || die "Could not install FVM. Install manually: https://fvm.app"
    }
  else
    install_fvm_pub_global || die "Could not install FVM. Install manually: https://fvm.app"
  fi

  hash -r 2>/dev/null || true
  export PATH="${HOME}/.pub-cache/bin:${PATH}"

  if ! FVM_BIN="$(resolve_fvm_bin)"; then
    die "FVM still not found. Add ${HOME}/.pub-cache/bin to PATH and open a new shell."
  fi
  export FVM_BIN
  ok "FVM installed (${FVM_BIN})"
}

require_fvm_config() {
  if [[ ! -f "${ROOT_DIR}/.fvm/fvm_config.json" ]] && [[ ! -f "${ROOT_DIR}/.fvmrc" ]]; then
    die "Missing .fvm/fvm_config.json or .fvmrc. Pin a Flutter version with: fvm use <version>"
  fi
}

main() {
  echo "====================================================="
  echo "||                                                 ||"
  echo "||          Welcome to Benaiah App                 ||"
  echo "||                                                 ||"
  echo "||  Please wait while we setup everything for you  ||"
  echo "||                                                 ||"
  echo "====================================================="
  echo ""

  SDK_MANAGER=$(detect_sdk_manager)
  
  if [[ "$SDK_MANAGER" == "puro" ]]; then
    info "Puro detected. Using puro for Flutter/Dart commands."
    FLUTTER_CMD=(puro flutter)
    DART_CMD=(puro dart)
    puro install
  elif [[ "$SDK_MANAGER" == "fvm" ]]; then
    info "FVM detected. Using fvm for Flutter/Dart commands."
    ensure_fvm
    require_fvm_config
    "${FVM_BIN}" install
    FLUTTER_CMD=("${FVM_BIN}" flutter)
    DART_CMD=("${FVM_BIN}" dart)
    # Add FVM flutter/dart to PATH for global tools
    export PATH="${ROOT_DIR}/.fvm/flutter_sdk/bin:${PATH}"
  else
    warn "No SDK manager (FVM/Puro) found. Using global flutter/dart."
    FLUTTER_CMD=(flutter)
    DART_CMD=(dart)
  fi

  info "Flutter / Dart versions:"
  "${FLUTTER_CMD[@]}" --version | head -3
  echo ""

  info "Running flutter doctor..."
  "${FLUTTER_CMD[@]}" doctor || warn "flutter doctor reported issues; fix any blockers above before building."

  echo ""
  info "Fetching Dart / Flutter packages..."
  "${FLUTTER_CMD[@]}" pub get
  ok "pub get complete"

  if [[ "$(uname -s)" == "Darwin" ]] && [[ -f ios/Podfile ]]; then
    if command -v pod &>/dev/null; then
      info "Precaching iOS artifacts..."
      "${FLUTTER_CMD[@]}" precache --ios
      info "Installing CocoaPods dependencies (iOS)..."
      if (cd ios && pod install --repo-update); then
        ok "pod install complete"
      else
        warn "pod install failed — fix CocoaPods, then run: (cd ios && pod install --repo-update)"
      fi
    else
      warn "CocoaPods (pod) not found — skip ios/pod install. Install with: sudo gem install cocoapods"
    fi
  fi

  echo ""
  info "Activating Mason CLI (project bricks)..."
  "${DART_CMD[@]}" pub global activate mason_cli
  if command -v mason &>/dev/null; then
    info "Running mason get..."
    mason get
    ok "mason get complete"
  else
    warn "mason not on PATH — run: export PATH=\"\${HOME}/.pub-cache/bin:\${PATH}\""
  fi

  echo ""
  info "Optional: FlutterGen CLI (used by scripts/Makefile gen target)..."
  if "${DART_CMD[@]}" pub global run flutter_gen:flutter_gen_command --version &>/dev/null; then
    ok "FlutterGen CLI already available"
  else
    "${DART_CMD[@]}" pub global activate flutter_gen || warn "Could not activate flutter_gen globally (gen may still work if already installed)."
  fi

  echo ""
  info "Configuring VS Code launch configurations..."
  mkdir -p .vscode
  cat > .vscode/launch.json <<EOF
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Benaiah [DEV]",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--flavor", "dev"]
    },
    {
      "name": "Benaiah [QA]",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--flavor", "qa"]
    },
    {
      "name": "Benaiah [PROD]",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--flavor", "prod"]
    }
  ]
}
EOF
  ok "VS Code launch configurations generated (default: DEV)"

  echo ""
  echo "====================================================="
  echo "||                                                 ||"
  echo "||       Everything is set up and ready to go!     ||"
  echo "||                                                 ||"
  echo "||  Use your preferred SDK manager (FVM/Puro) or:  ||"
  echo "||    make run-dev                                 ||"
  echo "||                                                 ||"
  echo "||  VS Code: Select 'Benaiah [DEV]' from Run/Debug ||"
  echo "||                                                 ||"
  echo "||                ~Happy Coding~                   ||"
  echo "||                                                 ||"
  echo "====================================================="
}

main "$@"
