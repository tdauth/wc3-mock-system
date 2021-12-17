# wc3-taunt-system

Warcraft III: Reforged system for taunts.

Taunts are ingame voice messages which players can send to each other to make the game more fun or to really send instructions to others.

## Usage

Put [the system's code](./src/TauntSystem.j) in your own custom map script, save your map and play it.

## Test

Download [this example map](./wc3tauntsystem1.0.w3x) to try the system.

## Features

* Easy to use without any dependencies or much effort.
* Provides many standard chat commands.
* Supports standard sounds from Warcraft III.
* Multiple aliases per taunt.
* Mute player texts and sounds.
* Cooldowns to avoid spamming.
* Enable taunts per player only.
* Highly configurable via options and callbacks.
* Non-leaking.

## API

The system provides a simple JASS API which can be used in your custom triggers.

Every taunt has a unique name which can be used to identify it and which is used by default in the chat to send it.
It is possible to add multiple aliases which can also be used in the chat.
Almost anything can be enabled and disabled for players only.
Standard sounds from Warcraft can be added with simple functions.

```
function AddTaunt takes string name, string text, sound whichSound returns nothing

function AddTauntWithStandardSound takes string name, string text, string soundPath returns nothing

function RemoveTaunt takes string name returns nothing

function GetTaunt takes integer index returns string

function CountTaunts takes nothing returns integer

function AddTauntAlias takes string name, string alias returns nothing

function RemoveTauntAlias takes string name, string alias returns nothing

function GetTauntAlias takes integer index returns string

function CountTauntAliases takes string name returns integer

function EnableTauntAliasForPlayer takes string name, string alias returns nothing

function DisableTauntAliasForPlayer takes string name, string alias returns nothing`

function IsTauntAliasEnabledForPlayer takes string name, string alias, player whichPlayer returns boolean

function EnableTauntForPlayer takes string name, player whichPlayer returns nothing

function DisableTauntForPlayer takes string name, player whichPlayer returns nothing

function IsTauntEnabledForPlayer takes string name, player whichPlayer returns boolean

function SendTaunt takes string name, player from, force to returns nothing

function MuteTaunts takes player whichPlayer, force from returns nothing

function IsTauntMutedForPlayer takes string name, player whichPlayer returns boolean

function MuteTauntSounds takes player whichPlayer, force from returns nothing

function IsTauntSoundsMutedForPlayer takes string name, player whichPlayer returns boolean

function MuteTauntMessages takes player whichPlayer, force from returns nothing

function IsTauntMessagesMutedForPlayer takes string name, player whichPlayer returns boolean

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

## Implementation

[The system's code](./src/TauntSystem.j) is written in vJass.

## Future Work

In the future this system could be improved:

* Custom chat GUI with mute and taunt buttons.
* AI support: Enable some standard taunts for the AI. The AI could react to your taunts or send some depending on the game situation.
* AI commands: Some taunts could work as real AI commands.

## Links

* <https://wowwiki-archive.fandom.com/wiki/Quotes_of_Warcraft_III/Orc_Horde>
* <https://ageofempires.fandom.com/wiki/Taunts>
