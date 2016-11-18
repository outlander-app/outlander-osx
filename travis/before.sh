#!/bin/sh
set -e

gem install xcpretty
brew update
brew install libxml2 libxslt

if [ $? -eq 0 ]
then
  echo "Dependencies installed"
  exit 0
else
  echo "Dependency intalls failed"
  exit 1
fi