#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EXTERNAL_DIR="$REPO_ROOT/external/llama.cpp"
BUILD_DIR="$REPO_ROOT/build/llama-ios"

echo "This script bootstraps the llama.cpp submodule and provides a starting point to build for iOS."

echo "1) Initialize submodule (if not already initialized)"
git submodule update --init --recursive --quiet

if [ ! -d "$EXTERNAL_DIR" ]; then
  echo "ERROR: submodule directory not found: $EXTERNAL_DIR"
  exit 1
fi

mkdir -p "$BUILD_DIR"
cd "$EXTERNAL_DIR"

cat <<'INFO'

Build notes:
- llama.cpp does not ship an official iOS universal binary. This script only outlines recommended steps.
- Common approaches:
  * Use the provided Makefile with an iOS toolchain (community-maintained), or
  * Use CMake with an iOS toolchain file to cross-compile a static library, then lipo into a fat binary.

Suggested workflow (manual steps you can follow):
  1. Open a macOS terminal and run this script from repo root:
       ./scripts/build-llama-ios.sh

  2. Inside external/llama.cpp, try a platform build (examples exist in community forks). If compilation fails, you may need to adapt the Makefile or use a CMake toolchain.

  3. Produce libllama.a (static) for arm64 (device) and x86_64/arm64-simulator (simulator) and combine with lipo into a universal / XCFramework.

Example (pseudo-commands):
  # for device (arm64)
  make clean && make -j8 PLATFORM=ios ARCH=arm64

  # for simulator (x86_64 / arm64)
  make clean && make -j8 PLATFORM=iossim ARCH=x86_64

  # then lipo them
  lipo -create -output libllama_universal.a path/to/device/libllama.a path/to/simulator/libllama.a

INFO

# Placeholders: you must adapt the commands above to the specific fork/build scripts you use.

echo "Done. See the notes above; adapt the build steps for your environment. After building, link the produced static lib into the Xcode target and add header search paths to external/llama.cpp/include."
