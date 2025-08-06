#!/bin/bash
DATE=$(date +'%y.%m.%d')
BUILD=$(date +'%y%m%d')00
sed -i '' "s/^version: .*/version: $DATE+$BUILD/" pubspec.yaml
