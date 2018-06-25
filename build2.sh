#!/bin/sh

pushd ./Carthage/Checkouts/YogaKit/src

xcodebuild -workspace YogaKit.xcworkspace \
       -scheme YogaKit \
       -configuration Release clean build
