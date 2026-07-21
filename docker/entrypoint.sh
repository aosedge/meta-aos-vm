#!/bin/bash

# Configure git to use GITHUB_TOKEN for github.com HTTPS access
if [ -n "$GITHUB_TOKEN" ]; then
    # Store credentials in git credential store format
    CRED_FILE="/tmp/.git-credentials"
    echo "https://x-access-token:${GITHUB_TOKEN}@github.com" > "$CRED_FILE"
    chmod 600 "$CRED_FILE"

    GIT_CONF="/tmp/.gitconfig"
    git config -f "$GIT_CONF" credential.helper "store --file=$CRED_FILE"
    export GIT_CONFIG_GLOBAL="$GIT_CONF"

    # Clear from env so child processes don't inherit it
    unset GITHUB_TOKEN
fi

exec "$@"
