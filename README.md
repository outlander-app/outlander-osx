Outlander - OSX 10.10+
==========

## Player documentation
Question or suggestion?  [![Join the chat at https://gitter.im/joemcbride/outlander-osx](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/joemcbride/outlander-osx?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
You can also read the [player documentation](commands.md) to see all of the available [commands](commands.md).

[Scripting support](commands.md#scripting) and [Example scripts](commands.md#example-scripts)

![Outlander App](http://i.imgur.com/Gk8LFK1.png)

### Multiple character profiles
Create multiple character profiles with persistent global variables.

### Highlights
Create custom highlight strings of foreground/background colors with full regex capability.

### Macros
Create macros for keypad navigation or quick keyboard actions.

### Aliases
Create aliased commands for less typing.

As an example, `l2` can become `load arrows`, or `atk mace` can become `.hunt offhand lob mace`.

### Substitutes
Provide substitute text based on regex to add or replace game text.  For example, adding numbers to mana perception or weapon appraisals.

### Gags
You can provide a list of things to ignore being shown.

### Windows
Customize and save your window layout with draggable/resizable windows. Create custom windows and show/hide existing windows with the #window command.

Get live updates of vitals (health, mana, stamina, concentration, spirit), experience fill and gain, tdps, and room players, monsters, and objects.

Toggle and persist window timestamps and border settings.

See live available cardinal directions with the direction pinwheel.

![Outlander App](http://i.imgur.com/Gk8LFK1.png)

### Maps
See your current location on the map.

Get directions to named locations or room numbers and automatically move to that location using #goto.

Easily see additional mapped exits besides the cardinal directions.

Compatible with Genie map files.

[Read more about Automapper and get instructions for installing map files.](commands.md#automapper)

![Outlander App - Automapper](http://i.imgur.com/V4cWDhW.png)

### Script toolbar

Active scripts are listed in a toolbar at the top of the screen.  Scripts can be paused/resumed/aborted, show script vars, or change debug level, all from a menu.

![Outlander App - Script toolbar](https://cloud.githubusercontent.com/assets/255007/7898521/6e137ca8-06b7-11e5-96fa-4095fb6ce873.png)

### Minimal UI

You can remove window borders for a text-only experience.

![Minimal UI](http://i.imgur.com/ZBtaUUR.png)

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
