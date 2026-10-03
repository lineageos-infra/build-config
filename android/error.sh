#!/bin/bash

set -eu
echo "--- Uploading logs on error"
echo "failures/${DEVICE}/${BUILD_UUID}/"
s3cmd --no-check-md5 put /tmp/android-sync.log s3://blob.lineageos.org/failures/${DEVICE}/${BUILD_UUID}_sync.log
s3cmd --no-check-md5 put /tmp/android-build.log s3://blob.lineageos.org/failures/${DEVICE}/${BUILD_UUID}_build.log
