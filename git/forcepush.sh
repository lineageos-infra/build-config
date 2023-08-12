#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

mkdir -p ${REPO}
git clone https://github.com/${REPO} ${REPO} -b ${DEST_BRANCH}
cd ${REPO}
git remote add gerrit ssh://c3po@review.lineageos.org:29418/${REPO}
git push gerrit HEAD:refs/backups/heads/$(date +%Y%m%d-%H%m)/${DEST_BRANCH}
git remote add new ${SRC_REPO}
git fetch new ${SRC_BRANCH}
git checkout FETCH_HEAD
git push --force gerrit HEAD:refs/heads/${DEST_BRANCH}

