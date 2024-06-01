#!/bin/bash
set -eo pipefail
echo "--- Setup"
rm /tmp/android-*.log || true
unset CCACHE_EXEC
export PYTHONDONTWRITEBYTECODE=true
export BUILD_ENFORCE_SELINUX=1
export BUILD_NO=
unset BUILD_NUMBER

if [ "$BUILDKITE_BRANCH" == "lineage-18.1" ] || [ "$BUILDKITE_BRANCH" == "lineage-19.1" ]; then
  export OVERRIDE_TARGET_FLATTEN_APEX=true
fi

#TODO(zif): convert this to a runtime check, grep "sse4_2.*popcnt" /proc/cpuinfo
export CPU_SSE42=false

if [ -z "$REPO_VERSION" ]; then
  export REPO_VERSION=v2.28
fi

cd $(dirname $0)
SCRIPT_DIR=`pwd`

echo "--- Syncing"

mkdir -p /lineage/${BUILDKITE_BRANCH}/.repo/local_manifests
cd /lineage/${BUILDKITE_BRANCH}
rm -rf .repo/local_manifests/*
if [ -f /lineage/setup.sh ]; then
    source /lineage/setup.sh
fi
repo sync lineage/crowdin
cp lineage/crowdin/config/${BUILDKITE_BRANCH}_extra_packages.xml .repo/local_manifests
# catch SIGPIPE from yes
yes | repo init -u https://github.com/lineageos/android.git -b ${BUILDKITE_BRANCH} -g default,-darwin --repo-rev=${REPO_VERSION} --git-lfs || if [[ $? -eq 141 ]]; then true; else false; fi
repo version

echo "Syncing"
(
  repo sync --detach --current-branch --no-tags --force-remove-dirty --force-sync -j32 ||
  repo sync --detach --current-branch --no-tags --force-remove-dirty --force-sync -j32 ||
  repo sync --detach --current-branch --no-tags --force-remove-dirty --force-sync -j32
)
repo forall -c "git lfs pull"
. build/envsetup.sh


echo "--- clobber"
rm -rf out

# TODO(forkbomb): Modify the crowdin tool so we don't have to change this every time we change branch.
export LINEAGE_CROWDIN_BASE_PATH_LINEAGE_17_1=/lineage/lineage-17.1
export LINEAGE_CROWDIN_BASE_PATH_LINEAGE_18_1=/lineage/lineage-18.1
export LINEAGE_CROWDIN_BASE_PATH_LINEAGE_19_1=/lineage/lineage-19.1
export LINEAGE_CROWDIN_BASE_PATH_LINEAGE_20_0=/lineage/lineage-20.0
export LINEAGE_CROWDIN_BASE_PATH_LINEAGE_21_0=/lineage/lineage-21.0
cd lineage/crowdin

echo "--- setup python environment for translation sync"

source /lineage/crowdin.sh

pip3 install --user -r requirements.txt
cd /lineage/${BUILDKITE_BRANCH}

if [[ $UPLOAD_SOURCES -eq 1 ]]; then
  echo "--- upload sources"
  ./lineage/crowdin/crowdin_sync.py --branch $BUILDKITE_BRANCH --upload-sources -p "$SCRIPT_DIR/crowdin-cli.sh"
  exit
fi

echo "--- download new translations"
./lineage/crowdin/crowdin_sync.py --username c3po --branch $BUILDKITE_BRANCH --download -p "$SCRIPT_DIR/crowdin-cli.sh"
STATUS=$?

if [[ $STATUS -eq 2 ]]; then
	echo "No new translations, not running build."
	exit
elif [[ $STATUS -ne 0 ]]; then
	echo "Crowdin sync failed, failing build."
	exit $STATUS
fi

echo "--- breakfast"
if ! breakfast barbet; then
  echo "Breakfast failed, exiting"
  ./lineage/crowdin/crowdin_sync.py --username c3po --branch $BUILDKITE_BRANCH -g abandon -m "$BUILDKITE_BUILD_URL failed." -o c3po
  exit 1
fi

echo "--- Building"
if ! mka otatools-package target-files-package dist | tee /tmp/android-build.log; then
  echo "Build failed, exiting"
  ./lineage/crowdin/crowdin_sync.py --username c3po --branch $BUILDKITE_BRANCH -g abandon -m "$BUILDKITE_BUILD_URL failed." -o c3po
  exit 1
fi

echo "--- Submitting translations"
./lineage/crowdin/crowdin_sync.py --username c3po --branch $BUILDKITE_BRANCH -g submit -o c3po
echo "Successful"

echo "--- cleanup"
rm -rf out
