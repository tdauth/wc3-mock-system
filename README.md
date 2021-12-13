# wc3-taunt-system

Warcraft III: Reforged system for taunts.

Taunts are ingame voice messages which players can send to each other to make the game more fun or to really send instructions to others.

## API

Every taunt has a unique name which can be used to identify it and which is used by default in the chat to send it.
It is possible to add multiple aliases which can also be used in the chat.
Almost anything can be enabled and disabled for players only.
Standard sounds from Warcraft can be added with simple functions.

```
function AddTaunt takes string name, string text, sound whichSound returns nothing

function AddTauntAlias takes string name, string alias returns nothing

function EnableTauntAliasForPlayer takes string name, string alias returns nothing

function DisableTauntAliasForPlayer takes string name, string alias returns nothing
   
function EnableTauntForPlayer takes string name, player whichPlayer returns nothing

function DisableTauntForPlayer takes string name, player whichPlayer returns nothing

function SendTaunt takes string name, player from, force to returns nothing

function MuteTaunts takes player whichPlayer, force from returns nothing

function MuteTauntSounds takes player whichPlayer, force from returns nothing

function MuteTauntMessages takes player whichPlayer, force from returns nothing

function UnmuteTaunts takes player whichPlayer, force from returns nothing

function UnmuteTauntSounds takes player whichPlayer, force from returns nothing

function UnmuteTauntMessages takes player whichPlayer, force from returns nothing

/**
 * Displays all possible taunt chat commands to each player from the given force.
 */
function DisplayTaunts takes force whichForce returns nothing

/**
 * Adds a taunt called "-saynomore" with the standard archer sound from Warcraft III.
 */
function AddTauntArcherSayNoMore takes nothing returns nothing
```

## Sources

* <https://wowwiki-archive.fandom.com/wiki/Quotes_of_Warcraft_III/Orc_Horde>
* <https://ageofempires.fandom.com/wiki/Taunts>
