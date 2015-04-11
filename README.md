Outlander - OSX 10.9+
==========

[![Build Status](https://travis-ci.org/joemcbride/outlander-osx.png?branch=master)](https://travis-ci.org/joemcbride/outlander-osx)

![](http://i.imgur.com/Q3t3QYG.png)

> Maps! See your current location on the map.  Get directions to named locations or room numbers.  Compatible with Genie map files.

![](http://i.imgur.com/tVivgNn.png)

>You can remove window borders for a true text-only experience.

![](http://i.imgur.com/ZBtaUUR.png)

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
