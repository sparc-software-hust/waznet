#!/bin/bash

set -eo pipefail

# 1. Unlock git-crypt
# We could not use the existing GitHub action because it doesn't support Windows
# https://github.com/sliteteam/github-action-git-crypt-unlock/blob/master/entrypoint.sh
if ! command -v git-crypt &>/dev/null; then
  brew install git-crypt
fi
echo $GIT_CRYPT_KEY | base64 -d | git-crypt unlock -