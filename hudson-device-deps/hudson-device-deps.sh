#!/bin/bash
set -eo pipefail
echo "--- Setup"
if [ -z "$REPO_VERSION" ]; then
  export REPO_VERSION=v2.28
fi

echo "--- Syncing"
cd /lineage/$BUILDKITE_BRANCH
repo sync lineage/{hudson,scripts}

if [ -f /lineage/setup.sh ]; then
    source /lineage/setup.sh
fi

cd lineage/scripts/device-deps-regenerator
pip3 install --user -r requirements.txt

if ! python3 app.py; then
  echo "./app.py failed, exiting"
  exit 1
fi

if ! python3 devices.py; then
  echo "./devices.py failed, exiting"
  exit 1
fi

mv device_deps.json ../../hudson/updater
rm out.json

cd ../../hudson/updater

if git add device_deps.json && git commit -m "Regenerate device dependency mappings"; then
  git push ssh://c3po@review.lineageos.org:29418/LineageOS/hudson HEAD:refs/for/master%l=Code-Review+2,l=Verified,submit
fi
