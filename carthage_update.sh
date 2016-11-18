#!/bin/sh

carthage update --platform osx

rm -rf ./src/Frameworks
rsync -av --exclude='*.dSYM*' ./Carthage/Build/Mac/ ./src/Frameworks