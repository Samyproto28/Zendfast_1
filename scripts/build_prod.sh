#!/bin/bash
# Production Build Script for Zendfast
# Builds production flavor with environment-specific configuration

set -e  # Exit on error

echo "======================================"
echo "Building Zendfast (PRODUCTION)"
echo "======================================"

# Load environment variables from .env.production if it exists
if [ -f .env.production ]; then
    export $(cat .env.production | grep -v '^#' | xargs)
    echo "✅ Loaded environment variables from .env.production"
else
    echo "❌ .env.production not found!"
    echo "   Production builds require .env.production file"
    exit 1
fi

# Check for required environment variables
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ] || [ -z "$ONESIGNAL_APP_ID" ] || [ -z "$SUPERWALL_API_KEY" ]; then
    echo "❌ Missing required environment variables!"
    echo "   Please ensure SUPABASE_URL, SUPABASE_ANON_KEY, ONESIGNAL_APP_ID, and SUPERWALL_API_KEY are set"
    exit 1
fi

# Build arguments
BUILD_TYPE="${1:-appbundle}"  # apk, appbundle, or ios (default: appbundle for production)
DART_DEFINES="--dart-define=ENV=production \
--dart-define=SUPABASE_URL=$SUPABASE_URL \
--dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
--dart-define=ONESIGNAL_APP_ID=$ONESIGNAL_APP_ID \
--dart-define=SUPERWALL_API_KEY=$SUPERWALL_API_KEY"

echo ""
echo "Configuration:"
echo "  Environment: production"
echo "  Build Type: $BUILD_TYPE"
echo "  Supabase URL: ${SUPABASE_URL:0:30}..."
echo "  OneSignal App ID: ${ONESIGNAL_APP_ID:0:20}..."
echo ""
echo "⚠️  PRODUCTION BUILD - Ensure all credentials are correct!"
echo ""

case $BUILD_TYPE in
    apk)
        echo "🔨 Building Android APK (production)..."
        flutter build apk --flavor production $DART_DEFINES
        echo ""
        echo "✅ Build complete!"
        echo "📦 APK location: build/app/outputs/flutter-apk/app-production-release.apk"
        ;;
    appbundle)
        echo "🔨 Building Android App Bundle (production)..."
        flutter build appbundle --flavor production $DART_DEFINES
        echo ""
        echo "✅ Build complete!"
        echo "📦 AAB location: build/app/outputs/bundle/productionRelease/app-production-release.aab"
        echo ""
        echo "📝 Next steps:"
        echo "   1. Upload AAB to Google Play Console"
        echo "   2. Test on internal testing track first"
        echo "   3. Roll out to production when ready"
        ;;
    ios)
        echo "🔨 Building iOS (production)..."
        flutter build ios --flavor production $DART_DEFINES --release
        echo ""
        echo "✅ Build complete!"
        echo "📦 Build location: build/ios/iphoneos/Runner.app"
        echo ""
        echo "📝 Next steps:"
        echo "   1. Open ios/Runner.xcworkspace in Xcode"
        echo "   2. Select 'Production' scheme"
        echo "   3. Archive and upload to App Store Connect"
        ;;
    run)
        echo "⚠️  WARNING: Running production build locally"
        echo "   This will connect to PRODUCTION services!"
        read -p "Continue? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            flutter run --flavor production $DART_DEFINES --release
        else
            echo "Cancelled."
            exit 0
        fi
        ;;
    *)
        echo "❌ Invalid build type: $BUILD_TYPE"
        echo "   Usage: ./scripts/build_prod.sh [apk|appbundle|ios|run]"
        exit 1
        ;;
esac

echo ""
echo "======================================"
echo "Production Build Complete! 🎉"
echo "======================================"
