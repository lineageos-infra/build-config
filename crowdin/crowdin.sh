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

if [ -z "$REPO_VERSION" ]; then
  export REPO_VERSION=v2.28
fi

cd $(dirname $0)
SCRIPT_DIR=`pwd`

echo "--- Syncing"

mkdir -p /lineage/${VERSION}/.repo/local_manifests
cd /lineage/${VERSION}
rm -rf .repo/local_manifests/*
cp lineage/crowdin/config/${VERSION}_extra_packages.xml .repo/local_manifests
if [ -f /lineage/setup.sh ]; then
    source /lineage/setup.sh
fi
# catch SIGPIPE from yes
yes | repo init -u https://github.com/lineageos/android.git -b ${VERSION} -g default,-darwin --repo-rev=${REPO_VERSION} || if [[ $? -eq 141 ]]; then true; else false; fi
repo version

echo "Syncing"
repo sync --detach --current-branch --no-tags --force-remove-dirty --force-sync -j32 > /tmp/android-sync.log 2>&1
. build/envsetup.sh


echo "--- clobber"
rm -rf out

# TODO(forkbomb): Modify the crowdin tool so we don't have to change this every time we change branch.
export LINEAGE_CROWDIN_BASE_PATH_LINEAGE_17_1=/lineage/lineage-17.1
export LINEAGE_CROWDIN_BASE_PATH_LINEAGE_18_1=/lineage/lineage-18.1
export LINEAGE_CROWDIN_BASE_PATH_LINEAGE_19_1=/lineage/lineage-19.1
export LINEAGE_CROWDIN_BASE_PATH_LINEAGE_20_0=/lineage/lineage-20.0
cd lineage/crowdin

echo "--- setup python environment for translation sync"

source /lineage/crowdin.sh

pip3 install --user -r requirements.txt

echo "--- download new translations"
cd /lineage/${VERSION}
./lineage/crowdin/crowdin_sync.py --username c3po --branch $VERSION --download -p "$SCRIPT_DIR/crowdin-cli.sh"
STATUS=$?

if [[ $STATUS -eq 2 ]]; then
	echo "No new translations, not running build."
	exit
elif [[ $STATUS -ne 0 ]]; then
	echo "Crowdin sync failed, failing build."
	exit $STATUS
fi

echo "--- breakfast"
breakfast lineage_bonito-userdebug

if [[ "$TARGET_PRODUCT" != lineage_* ]]; then
    echo "Breakfast failed, exiting"
    # TODO(forkbomb): Abandon or -1 changes if stuff is broken.
    exit 1
fi

echo "--- Building"
mka otatools-package target-files-package dist | tee /tmp/android-build.log || exit 1
# TODO(forkbomb): Abandon or -1 changes if stuff is broken.

echo "--- Submitting translations"
./lineage/crowdin/crowdin_sync.py --username c3po --branch $VERSION -s -o c3po
echo "Successful"

echo "--- cleanup"
rm -rf out
