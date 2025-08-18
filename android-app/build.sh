#!/bin/bash
set -e

echo "--- Install dependencies"
apk add go zip
go install github.com/ensody/androidmanifest-changer@834db42cf83608f43cfbd72870d69b56fcd07fe1

echo "--- Build"
git clone -b "${BRANCH}" "https://github.com/LineageOS/${REPO}" src
cd src
./gradlew assembleRelease

echo "--- Update apk package name and version code"
PACKAGE_NAME=`aapt2 dump badging "${APK_PATH}" | grep ^package: | awk '{print $2}' | cut -b7- | rev | cut -c 2- | rev`
PACKAGE_NAME="${PACKAGE_NAME}.fdroid"
VERSION_CODE=`TZ=UTC date +%s`

~/go/bin/androidmanifest-changer --package "${PACKAGE_NAME}" --versionCode "${VERSION_CODE}" "${APK_PATH}"
