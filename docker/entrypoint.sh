#!/bin/bash

# Configure git to use GITHUB_TOKEN for github.com HTTPS access
if [ -n "$GITHUB_TOKEN" ]; then
    git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
fi

exec "$@"
