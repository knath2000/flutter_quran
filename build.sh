#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo ">>> Setting Explicit Pub Cache Location..."
export PUB_CACHE="/tmp/.pub-cache"
mkdir -p "$PUB_CACHE" # Ensure the directory exists

# Removed explicit Flutter SDK download and setup.
# Relying on Vercel's default Flutter environment.
# echo ">>> Downloading Flutter SDK 3.29.2..."
# curl -L -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.2-stable.tar.xz
# echo ">>> Extracting Flutter SDK..."
# FLUTTER_DIR="/tmp/flutter-sdk"
# mkdir -p "$FLUTTER_DIR"
# tar xf flutter.tar.xz -C "$FLUTTER_DIR" --strip-components=1
# rm flutter.tar.xz
# echo ">>> Setting Flutter Path..."
# export PATH="$PATH:$FLUTTER_DIR/bin"

echo ">>> Configuring Git Safe Directory..."
# Assuming git is available in the base image now
# Removed git safe.directory config related to specific FLUTTER_DIR
# git config --global --add safe.directory "$FLUTTER_DIR" || echo "Git config failed, proceeding anyway..."

echo ">>> Enabling Flutter Web..."
flutter config --enable-web

# Let flutter build handle pub get implicitly, using the defined PUB_CACHE
echo ">>> Building Flutter Web..."
flutter build web --release --web-renderer html --source-maps --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY

echo ">>> Build Script Completed."