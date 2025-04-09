#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo ">>> Installing Dependencies..."
apt-get update && apt-get install -y curl xz-utils git # Ensure git is installed

echo ">>> Downloading Flutter SDK 3.29.2..."
curl -L -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.2-stable.tar.xz

echo ">>> Extracting Flutter SDK..."
mkdir /flutter
tar xf flutter.tar.xz -C /
rm flutter.tar.xz

echo ">>> Setting Flutter Path..."
export PATH="$PATH:/flutter/bin"

echo ">>> Configuring Git Safe Directory..."
git config --global --add safe.directory /flutter

echo ">>> Enabling Flutter Web..."
flutter config --enable-web

echo ">>> Getting Flutter Dependencies..."
flutter pub get

echo ">>> Building Flutter Web..."
flutter build web --release

echo ">>> Build Script Completed."