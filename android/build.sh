#!/bin/bash
set -eo pipefail
echo "--- Setup"
rm /tmp/android-*.log || true
export USE_CCACHE="1"
export CCACHE_EXEC=/usr/bin/ccache
ccache -s
export PYTHONDONTWRITEBYTECODE=true
export BUILD_ENFORCE_SELINUX=1
export BUILD_NO=
unset BUILD_NUMBER

if [ "$VERSION" == "lineage-18.1" ] || [ "$VERSION" == "lineage-19.1" ]; then
  export OVERRIDE_TARGET_FLATTEN_APEX=true
fi

#TODO(zif): convert this to a runtime check, grep "sse4_2.*popcnt" /proc/cpuinfo
export CPU_SSE42=false
# Following env is set from build
# VERSION
# DEVICE
# TYPE
# RELEASE_TYPE
# EXP_PICK_CHANGES

if [ -z "$BUILD_UUID" ]; then
  export BUILD_UUID=$(uuidgen)
fi

if [ -z "$REPO_VERSION" ]; then
  export REPO_VERSION=v2.28
fi

if [ -z "$TYPE" ]; then
  export TYPE=userdebug
fi

OFFSET="10000000"
export BUILD_NUMBER=$(($OFFSET + $BUILDKITE_BUILD_NUMBER))

echo "--- Syncing"

mkdir -p /lineage/${VERSION}/.repo/local_manifests
cd /lineage/${VERSION}
rm -rf .repo/local_manifests/*
if [ -f /lineage/setup.sh ]; then
    source /lineage/setup.sh
fi
# catch SIGPIPE from yes
yes | repo init -u https://github.com/lineageos/android.git -b ${VERSION} -g default,-darwin --repo-rev=${REPO_VERSION} --git-lfs || if [[ $? -eq 141 ]]; then true; else false; fi
repo version

echo "Syncing"
repo sync --detach --current-branch --no-tags --force-remove-dirty --force-sync -j32 > /tmp/android-sync.log 2>&1
repo forall -c "git lfs pull"
. build/envsetup.sh


echo "--- clobber"
rm -rf out

echo "--- breakfast"
breakfast lineage_${DEVICE}-${TYPE}

if [[ "$TARGET_PRODUCT" != lineage_* ]]; then
    echo "Breakfast failed, exiting"
    exit 1
fi

if [ "$RELEASE_TYPE" '==' "experimental" ]; then
  if [ -n "$EXP_PICK_CHANGES" ]; then
    repopick $EXP_PICK_CHANGES
  fi
fi
echo "--- Building"
mka otatools-package target-files-package dist | tee /tmp/android-build.log

echo "--- Uploading"
ssh jenkins@blob.lineageos.org rm -rf /home/jenkins/incoming/${DEVICE}/${BUILD_UUID}/
ssh jenkins@blob.lineageos.org mkdir -p /home/jenkins/incoming/${DEVICE}/${BUILD_UUID}/
scp out/dist/*target_files*.zip jenkins@blob.lineageos.org:/home/jenkins/incoming/${DEVICE}/${BUILD_UUID}/
scp out/target/product/${DEVICE}/otatools.zip jenkins@blob.lineageos.org:/home/jenkins/incoming/${DEVICE}/${BUILD_UUID}/
s3cmd --no-check-md5 put out/dist/*target_files*.zip s3://lineageos-blob/${DEVICE}/${BUILD_UUID}/ || true
s3cmd --no-check-md5 put out/target/product/${DEVICE}/otatools.zip s3://lineageos-blob/${DEVICE}/${BUILD_UUID}/ || true

echo "--- cleanup"
rm -rf out
