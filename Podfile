platform:osx, '10.10'
use_frameworks!

project 'src/Outlander.xcodeproj'

def shared_pods
  pod 'CocoaAsyncSocket', '7.3.3'
  pod 'PEGKit', '~> 0.4'
end

target :Outlander do
    shared_pods
end

target :OutlanderTests do
  shared_pods
  pod 'Kiwi', '2.4.0'
  pod 'Quick', '0.9.1'
  pod 'Nimble', '3.2.0'
end
