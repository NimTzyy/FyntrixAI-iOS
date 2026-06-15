#!/bin/bash
# Fyntrix AI iOS Build Script
# Run this on macOS: chmod +x build.sh && ./build.sh
set -e

echo "Building Fyntrix AI iOS..."
echo ""

PROJ="FyntrixAI.xcodeproj"
SCHEME="FyntrixAI"

# Clean
xcodebuild -project "$PROJ" -scheme "$SCHEME" clean 2>/dev/null

# Build archive
echo "Archiving..."
xcodebuild -project "$PROJ" \
    -scheme "$SCHEME" \
    -sdk iphoneos \
    -configuration Release \
    -archivePath ./build/FyntrixAI.xcarchive \
    archive \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    DEVELOPMENT_TEAM="" 2>&1

# Create IPA
echo "Creating IPA..."
mkdir -p Payload
cp -r ./build/FyntrixAI.xcarchive/Products/Applications/FyntrixAI.app Payload/
zip -qr FyntrixAI.ipa Payload
rm -rf Payload

IPA_SIZE=$(ls -lh FyntrixAI.ipa | awk '{print $5}')
echo ""
echo "DONE: FyntrixAI.ipa ($IPA_SIZE)"
echo "Location: $(pwd)/FyntrixAI.ipa"
