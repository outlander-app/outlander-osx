Outlander
==========

[![Build Status](https://travis-ci.org/joemcbride/outlander-osx.png?branch=master)](https://travis-ci.org/joemcbride/outlander-osx)

![](http://i.imgur.com/NsK0LOT.png)

Players
==========
Read the client [documentation](commands.md).

Developers
==========

This project uses [CocoaPods](http://cocoapods.org) for dependency management.  Run the following at the root of the project to download and install dependencies.

    $ sudo gem install cocoapods
    $ pod install

Use .xcworkspace workspace instead of .xcodeproj project after installation.

Install xctool to run unit tests on the command line.  xctool requires Xcode command line tools installed.

    $ xcode-select --install
    $ brew update
    $ brew install xctool
    $ ./test.sh

Run guard to have the unit tests auto-run on file changes.

    $ bundle install
    $ bundle exec guard

License
==========
[MIT License](LICENSE.md)
