#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

mkdir -p ${REPO}
git clone https://github.com/${REPO} ${REPO}
cd ${REPO}
git remote add gerrit ssh://c3po@review.lineageos.org:29418/${REPO}
if git checkout ${DEST_BRANCH}; then
    git push gerrit HEAD:refs/backups/heads/$(date +%Y%m%d-%H%M)/${DEST_BRANCH}
fi
git remote add new ${SRC_REPO}
git fetch new ${SRC_BRANCH}
git checkout FETCH_HEAD
git push -o skip-validation --force gerrit HEAD:refs/heads/${DEST_BRANCH}

