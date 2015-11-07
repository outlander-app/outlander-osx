xcodebuild -workspace outlander.xcworkspace \
       -scheme OutlanderTests \
       clean build test \
       | xcpretty -s
