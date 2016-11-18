#!/bin/sh

xcodebuild -workspace outlander.xcworkspace \
       -scheme OutlanderTests \
       clean test | xcpretty -tc && exit ${PIPESTATUS[0]}
