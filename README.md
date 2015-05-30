Outlander - OSX 10.9+
==========

[![Build Status](https://travis-ci.org/joemcbride/outlander-osx.png?branch=master)](https://travis-ci.org/joemcbride/outlander-osx)

![](http://i.imgur.com/Q3t3QYG.png)

**Maps**

See your current location on the map.  Get directions to named locations or room numbers.  Compatible with Genie map files.  [Instructions for installing map files](commands.md#automapper)

![](http://i.imgur.com/tVivgNn.png)

**Script toolbar**

Active scripts are listed in a toolbar at the top of the screen.  Scripts can be paused/resumed/aborted, show script vars, or change debug level, all from a menu.

![scripttoolbar](https://cloud.githubusercontent.com/assets/255007/7898521/6e137ca8-06b7-11e5-96fa-4095fb6ce873.png)

**Minimal UI**

You can remove window borders for a text-only experience.

![](http://i.imgur.com/ZBtaUUR.png)

Players
==========
Read the [Outlander documentation](commands.md).

[Instructions for installing map files](commands.md#automapper)

[Scripting support](commands.md#scripting) and [Example scripts](commands.md#example-scripts)

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
