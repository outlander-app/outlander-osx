## Configuration Commands

* \#alias \<name\> \<replacement\>
    * setup an alias
    * ex: #alias l2 load arrows    
* \#var
    * set global var
    * ex: #var primary.container backpack
* \#highlight
    * add highlight
    * ex: #highlight #AD0000 a silver clenched fist
* \#script (abort|pause|resume) \<script name\>
    * control running scripts
    * ex: #script pause forage
    * ex: #script resume forage
* coming - \#parse \<text\>
	* sends the text to be parsed by the scripting engine, as if sent by the game

## Scripting

    .myscript one two "three four"
   
Script arguments become local variables:
	
    %scriptname = myscript
	%0 = one two "three four"
	%1 = one
	%2 = two
	%3 = three four
    %argcount = 3

* echo
* exit
* goto
* gosub
    * gosub &lt;label&gt; &lt;argument1, argument2, etc.&gt;
    * Move to a label with the supplied arguments.  Arguments are referenced by $1, $2, etc.  Use $0 to reference all arguments.
    * Use 'return' to return to the line directly after the gosub.
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
    * use %lastlabel to know the last label passed
* setvariable
* var
* wait
* waitre

##Global Variables

Global variables are prefixed with a $.

* $charactername - your character name
* $preparedspell - currently prepared spell, 'None' when there isn't one.
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
* $lefthand
* $lefthandnoun
* $lefthandnounid
* coming - $monstercount - the number of monsters in the room you are currently in; requires monsterbold to be set
* coming - $monsterlist - the names of the monsters in the room you are currently in; requires monsterbold to be set
* coming - parse \<text\>
	* sends the text to be parsed by the scripting engine, as if sent by the game
* $righthand
* $righthandnoun
* $righthandnounid
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