#!/usr/bin/env bash

set -Eeuo pipefail

# Show the outcome and keep a desktop terminal open
finish() {
    status=$?

    if [ "$status" -ne 0 ]; then
        echo ""
        echo "ERROR: Git sync failed."
        echo "Read the messages above for details."
    fi

    if [ -t 0 ]; then
        echo ""
        read -r -p "Press Enter to close..." || true
    fi
}

trap finish EXIT

# Navigate to this script's folder
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

# Require the main branch
if [ "$(git branch --show-current)" != "main" ]; then
    echo "ERROR: You must be on the main branch."
    exit 1
fi

echo "================================="
echo "        GITHUB AUTO SYNC"
echo "================================="

# Stage all local changes
echo "Staging files..."
git add -A

# Commit changes, if any
if ! git diff --cached --quiet; then
    echo "Creating commit..."
    git commit -m "Auto sync: $(date '+%Y-%m-%d %H:%M:%S')"
else
    echo "No local changes to commit."
fi

# Download updates and replay local commits
echo "Downloading latest updates..."
git pull --rebase origin main

# Upload local commits
echo "Uploading changes..."
git push origin main

echo ""
echo "================================="
echo "       SYNC SUCCESSFUL!"
echo "================================="
