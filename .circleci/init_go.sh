#!/bin/bash

set -x

echo "Cloning goenv..."
git clone https://github.com/syndbg/goenv.git ~/.goenv 2>&1

GO_VERSION="$(cat test/.go-version)"

echo "Installing go..."
$HOME/.goenv/bin/goenv install -f "${GO_VERSION}"

echo "Setting .bashrc env..."
echo 'export GOENV_ROOT="$HOME/.goenv"' >>$BASH_ENV
echo "export GOROOT=\"\$HOME/.goenv/versions/${GO_VERSION}\"" >>$BASH_ENV
echo 'export PATH="$GOROOT/bin:$GOENV_ROOT/bin:$PATH"' >>$BASH_ENV
cat $BASH_ENV
