#!/bin/bash

set -eu
ssh jenkins@blob.lineageos.org mkdir -p /home/jenkins/incoming/${DEVICE}/${BUILD_UUID}/
scp /tmp/android-reset.log jenkins@blob.lineageos.org:/home/jenkins/incoming/failures/${DEVICE}/${BUILD_UUID}/
scp /tmp/android-sync.log jenkins@blob.lineageos.org:/home/jenkins/incoming/failures/${DEVICE}/${BUILD_UUID}/
scp /tmp/android-build.log jenkins@blob.lineageos.org:/home/jenkins/incoming/failures/${DEVICE}/${BUILD_UUID}/
