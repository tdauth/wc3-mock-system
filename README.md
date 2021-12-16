# wc3-taunt-system

Warcraft III: Reforged system for taunts.

Taunts are ingame voice messages which players can send to each other to make the game more fun or to really send instructions to others.

## Download

Download this [example map]() to try the system.

## Features

* Works out of the box with standard chat commands.
* Supports standard sounds from Warcraft III.
* Multiple aliases per taunt.
* Mute player texts and sounds.
* Cooldowns to avoid spamming.
* Enable taunts per player only.
* No dependencies required.
* Highly configurable via callbacks.

## API

The system provides a simple JASS API which can be used in your custom triggers.

Every taunt has a unique name which can be used to identify it and which is used by default in the chat to send it.
It is possible to add multiple aliases which can also be used in the chat.
Almost anything can be enabled and disabled for players only.
Standard sounds from Warcraft can be added with simple functions.

```
function AddTaunt takes string name, string text, sound whichSound returns nothing
endfunction

function RemoveTaunt takes string name returns nothing
endfunction

function GetTaunt takes integer index returns string
endfunction

function CountTaunts takes nothing returns integer
endfunction

function AddTauntAlias takes string name, string alias returns nothing
endfunction

function RemoveTauntAlias takes string name, string alias returns nothing
endfunction

function GetTauntAlias takes integer index returns string
endfunction

function CountTauntAliases takes string name returns integer
endfunction

function EnableTauntAliasForPlayer takes string name, string alias returns nothing
endfunction

function DisableTauntAliasForPlayer takes string name, string alias returns nothing`
endfunction

function IsTauntAliasEnabledForPlayer takes string name, string alias, player whichPlayer returns boolean
endfunction

function EnableTauntForPlayer takes string name, player whichPlayer returns nothing
endfunction

function DisableTauntForPlayer takes string name, player whichPlayer returns nothing
endfunction

function IsTauntEnabledForPlayer takes string name, player whichPlayer returns boolean
endfunction

function SendTaunt takes string name, player from, force to returns nothing
endfunction

function MuteTaunts takes player whichPlayer, force from returns nothing
endfunction

function IsTauntMutedForPlayer takes string name, player whichPlayer returns boolean
endfunction

function MuteTauntSounds takes player whichPlayer, force from returns nothing
endfunction

function IsTauntSoundsMutedForPlayer takes string name, player whichPlayer returns boolean
endfunction

function MuteTauntMessages takes player whichPlayer, force from returns nothing
endfunction

function IsTauntMessagesMutedForPlayer takes string name, player whichPlayer returns boolean
endfunction

function UnmuteTaunts takes player whichPlayer, force from returns nothing
endfunction

function UnmuteTauntSounds takes player whichPlayer, force from returns nothing
endfunction

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

## Implementation

The system is written in vJass.

## Future Work

In the future this system could be improved:

* Custom chat GUI with mute and taunt buttons.
* AI support: Enable some standard taunts for the AI. The AI could react to your taunts or send some depending on the game situation.
* AI commands: Some taunts could work as real AI commands.

## Links

* <https://wowwiki-archive.fandom.com/wiki/Quotes_of_Warcraft_III/Orc_Horde>
* <https://ageofempires.fandom.com/wiki/Taunts>
