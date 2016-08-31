#!/bin/sh

xctool -workspace outlander.xcworkspace \
       -scheme OutlanderTests \
       clean test
