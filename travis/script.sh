#!/bin/sh
set -e

xctool -workspace src/outlander.xcworkspace \
       -scheme OutlanderTests \
       clean build test \
       ONLY_ACTIVE_ARCH=NO