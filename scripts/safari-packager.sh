#!/usr/bin/env bash
set -e

# ==============================================================================
# safari-packager.sh
# Automated packager and converter script for Apple Safari Web Extensions.
# ==============================================================================

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHROME_BUILD_DIR="$PROJECT_DIR/build/chrome-mv3-prod"
SAFARI_BUILD_DIR="$PROJECT_DIR/build/safari-mv3-prod"
APP_NAME="Local Web Analytics"
BUNDLE_ID="com.yourdomain.local-web-analytics"

echo "=========================================================="
echo "🍎 Safari Web Extension Packager Workflow"
echo "=========================================================="

# 1. Ensure build exists
if [ ! -d "$SAFARI_BUILD_DIR" ]; then
    echo "📦 Building extension for Safari MV3 target..."
    bun run build:safari
fi

# 2. Check for xcrun safari converter / packager
CONVERTER_TOOL=""
if xcrun --find safari-web-extension-converter >/dev/null 2>&1; then
    CONVERTER_TOOL="safari-web-extension-converter"
elif xcrun --find safari-web-extension-packager >/dev/null 2>&1; then
    CONVERTER_TOOL="safari-web-extension-packager"
fi

if [ -n "$CONVERTER_TOOL" ]; then
    echo "✓ Found Apple tool: $CONVERTER_TOOL"
    echo "Packaging Safari extension wrapper into $PROJECT_DIR/safari..."
    xcrun "$CONVERTER_TOOL" "$SAFARI_BUILD_DIR" \
        --app-name "$APP_NAME" \
        --bundle-identifier "$BUNDLE_ID" \
        --swift \
        --force \
        --project-location "$PROJECT_DIR/safari-generated"
    echo "✓ Apple converter completed."
else
    echo "ℹ Note: 'safari-web-extension-converter' requires full Xcode.app."
    echo "  Current developer dir: $(xcode-select -p 2>/dev/null || echo 'none')"
    echo "  Pre-configured native Xcode project is ready in: $PROJECT_DIR/safari"
    echo "  Extension resources synced in: $PROJECT_DIR/safari/Shared (Extension)/Resources"
    echo ""
    echo "To build from terminal with xcodebuild (once Xcode is installed):"
    echo "  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    echo "  xcodebuild -project \"$PROJECT_DIR/safari/Local Web Analytics.xcodeproj\" -scheme \"Local Web Analytics (macOS)\""
fi

echo "=========================================================="
