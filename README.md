Outlander - OSX 10.10+
==========
[![Travis](https://img.shields.io/travis/joemcbride/outlander-osx.svg)](https://travis-ci.org/joemcbride/outlander-osx)

Like Outlander?  Consider [becoming a Patreon](https://www.patreon.com/outlander).

## Player documentation
Question or suggestion?

Join the Discord Server - https://discord.gg/XqyCNEq

See the YouTube Channel with for some how-to videos: https://www.youtube.com/channel/UCH7LuCxJkg_wJ0l2KUHia0g

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

This project uses [Carthage](https://github.com/Carthage/Carthage) for dependency management.  Run the following at the root of the project to download and install dependencies.

    $ brew update
    $ brew install carthage
    $ ./carthage_update.sh

Use .xcworkspace workspace instead of .xcodeproj project after installation.

Install xcpretty to run unit tests on the command line.

    $ gem install xcpretty
    $ ./build.sh

License
==========
[MIT License](LICENSE.md)
