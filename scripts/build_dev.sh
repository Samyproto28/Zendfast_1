#!/bin/bash
# Development Build Script for Zendfast
# Builds development flavor with environment-specific configuration

set -e  # Exit on error

echo "======================================"
echo "Building Zendfast (DEVELOPMENT)"
echo "======================================"

# Load environment variables from .env.development if it exists
if [ -f .env.development ]; then
    export $(cat .env.development | grep -v '^#' | xargs)
    echo "✅ Loaded environment variables from .env.development"
else
    echo "⚠️  .env.development not found, using .env fallback"
fi

# Check for required environment variables
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ] || [ -z "$ONESIGNAL_APP_ID" ] || [ -z "$SUPERWALL_API_KEY" ]; then
    echo "❌ Missing required environment variables!"
    echo "   Please ensure SUPABASE_URL, SUPABASE_ANON_KEY, ONESIGNAL_APP_ID, and SUPERWALL_API_KEY are set"
    exit 1
fi

# Build arguments
BUILD_TYPE="${1:-apk}"  # apk, appbundle, or ios (default: apk)
DART_DEFINES="--dart-define=ENV=development \
--dart-define=SUPABASE_URL=$SUPABASE_URL \
--dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
--dart-define=ONESIGNAL_APP_ID=$ONESIGNAL_APP_ID \
--dart-define=SUPERWALL_API_KEY=$SUPERWALL_API_KEY"

echo ""
echo "Configuration:"
echo "  Environment: development"
echo "  Build Type: $BUILD_TYPE"
echo "  Supabase URL: ${SUPABASE_URL:0:30}..."
echo "  OneSignal App ID: ${ONESIGNAL_APP_ID:0:20}..."
echo ""

case $BUILD_TYPE in
    apk)
        echo "🔨 Building Android APK (development)..."
        flutter build apk --flavor development $DART_DEFINES
        echo ""
        echo "✅ Build complete!"
        echo "📦 APK location: build/app/outputs/flutter-apk/app-development-release.apk"
        ;;
    appbundle)
        echo "🔨 Building Android App Bundle (development)..."
        flutter build appbundle --flavor development $DART_DEFINES
        echo ""
        echo "✅ Build complete!"
        echo "📦 AAB location: build/app/outputs/bundle/developmentRelease/app-development-release.aab"
        ;;
    ios)
        echo "🔨 Building iOS (development)..."
        flutter build ios --flavor development $DART_DEFINES --no-codesign
        echo ""
        echo "✅ Build complete!"
        echo "📦 Build location: build/ios/iphoneos/Runner.app"
        ;;
    run)
        echo "🚀 Running app (development)..."
        flutter run --flavor development $DART_DEFINES
        ;;
    *)
        echo "❌ Invalid build type: $BUILD_TYPE"
        echo "   Usage: ./scripts/build_dev.sh [apk|appbundle|ios|run]"
        exit 1
        ;;
esac

echo ""
echo "======================================"
echo "Development Build Complete! 🎉"
echo "======================================"
