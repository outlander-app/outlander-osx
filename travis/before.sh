#!/bin/sh
set -e

brew update
brew unlink xctool
brew install xctool
sudo gem install cocoapods
pod install