#!/bin/bash

# Clone Flutter (shallow clone to save time)
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable
fi

# Add Flutter to path
export PATH="$PATH:`pwd`/flutter/bin"

# Enable web
flutter config --enable-web

# Get dependencies
flutter pub get

# Build the project
flutter build web --release
