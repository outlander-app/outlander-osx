#!/bin/sh

carthage update --platform osx

if [ $? -eq 0 ]
then
  rm -rf ./src/Frameworks
  rsync -av --exclude='*.dSYM*' ./Carthage/Build/Mac/ ./src/Frameworks
else
  echo "Failed to build dependencies"
  exit 1
fi

