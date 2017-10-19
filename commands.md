
* [Automapper](#automapper)
* [Configuration Commands](#configuration-commands)
* [Scripting](#scripting)

## Automapper

Outlander supports Genie map files.  View maps via the `⌘M` shortcut.  Mouse over a map node to see its name and `roomid`.  Your `roomid` can be referenced as a global variable, `$roomid`, and the id of the current map can be referenced as `$zoneid`.

#### Automapper Usage

* `#goto <roomid>`, `#goto <named room>`
* ex: `#goto 123`  `#goto bank`

#### Automapper Installation
* Use svn from terminal to download maps: `$ svn checkout http://svn.code.sf.net/p/geniemapsfordr/Genie3Maps/trunk Maps`
* Put the maps in the `/Documents/Outlander/Maps` folder
* You will also need the `automapper.cmd` script found listed under the [example scripts](#example-scripts)
    * Create a new script file named `automapper.cmd`, paste in the text from the gist, and save it to `/Documents/Outlander/Scripts`
* Use `svn update` from the folder created with the `svn checkout` command to fetch the latest maps

#### Automapper FAQ
> The automapper sometimes gets stuck, is this normal?

Yes - the Genie map files have several commands that are not yet fully supported.  As Outlander's script engine becomes more robust the `automapper.cmd` script will be updated to support those commands.

## Configuration Commands

* `#alias <name> <replacement>`
    * setup an alias
    * ex: `#alias l2 load arrows`
* `#class`
    * `#class (list|load|save|clear)`
    * `#class combat on` - this activates the `combat` class
    * `#class combat off` - this deactivates the `combat` class
    * `#class all on` - this activates all classes
    * `#class all off` - this deactivates all classes
    * `#class +combat -app` this activates the `combat` class and deactivates the `app` class
* `#var`
    * set global var
    * ex: `#var primary.container backpack`
* `#highlight`
    * add highlight
    * ex: `#highlight #AD0000 a silver clenched fist`
* `#script (abort|pause|resume|vars) <script name\>`
    * control running scripts
    * ex: #script pause forage
    * ex: #script resume forage
    * ex: #script vars forage
        * vars will display the current list of local script variables.
* `#parse <text>`
	* sends the text to be parsed by the scripting engine, as if sent by the game
* `#play` - play a sound file
  * `#play stop` - stops all playing sounds
  * `#play <filename>` plays the given sound file
  * If the file exists in the Outlander `Sounds` folder, you can leave off the full path and just use the file name, such as `spooky.mp3`.  Otherwise you will need to provide the full path to the file, such as `/Users/joe/Documents/Sounds/spooky.wav`.
* `#window add/show/hide/clear <name>`
  * ex: `#window add log`
  * ex: `#window hide log`
  * `#window list all` will show all window ids and locations.
    * The output: (x,y), (height, width)
    * x,y being the point of the top-left corner.  Height going down and width across.
    * `->` represents what window messages are forwarded to if that window is hidden. Ex: `atmospherics->main` means messages send to the `atmospherics` window will be forwarded to the `main` window.  Set the `closedTarget` in `layout.cfg` for the given window to accomplish this.
  ```
  Windows:
    thoughts: (x:0, y:0), (h:148, w:521)
    log: (x:0, y:147), (h:114, w:521)
    main: (x:0, y:259), (h:790, w:1357)
    percwindow: (x:1015, y:193), (h:177, w:341)
    logons: (x:1356, y:0), (h:206, w:380)
    death: (x:1356, y:205), (h:136, w:380)
    experience: (x:1356, y:340), (h:710, w:380)
    room: (x:520, y:0), (h:261, w:837)
    (hidden) atmospherics->main: (x:0, y:0), (h:200, w:200)
    (hidden) chatter->thoughts: (x:0, y:0), (h:200, w:200)
    (hidden) conversation->log: (x:0, y:0), (h:200, w:200)
    (hidden) familiar: (x:0, y:0), (h:200, w:200)
    (hidden) group: (x:0, y:0), (h:200, w:200)
    (hidden) inv: (x:0, y:0), (h:200, w:200)
    (hidden) ooc->log: (x:0, y:0), (h:200, w:200)
    (hidden) whispers: (x:0, y:0), (h:200, w:200)
    (hidden) raw: (x:453, y:193), (h:300, w:881)
    (hidden) assess->main: (x:782, y:502), (h:177, w:567)
    (hidden) talk->conversation: (x:801, y:306), (h:200, w:200)

  ```
  * `#window clear log` will clear all contents of the window

## Scripting

#### Example Scripts
* Repository of several scripts: https://github.com/joemcbride/outlander-osx-scripts
* [hunt.cmd](https://gist.github.com/joemcbride/d0c2b2cde11d68f9f9e4) - basic hunt script
```
supported options: throw, lob, hurl, offhand, ambush, poach, snipe, exp

.hunt offhand lob nightstick
.hunt poach shortbow
.hunt ambush "short sword"
```
* [disarm.cmd](https://gist.github.com/joemcbride/584f1b99d8c5211b410d) - disarm and pick boxes (supports lockpick rings or loose lockpicks, removes and re-equips armor)
* [swim.cmd](https://gist.github.com/joemcbride/adeb7ce75816ec510213) - swim between two rooms `.swim north south`
* [simpletravel.cmd](https://gist.github.com/joemcbride/f5d7d8aeaf687b31ccc5) - travel to locations across maps  `.simpletravel "w gate" brook`
* [automapper.cmd](https://gist.github.com/joemcbride/1614787c3913b6a4739f) - required for `#goto` map commands to work.  Set `#var powerwalk 1` to enable powerwalking to the given destination.

#### Scripting Basics
```
.myscript one two "three four"
```

Script arguments become local variables:

    %scriptname = myscript
	%0 = one two "three four"
	%1 = one
	%2 = two
	%3 = three four
    %argcount = 3

Use `#` to add comments to your script.

```
# collect items
loop:
  put collect rock
  pause 2
  goto loop
```

* \#beep
    * performs a system beep
* `#echo [>targetWindow] [color[,backgroundcolor]] <text>`
    * echo a message to a window
    * text - The text you want to echo
    * window (optional) - The target window you want to echo to.  Defaults to main.
    * color (optional) - The foreground color.  Use hex color.
    * backgroundcolor (optional) - The background color.
```
put #echo >thoughts #000000,#efefef hello
```
* \#flash
    * makes the dock icon bounce if the application is not the currently active application
* action \<commands\> when \<regex\>
```
action put #beep;put #flash when ^(.+) (say|says|asks|exlaims|whispers)
```
* debug/debuglevel \<0|1|2|3|4|5\>
* echo
* exit
* if/else
```
# single line ifs require the use of 'then'
if $Athletics.LearningRate >= 34 then goto MoveOut

# check number of arguments with if_x
if_2 {
  gosub print %2
} else {
  echo %0
}
goto end

print:
  echo $0
  return

end:
```
* (planned) include \<filename\>
    * `include monstervars` include the contents of the given script file in this script
* goto \<label\>
* gosub
    * gosub &lt;label&gt; &lt;argument1, argument2, etc.&gt;
    * Move to a label with the supplied arguments.  Arguments are referenced by $1, $2, etc.  Use $0 to reference all arguments.
    * Use `return` to return to the line directly after the gosub.
* math \<variable\> add/subtract/multiply/divide/modulus \<number\>
* match
	* match &lt;label&gt; &lt;text&gt;
	* match start You see
* matchre
	* matchre &lt;label&gt; &lt;text&gt;
	* matchre start first|second|third|fourth
* matchwait 10
* move \<direction\>
    * moves the direction and pauses until a room description is received
* nextroom
    * pauses until a room description is received
* pause 0.5
* put
 	* put &lt;command&gt;
	* put collect rock
* label:
    * (planned) use %lastlabel to know the last label passed
* math \<variable\> \<add|subtract|multiply|divide|modulus\> \<number\>
    * math my_count add 1
* random \<min\> \<max\>
    *  saves the result of the random to `%r` variable
* save \<text\>
    * Saves the given text to `%s` variable
* send \<text\>
    * sends the text after roundtime has completed or immediately if there is none
* setvariable
* unvar \<name\>
    * removes the script variable
* var \<name\> \<value\>
```
var weapon katana
echo %weapon # prints katana
```
* wait
* waiteval \<expression\>
    * waiteval $mana >= 60
* waitfor \<text\>
    * waits to continue until the given text
* waitforre \<regex\>
    * waits for the given regex to match

### Misc
* `contains("<value to check>", "<value to check for>")` function - can be used to determine if a value contains another value
```
if !contains("$lefthand", "%tool") then
{
  gosub get.tool %tool
}
```
* `matchre("<variable>", "<regex>")` function - can be used to evaluate to true/false within an `if` expression
```
if matchre("$roomobjs", "((which|that) appears dead|\(dead\))") then {
  # loot, skin
}
```
* `replacere("<variable>", "<regex>", "<replacement>")` function - can be used to do a regex replace on a variable
```
eval dir replacere("%dir", "^(search|swim|web|muck|rt|wait|slow|script|room|ice) ", "")
```

* `countsplit` function - counts the number of occurances of the given character
```
var two a|b|yes|test
eval twoCount countsplit(%two, "|")
echo %twoCount #prints 4
```
* variable indexers - variables with `|` delimiters can be used as sudo arrays with indexers
```
var weapons sword|longbow|scimitar

echo %weapons(0) # prints sword
echo %weapons[1] # prints longbow
echo %weapons(2) # prints scimitar
```

##Global Variables

Global variables are prefixed with a $.

* $charactername - your character name
* $preparedspell - currently prepared spell, `None` when there isn't one.
* $spelltime - amount of time in seconds the spell has been prepared
* $game - what game you are connected to, ex: 'DR'
* $gametime - the time in game you are playing, a Unix timestamp, ex: 1388858263
* $health - the percentange of your health
* $mana - the percentange of your mana
* $stamina - the percentange of your stamina
* $spirit - the percentange of your spirit
* $concentration - the percentange of your concentration
* $&lt;skill_name&gt;.Ranks
    * ex: Shield_Usage.Ranks, Outdoorsmanship.Ranks, etc.
* $&lt;skill_name&gt;.LearningRate
* $&lt;skill_name&gt;.LearningRateName
* $bleeding (0/1)
* $kneeling (0/1)
* $prone (0/1)
* $sitting (0/1)
* $standing (0/1)
* $stunned (0/1)
* $hidden (0/1)
* $invisible (0/1)
* $dead (0/1)
* $webbed (0/1)
* $joined (0/1)
* $lefthand - `Empty` when nothing
* $lefthandnoun
* $lefthandnounid
* $monstercount - the number of monsters in the room you are currently in; requires monsterbold to be set
* $monsterlist - the names of the monsters in the room you are currently in; requires monsterbold to be set
* $righthand - `Empty` when nothing
* $righthandnoun
* $righthandnounid
* $roomid - the room # of the map you are in
* $roomtitle
* $roomdesc
* $roomobjs
* $roomplayers
* $roomexits
* $roomextra
* $roundtime
* $prompt
* $north (0/1)
* $south (0/1)
* $east (0/1)
* $west (0/1)
* $northeast (0/1)
* $northwest (0/1)
* $southeast (0/1)
* $southwest (0/1)
* $up (0/1)
* $down (0/1)
* $out (0/01)
* $zoneid - the zone # of the map you are in
