#!/bin/bash

set -eu
echo "--- Uploading logs on error"
echo "failures/${DEVICE}/${BUILD_UUID}/"
ssh jenkins@blob.lineageos.org mkdir -p /home/jenkins/incoming/failures/${DEVICE}/${BUILD_UUID}/
scp /tmp/android-sync.log jenkins@blob.lineageos.org:/home/jenkins/incoming/failures/${DEVICE}/${BUILD_UUID}/
scp /tmp/android-build.log jenkins@blob.lineageos.org:/home/jenkins/incoming/failures/${DEVICE}/${BUILD_UUID}/
