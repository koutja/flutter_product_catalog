#!/bin/bash
echo 'run ruby install:'

# Source RVM into local environment.
# See: https://rvm.io/workflow/scripting/
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
    # First try to load from a user install
    source "$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
    # Then try to load from a root install
    source "/usr/local/rvm/scripts/rvm"
else
    echo "ERROR: An RVM installation was not found." >&2
    exit 1
fi

brew install openssl@3
RUBY_VERSION_FILE="$(dirname "${BASH_SOURCE[0]}")/../.ruby-version"
rvm install "ruby-$(cat "$RUBY_VERSION_FILE")" --with-openssl-dir=$(brew --prefix openssl@3)
rvm use "$(cat "$RUBY_VERSION_FILE")" --default
