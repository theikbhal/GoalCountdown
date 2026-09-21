#!/bin/bash
set -e

APP_NAME="GoalCountdown"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "🔨 Building $APP_NAME..."

# Clean
rm -rf "$BUILD_DIR"

# Create app bundle structure
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Build with Swift
swift build -c release --package-path . 2>/dev/null || {
    echo "📦 Trying debug build..."
    swift build --package-path .
}

# Find the built binary
BINARY_PATH=$(find .build -name "$APP_NAME" -type f 2>/dev/null | head -1)

if [ -z "$BINARY_PATH" ]; then
    echo "❌ Build failed. Trying alternative build..."
    swiftc -o "$MACOS_DIR/$APP_NAME" \
        Sources/GoalCountdown/*.swift \
        Sources/GoalCountdown/**/*.swift \
        -framework SwiftUI \
        -framework Foundation \
        -target arm64-apple-macosx13.0
else
    cp "$BINARY_PATH" "$MACOS_DIR/$APP_NAME"
fi

# Copy Info.plist
cp Resources/Info.plist "$CONTENTS_DIR/Info.plist"

# Copy icon if exists
if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

echo "✅ Build complete: $APP_BUNDLE"
echo "📦 Bundle size: $(du -sh "$APP_BUNDLE" | cut -f1)"
