#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

mkdir -p ${REPO}
git clone https://github.com/torvalds/linux ${REPO}
cd ${REPO}
git checkout ${SRC_BRANCH}
git remote add gerrit ssh://c3po@review.lineageos.org:29418/LineageOS/${REPO}
for i in `seq 50000 -5000 0`; do
    git push -o skip-validation gerrit ${SRC_BRANCH}^0~${i}:refs/heads/${DEST_BRANCH} ||
        git push --no-thin -o skip-validation gerrit ${SRC_BRANCH}^0~${i}:refs/heads/${DEST_BRANCH} ||
        true
    ssh -p 29418 c3po@review.lineageos.org replication start LineageOS/${REPO} --wait
done
