#!/usr/bin/env bash
# Release build for Android: per-ABI and universal APKs into dist/.
# Signing: android/key.properties (see README); without it the release APKs
# are signed with the debug key.
#
#   bash scripts/build_android.sh
set -euo pipefail
cd "$(dirname "$0")/.."

version=$(sed -n 's/^version:[[:space:]]*//p' pubspec.yaml | head -n1)
name=${version%%+*}
build=${version#*+}
[ "$build" = "$version" ] && build=1
echo "Prism Browser $name ($build)"

[ -f android/key.properties ] || echo "warning: android/key.properties not found, using the debug key" >&2

flutter build apk --release --split-per-abi --build-name="$name" --build-number="$build"
flutter build apk --release --build-name="$name" --build-number="$build"

mkdir -p dist
out=build/app/outputs/flutter-apk
cp "$out/app-arm64-v8a-release.apk" "dist/PrismBrowser-$name-android-arm64-v8a.apk"
cp "$out/app-armeabi-v7a-release.apk" "dist/PrismBrowser-$name-android-armeabi-v7a.apk"
cp "$out/app-x86_64-release.apk" "dist/PrismBrowser-$name-android-x86_64.apk"
cp "$out/app-release.apk" "dist/PrismBrowser-$name-android-universal.apk"
ls -lh dist/*.apk
