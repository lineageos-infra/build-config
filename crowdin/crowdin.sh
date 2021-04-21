#!/bin/bash

echo "--- Setup"
export USE_CCACHE="1"
export CCACHE_EXEC=/usr/bin/ccache
export PYTHONDONTWRITEBYTECODE=true
export BUILD_ENFORCE_SELINUX=1
export BUILD_NO=
unset BUILD_NUMBER
export OVERRIDE_TARGET_FLATTEN_APEX=true
#TODO(zif): convert this to a runtime check, grep "sse4_2.*popcnt" /proc/cpuinfo
export CPU_SSE42=false

cd $(dirname $0)
SCRIPT_DIR=`pwd`
cd /lineage/${VERSION}

rm -rf .repo/local_manifests/*
cp lineage/crowdin/config/${VERSION}_extra_packages.xml .repo/local_manifests

if [ -f /lineage/setup.sh ]; then
    source /lineage/setup.sh
fi

yes | repo init -u https://github.com/lineageos/android.git -b ${VERSION}
echo "Resetting build tree"
repo forall -vc "git reset --hard" > /tmp/android-reset.log 2>&1
echo "Syncing"
repo sync -j32 -d --force-sync > /tmp/android-sync.log 2>&1

echo "--- clobber"
rm -rf out

# TODO(forkbomb): Modify the crowdin tool so we don't have to change this every time we change branch.
export LINEAGE_CROWDIN_BASE_PATH_LINEAGE_16_0=/lineage/lineage-16.0
export LINEAGE_CROWDIN_BASE_PATH_LINEAGE_17_1=/lineage/lineage-17.1
export LINEAGE_CROWDIN_BASE_PATH_LINEAGE_18_1=/lineage/lineage-18.1
cd lineage/crowdin

echo "--- setup python environment for translation sync"

source /lineage/crowdin.sh
rm -rf /tmp/venv

# The crowdin script uses fstrings, so we need at least python 3.6 (currently infra uses 3.5 by default)
virtualenv -p python3.6 /tmp/venv
source /tmp/venv/bin/activate

pip install -r requirements.txt

echo "--- download new translations"
cd /lineage/${VERSION}
python lineage/crowdin/crowdin_sync.py --username c3po --branch $VERSION --download -p "$SCRIPT_DIR/crowdin-cli.sh"
STATUS=$?
# leave the venv while the build is happening.
deactivate

if [[ $STATUS -eq 2 ]]; then
	echo "No new translations, not running build."
	exit
elif [[ $STATUS -ne 0 ]]; then
	echo "Crowdin sync failed, failing build."
	exit $STATUS
fi

echo "--- breakfast"
. build/envsetup.sh
set +e
breakfast lineage_blueline-userdebug
set -e

if [[ "$TARGET_PRODUCT" != lineage_* ]]; then
	echo "Breakfast failed, exiting"
	# TODO(forkbomb): Abandon or -1 changes if stuff is broken.
	exit 1
fi

echo "--- Building"
mka otatools-package target-files-package dist > /tmp/android-build.log || exit 1
# TODO(forkbomb): Abandon or -1 changes if stuff is broken.

echo "--- Submitting translations"
source /tmp/venv/bin/activate
python lineage/crowdin/crowdin_sync.py --username c3po --branch $VERSION -s -o c3po
echo "Successful"
deactivate
rm -rf /tmp/venv
