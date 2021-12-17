# wc3-taunt-system

Warcraft III: Reforged system for taunts.

Taunts are ingame voice messages which players can send to each other to make the game more fun or to really send instructions to others.

## Usage

Put [the system's code](./src/TauntSystem.j) in your own custom map script, save your map and play it.

## Test

Download [this example map](./wc3tauntsystem1.0.w3x) to try the system.

The map uses the AI extension allowing to you not only to taunt the other players but to command your allies.

## Features

* Easy to use without any dependencies or much effort.
* Provides many standard chat commands.
* Supports standard sounds from Warcraft III.
* Predefined collections of standard Warcarft III sounds.
* Multiple aliases per taunt.
* Mute player texts and sounds.
* Cooldowns to avoid spamming.
* Enable taunts per player only.
* Supports a quest per player listing all available chat commands.
* Highly configurable via options and callbacks.
* Non-leaking.
* AI commands support.

## Standard Chat Commands

By default, the system provides some useful chat commands for taunting.

* `-taunts`: Displays all available taunts and corresponding chat commands to the player.
* `-mute/unmute X`: Mutes/unmutes taunts from player(s) X.
* `-muted`: Lists muted players.
* `-players`: Lists all playing players who you can send taunts to with their player numbers and color name and indicating whether you have muted them or not.

`X` can have different values like multiple player numbers `1,2,4`, player colors `red,green,blue` or the following special identifiers:

* `all`: Affects all playing players. This is the default behaviour if you do no not specify X.
* `allies`: Affects all allied playing players.
* `enemies`: Affects all enemy playing players.
* `neutral`: Affects all neutral playing players.
* `computer`: Affects all Computer playing players.
* `user`: Affects all non-Computer playing players.
* `teamX`: Affects all players from team X where X is a number.
* `observers`: Affects all observing players.
* `invaders`: Affects all enemy playing players who are near to your buildings and see them.
* `victims`: Affects all enemy playing players who have buildings next to your army and you can see them.

You can combine multiple identifiers like `enemies computer` which will select only playing Computer players who are your enemies. The comma means someting like or and starts a new condition. Hence, `enemies,computer` will send it to your playing enemies but also all playing Computer players.

The special identifiers are shown in addition to the actual players who the taunt is send to.

## Standard Quest

By default, there is an optional quest in the quest log which describes how to use taunts and lists all available chat commands per player.

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

function GetTriggeredTaunt takes nothing returns string
    
function GetTriggeredTauntFrom takes nothing returns player
    
function GetTriggeredTauntTo takes nothing returns force
    
function RegisterTauntCallback takes code func returns nothing
    
function UnregisterAllTauntCallbacks takes nothing returns nothing

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
```

The following functions add standard Warcraft III sounds with predefined names:

```
function AddTauntArthasOfCourse takes nothing returns nothing

function AddTauntPeasantHelp takes nothing returns nothing
```

## Extensions

### AI Extension

[The AI extension](./src/TauntAIExtension.j) allows you to send commands to the AI with the help of taunts.
It adds the following functions:

```
function AddTauntAICommand takes nothing returns integer
    
function SetTauntAICommandDataCalculator takes integer command, TauntAICommandDataCalculator dataCalculator returns nothing

function SetTauntAICommandDataCalculatorSendingPlayer takes integer command returns nothing

function SetTauntAICommandDataCalculatorTargetPlayer takes integer command returns nothing

function EnableTauntAICommandForTaunt takes integer command, string name returns nothing

function DisableTauntAICommandForTaunt takes integer command, string name returns nothing

function IsTauntAICommandEnabledForTaunt takes integer command, string name returns boolean

function EnableTauntAICommandForPlayer takes integer command, player from, player to returns nothing

function DisableTauntAICommandForPlayer takes integer command, player from, player to returns nothing

function IsTauntAICommandEnabledForPlayer takes integer command, player from, player to returns boolean

function EnableAICommandComputerAllies takes integer command, player from returns nothing

function EnableAICommandComputerAlliesForAll takes integer command returns nothing

function GetTriggerTauntAICommand takes nothing returns integer

function GetTriggerTauntAIData takes nothing returns integer

function RegisterTauntAICommandCallback takes code func returns nothing

function UnregisterAllTauntAICommandCallbacks takes nothing returns nothing
```

These functions allow you to register AI commands dynamically for taunts. When the taunt is used the AI command will be send with the given data to the given force.
However, the AI script has to be written manually to react to the command since there are no standard AI commands in Warcraft III.
The example map provides some AI which reacts to certain taunts.

[Human.ai](./src/Human.ai) is an example campaign AI script which reacts to the AI taunts from the example map.
It contains a single thread which handles all AI commands.
The same could be done for melee AI scripts.

[example.j](./src/example.j) shows how to add some AI taunt commands.

### UI Extension

The UI extension adds a custom UI which allows the player to send taunts.

TODO Work in progress.

## Implementation

[The system's code](./src/TauntSystem.j) is written in vJass.

## Future Work

In the future this system could be improved:

* Custom chat GUI with mute and taunt buttons.
* AI support: Enable some standard taunts for the AI. The AI could react to your taunts or send some depending on the game situation.
* AI commands: Some taunts could work as real AI commands.
* Some command like `-react` which reacts to the latest taunt which was send to you. This would only work for standard sounds from the game.

## Links

* <https://wowwiki-archive.fandom.com/wiki/Quotes_of_Warcraft_III/Orc_Horde>
* <https://ageofempires.fandom.com/wiki/Taunts>
