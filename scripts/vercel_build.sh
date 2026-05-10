#!/usr/bin/env bash
# Installs Flutter SDK on Vercel (Linux) if missing, then builds Flutter Web.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SDK_DIR="$ROOT/.flutter-sdk"
FLUTTER_BRANCH="${FLUTTER_BRANCH:-stable}"

if [[ ! -x "$SDK_DIR/bin/flutter" ]]; then
  rm -rf "$SDK_DIR"
  git clone https://github.com/flutter/flutter.git -b "$FLUTTER_BRANCH" --depth 1 "$SDK_DIR"
fi

export PATH="$SDK_DIR/bin:$PATH"

flutter --version
flutter config --no-analytics
flutter precache --web
flutter pub get
flutter build web --release
