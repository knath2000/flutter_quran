#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo ">>> Setting Explicit Pub Cache Location..."
export PUB_CACHE="/tmp/.pub-cache"
mkdir -p "$PUB_CACHE" # Ensure the directory exists

echo ">>> Downloading Flutter SDK 3.29.2..." # Reverted version
curl -L -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.2-stable.tar.xz

echo ">>> Extracting Flutter SDK..."
# Use /tmp directory which is usually writable
FLUTTER_DIR="/tmp/flutter-sdk"
mkdir -p "$FLUTTER_DIR"
tar xf flutter.tar.xz -C "$FLUTTER_DIR" --strip-components=1 # Extract directly into the target dir
rm flutter.tar.xz

echo ">>> Setting Flutter Path..."
export PATH="$PATH:$FLUTTER_DIR/bin"

echo ">>> Configuring Git Safe Directory..."
# Assuming git is available in the base image now
git config --global --add safe.directory "$FLUTTER_DIR" || echo "Git config failed, proceeding anyway..."

echo ">>> Enabling Flutter Web..."
flutter config --enable-web

# Let flutter build handle pub get implicitly, using the defined PUB_CACHE
echo ">>> Building Flutter Web..."
flutter build web --release --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY

echo ">>> Build Script Completed."