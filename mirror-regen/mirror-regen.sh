#!/bin/bash -e
update_thingy() {
    git clean -fd
    git fetch origin main
    git reset --hard FETCH_HEAD

    "./$1"

    if git diff --quiet; then
        >&2 echo "$1: No changes detected."
        return
    fi

    DATESTRING="$(LC_ALL=C date --utc '+%d-%b-%Y %H:%M UTC')"
    REVIEWMSG=""

    if [ "$(git ls-files -o --exclude-standard | wc -l)" != "0" ]; then
        >&2 echo "$1: Found new untracked files, uploading for review."
        REVIEWMSG="Change contains new files, uploaded for manual review."
    elif [ "$(git ls-files -m | wc -l)" -gt 1 ]; then
        >&2 echo "$1: Multiple changed files, uploading for review."
        REVIEWMSG="Change contains multiple changed files, uploaded for manual review."
    elif [ "$(git diff --numstat | awk '{print $2}')" -gt 0 ]; then
        >&2 echo "$1: Found files with deleted lines, uploading for review."
        REVIEWMSG="Change contains files with deleted lines, uploaded for manual review."
    fi

    git add .

    git commit -m "$(sed "s/{date}/$DATESTRING/g" <<< "$2")"

    if [ -n "$REVIEWMSG" ]; then
        git push ssh://c3po@review.lineageos.org:29418/LineageOS/mirror HEAD:refs/for/main
        ssh -p 29418 c3po@review.lineageos.org "gerrit review -m '$REVIEWMSG' '$(git rev-parse HEAD)'"
    else
        git push ssh://c3po@review.lineageos.org:29418/LineageOS/mirror HEAD:refs/heads/main
    fi
}

set -eo pipefail

# Clone repo
git clone https://github.com/LineageOS/mirror.git
cd mirror

# Set up git user
git config user.name "LineageOS Infra"
git config user.email "infra@lineageos.org"

# Set up commit-msg hook
curl -Lo .git/hooks/commit-msg https://review.lineageos.org/tools/hooks/commit-msg
chmod u+x .git/hooks/commit-msg

# Install dependencies
pip install GitPython pygithub

# Update everything
update_thingy "mirror-regen.py" "Updated to {date}"
update_thingy "aosp-minimal-regen.py" "Updated aosp-minimal to {date}"
update_thingy "lineage-minimal-regen.py" "Updated lineage-minimal to {date}"
