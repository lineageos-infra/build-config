#!/bin/bash

set -eu
echo "--- Uploading logs on error"
echo "failures/${DEVICE}/${BUILD_UUID}/"
s3cmd put /tmp/android-sync.log s3://lineageos-blob/failures/${DEVICE}/${BUILD_UUID}_sync.log
s3cmd put /tmp/android-build.log s3://lineageos-blob/failures/${DEVICE}/${BUILD_UUID}_build.log
