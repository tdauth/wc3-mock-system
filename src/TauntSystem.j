library TauntSystemConfig

    globals
        constant string TAUNT_SYSTEM_CHAT_PREFIX = "-"
        constant boolean TAUNT_SYSTEM_MOCKS_CHAT_COMMAND = true
        constant string TAUNT_SYSTEM_DEFAULT_COOLDOWN = 6.0
        // Adds "-tauntson/-tauntsoff" chat commands to enable/disable all taunts.
        constant boolean TAUNT_SYSTEM_MOCKSONOFF_CHAT_COMMANDS = true
        // Adds "-mute X" chat commands where X can be the player number or color. All taunts from the player will be muted.
        constant boolean TAUNT_SYSTEM_MUTE_CHAT_COMMAND = true
    endglobals

endlibrary

library TauntSystem requires TauntSystemConfig initializer Init

    globals
        private hashtable tauntHashTable = InitHashTable()
    endglobals
    
    private struct PlayerData
        private player whichPlayer
        private real cooldown
        private force mutedForce
        private timer cooldownTimer
        
        public method getMutedForce takes nothing returns force
            return mutedForce
        endmethod
        
        public method getCooldownTimer takes nothing returns player
            return cooldownTimer
        endmethod
        
        public method startCooldownTimer takes nothing returns nothing
            call TimerStart(cooldownTimer, cooldown, false, null)
        endmethod
        
        public static method create takes player whichPlayer, real cooldown returns thistype
            local thistype this = thistype.allocate()
            set this.whichPlayer = whichPlayer
            set this.cooldown = cooldown
            set this.mutedForce = CreateForce()
            set this.cooldownTimer = CreateTimer()
            
            call SaveInteger(this, 0, GetPlayerId(whichPlayer), tauntHashTable)
            
            return this
        endmethod
    endstruct
    
    private function GetPlayerData takes player whichPlayer returns PlayerData
        return LoadInteger(0, GetPlayerId(whichPlayer), tauntHashTable)
    endfunction
    
    private function InitPlayerData takes nothing returns nothing
        call PlayerData.create(GetEnumPlayer(), TAUNT_SYSTEM_DEFAULT_COOLDOWN)
    endfunction
    
    private function Init takes nothing returns nothing
        call ForForce(GetAllPlayers(), function InitPlayerData)
    endfunction
    
    private function GetPlayerFromString takes string whichString returns player
    endfunction
    
    private function GetColoredPlayerName takes player whichPlayer returns string
    endfunction

    private struct Taunt
        private string name
        private string text
        private sound whichSound
        
        private trigger array aliasChatTriggers[100]
        private string array aliases[100]
        private integer aliasIndex = 0
        
        public method send takes player from, force whichForce returns nothing
            local integer i = 0
            loop
                exitwhen (i == MAX_PLAYERS)
                if (IsPlayerInForce(Player(i), whichForce)) then
                    if (not IsPlayerInForce(from, GetPlayerData(Player(i)).getMutedForce())) then
                        call DisplayMessage(Player(i), GetColoredPlayerName(Player(i)) + ": " + this.text)
                        call PlaySoundForPlayer(Player(i), this.whichSound)
                    else
                        call DisplayMessage(from, GetColoredPlayerName(Player(i)) + " has muted you or all players.")
                    endif
                endif
                set i = i + 1
            endloop
        endmethod
        
        private static method triggerActionTaunt takes nothing returns nothing
            local player target = GetPlayerFromString(GetEnteredChatString())
            
            if (GetRemainingTime(GetPlayerData(GetTriggerPlayer()).getCooldownTimer()) <= 0.0) then
                if (target == null) then
                    call this.send(GetTriggerPlayer(), GetAllPlayers())
                else
                    call this.send(GetTriggerPlayer(), GetPlayerForce(target))
                endif
                
                call GetPlayerData(GetTriggerPlayer()).startCooldownTimer()
            else
                call DisplayMessage(GetTriggerPlayer(), "Wait some time for the next taunt.")
            endif
        endmethod
        
        public method addAlias takes string alias returns integer
            set this.aliases[this.aliasIndex] = alias
            set this.aliasChatTriggers[this.aliasIndex] = CreateTrigger()
            // TODO chat event
            call TriggerAddAction(this.aliasChatTriggers[this.aliasIndex], function thistype.triggerActionTaunt)
            set this.aliasIndex = this.aliasIndex + 1
            
            return this.aliasIndex
        endmethod
        
        public static method create takes string name, string text, sound whichSound returns thistype
            local thistype this = thistype.allocate()
            set this.name = name
            set this.text = text
            set this.whichSound = whichSound
            
            call this.addAlias(name)
            
            return this
        endmethod
        
        public method onDestroy takes nothing returns nothing
            local integer i = 0
            loop
                exitwhen (i == this.aliasIndex)
                call DestroyTrigger(this.aliasChatTriggers[i])
                set this.aliasChatTriggers[i] = null
                set i = i + 1
            endloop
        endmethod
    endstruct

    
    function AddTaunt takes string name, string text, sound whichSound returns nothing
        call Taunt.create(name, text, whichSound)
    endfunction
    
    function RemoveTaunt takes string name returns nothing
        // TODO Store taunts somehow by name
    endfunction
    
    function GetTaunt takes integer index returns string
        // TODO Store taunts somehow by index
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
    endfunction
    
    function SetTauntCooldownForPlayer takes player whichPlayer, real cooldown returns nothing
    endfunction
    
    function GetTauntCooldownForPlayer takes player whichPlayer returns real
    endfunction
    
    function GetCurrentPlayerTauntCooldown takes player whichPlayer returns real
    endfunction
    
    function ResetTauntCooldownForPlayer takes player whichPlayer returns nothing
    endfunction
    
    function DisplayTaunts takes force whichForce returns nothing
    endfunction
    
    // standard taunts
    
    function AddTauntArcherSayNoMore takes nothing returns nothing
        call AddTaunt("saynomore", "Say no more!", null)
    endfunction

endlibrary
