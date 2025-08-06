#!/bin/bash
echo 'run pod install:'

gem install bundler
bundle install

cd ./ios || exit

# Install pods
bundle exec pod install --repo-update
if [[ $? != 0 ]]; then
    exit 1
fi
