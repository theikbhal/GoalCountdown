#!/bin/bash
set -e

APP_NAME="GoalCountdown"
APP_PATH="build/$APP_NAME.app"
INSTALL_PATH="/Applications/$APP_NAME.app"

echo "🚀 Installing $APP_NAME..."

# Build first
./Scripts/build.sh

# Copy to Applications
if [ -d "$APP_PATH" ]; then
    rm -rf "$INSTALL_PATH"
    cp -R "$APP_PATH" "$INSTALL_PATH"
    echo "✅ Installed to $INSTALL_PATH"
else
    echo "❌ Build not found. Run ./Scripts/build.sh first."
    exit 1
fi

# Create desktop shortcut
DESKTOP_PATH="$HOME/Desktop/$APP_NAME"
ln -sf "$INSTALL_PATH" "$DESKTOP_PATH"
echo "✅ Desktop shortcut created"

# Install LaunchAgent
PLIST_PATH="$HOME/Library/LaunchAgents/com.goalcountdown.plist"
mkdir -p "$HOME/Library/LaunchAgents"

cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.goalcountdown</string>
    <key>ProgramArguments</key>
    <array>
        <string>$INSTALL_PATH/Contents/MacOS/$APP_NAME</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>StandardOutPath</key>
    <string>/tmp/goalcountdown.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/goalcountdown.err</string>
</dict>
</plist>
EOF

echo "✅ LaunchAgent installed (auto-start on login)"

# Open the app
open "$INSTALL_PATH"
echo "🎉 $APP_NAME is now running!"
echo ""
echo "📍 App: $INSTALL_PATH"
echo "🖥️  Desktop: $DESKTOP_PATH"
echo "🔄 Auto-start: Enabled"
