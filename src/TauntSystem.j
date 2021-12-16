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
    
    /**
     * \param whichString Can be "all"/"allies"/"enemies"/"friends"/"hostile"/"X" etc. where X is a player number If not specified or empty it will return an empty force.
     */
    function GetForceFromString takes String name, player from, string whichString returns force
        // TODO Remove the chat command from the string first and then analyse
        return GetAllPlayers()
    endfunction
    
    function GetColoredPlayerName takes player whichPlayer returns string
        return GetPlayerName(whichPlayer)
    endfunction
    
    // callback
    function GetTauntMessage takes String name, String text, sound whichSound, player from, force to returns string
        return GetColoredPlayerName(from) + ": " + this.text
    endfunction

    // callback
    function GetTauntMessageMuted takes String name, String text, sound whichSound, player from, player to returns string
        return GetColoredPlayerName(to) + " has muted you or all players."
    endfunction
    
    // callback
    function GetTauntMessageCooldown takes String name, String text, sound whichSound, player from, force to returns string
        return "Wait some time for the next taunt."
    endfunction
    
    // callback
    function GetDisplayTauntsTitle takes player whichPlayer returns string
        return "Taunts:\n"
    endfunction
    
    // callback
    function GetDisplayTaunt takes player whichPlayer, string aliases, string text, sound whichSound returns nothing
        return aliases + ": " + text
    endfunction
    
endlibrary

library TauntSystem requires TauntSystemConfig initializer Init

    globals
        private hashtable tauntHashTable = InitHashTable()
    endglobals
    
    private struct PlayerData
        private player whichPlayer
        private real cooldown
        private force mutedTauntSounds
        private force mutedTauntMessages
        private timer cooldownTimer
        
        private string array disabledTauntAliases
        private integer disabledTauntAliasesIndex
        
        public method enableTauntAlias takes string alias returns nothing
            local boolean found = false
            local integer i = 0
            loop
                exitwhen (i == this.disabledTauntAliasesIndex)
                if (this.disabledTauntAliases[i] == alias) then
                    set this.disabledTauntAliases[i] = null
                    set found = true
                // move elements in the list
                elseif (found and i > 0) then
                    set this.disabledTauntAliases[i - 1] = this.disabledTauntAliases[i]
                endif
                set i = i + 1
            endloop
        endmethod
        
        public method disableTauntAlias takes string alias returns nothing
            set this.disabledTauntAliases[this.disabledTauntAliasesIndex] = alias
            set this.disabledTauntAliasesIndex = this.disabledTauntAliasesIndex + 1
        endmethod
        
        public method isTauntAliasDisabled takes string alias returns boolean
            local integer i = 0
            loop
                exitwhen (i == this.disabledTauntAliasesIndex)
                if (this.disabledTauntAliases[i] == alias) then
                    return true
                endif
                set i = i + 1
            endloop
            
            return false
        endmethod
        
        public method muteTauntSounds takes player from returns nothing
        endmethod
        
        public method muteTauntTexts takes player from returns nothing
        endmethod
        
        public method muteTaunt takes player from returns nothing
            call this.muteTauntSounds(from)
            call this.muteTauntTexts(from)
        endmethod
        
        public boolean isSoundMuted takes player from returns boolean
        endmethod
        
        public method setCooldown takes real cooldown returns nothing
            set this.cooldown = cooldown
        endmethod
        
        public method getCooldown takes nothing returns real
            return this.cooldown
        endmethod
        
        public method isInCooldown takes nothing returns boolean
            return (GetRemainingTime(this.cooldownTimer) <= 0.0)
        endmethod
        
        public method startCooldownTimer takes nothing returns nothing
            call TimerStart(cooldownTimer, cooldown, false, null)
        endmethod
        
        public method getCooldownTimerRemaining takes nothing returns real
            return GetRemainingTime(cooldownTimer)
        endmethod
        
        public static method create takes player whichPlayer, real cooldown returns thistype
            local thistype this = thistype.allocate()
            set this.whichPlayer = whichPlayer
            set this.cooldown = cooldown
            set this.mutedTauntSounds = CreateForce()
            set this.mutedTauntMessages = CreateForce()
            set this.cooldownTimer = CreateTimer()
            
            call SaveInteger(this, 0, GetPlayerId(whichPlayer), tauntHashTable)
            
            return this
        endmethod
        
        public method onDestroy takes nothing returns nothing
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
    
    private struct Alias
        private Taunt taunt
        private trigger aliasChatTrigger
        private string alias
        
        public method getAlias takes nothing returns string
            return this.alias
        endmethod
        
        private static method triggerActionTaunt takes nothing returns nothing
            local thistype this = LoadInteger(0, GetHandleId(GetTriggeringTrigger()), tauntHashTable)
            local force target = GetForceFromString(this.taunt.getName(), GetTriggerPlayer(), GetEnteredChatString())
            
            if (not GetPlayerData(GetTriggerPlayer()).isInCooldown()) then
                call this.taunt.send(GetTriggerPlayer(), target)
                
                call GetPlayerData(GetTriggerPlayer()).startCooldownTimer()
            else
                call DisplayMessage(GetTriggerPlayer(), GetTauntMessageCooldown(this.name, this.text, this.whichSound, GetTriggerPlayer(), target))
            endif
        endmethod
        
        public static method create takes Taunt taunt, String alias returns thistype
            local thistype this = thistype.allocate()
            set this.taunt = taunt
            set this.aliasChatTrigger = CreateTrigger()
            call SaveInteger(this, 0, GetHandleId(aliasChatTrigger), tauntHashTable)
            // TODO chat event
            call TriggerRegisterChatEvent(aliasChatTrigger, TAUNT_SYSTEM_CHAT_PREFIX + alias, false)
            call TriggerAddAction(aliasChatTrigger, function thistype.triggerActionTaunt)
            set this.alias = alias
            
            return this
        endmethod
        
        public method onDestroy takes nothing returns nothing
            call FlushParentKey(GetHandleId(this.aliasChatTrigger), tauntHashTable)
            call DestroyTrigger(this.aliasChatTrigger)
            set this.aliasChatTrigger = null
        endmethod
    endstruct

    private struct Taunt
        private static Taunt array taunts[5000]
        private static integer tauntIndex = 0
    
        private string name
        private string text
        private sound whichSound
        
        private Alias array aliases[100]
        private integer aliasIndex = 0
        
        public method getName takes nothing returns string
            return this.name
        endmethod
        
        public method getText takes nothing returns string
            return this.text
        endmethod
        
        public method getSound takes nothing returns sound
            return this.whichSound
        endmethod
        
        public method send takes player from, force to returns nothing
            local integer i = 0
            loop
                exitwhen (i == MAX_PLAYERS)
                if (IsPlayerInForce(Player(i), to)) then
                    if (not IsPlayerInForce(from, GetPlayerData(Player(i)).getMutedForce())) then
                        call DisplayMessage(Player(i), GetTauntMessage(this.name, this.text, this.whichSound, from, to))
                        call PlaySoundForPlayer(Player(i), this.whichSound)
                    else
                        call DisplayMessage(from, GetTauntMessageMuted(this.name, this.text, this.whichSound, from, Player(i)))
                    endif
                endif
                set i = i + 1
            endloop
        endmethod
        
        public method getAlias takes integer index returns string
            if (index >= this.aliasIndex || index < 0) then
                return ""
            endif
            
            return this.aliases[index].getAlias()
        endmethod
        
        public method countAliases takes nothing returns integer
            return this.aliasIndex
        endmethod
        
        public method addAlias takes string alias returns integer
            set this.aliases[this.aliasIndex] = Alias.create(this, alias)
            set this.aliasIndex = this.aliasIndex + 1
            
            return this.aliasIndex
        endmethod
        
        public method removeAlias takes string alias returns boolean
            local boolean found = false
            local integer i = 0
            loop
                exitwhen (i == this.aliasIndex)
                if (this.aliases[i].getAlias() == alias) then
                    call this.aliases[i].destroy()
                    set this.aliases[i] = 0
                    set found = true
                // move elements in the list
                elseif (found and i > 0) then
                    set this.aliases[i - 1] = this.aliases[i]
                endif
                set i = i + 1
            endloop
        endmethod
        
        private static method addTaunt takes thistype taunt returns nothing
            call thistype.taunts[thistype.tauntIndex] = taunt
            set thistype.tauntIndex = thistype.tauntIndex + 1
        endmethod
        
        public static method create takes string name, string text, sound whichSound returns thistype
            local thistype this = thistype.allocate()
            set this.name = name
            set this.text = text
            set this.whichSound = whichSound
            
            call this.addAlias(name)
            
            call thistype.addTaunt(this)
            
            return this
        endmethod
        
        private static method removeTaunt takes thistype taunt returns nothing
            local boolean found = false
            local integer i = 0
            loop
                exitwhen (i == thistype.tauntIndex)
                if (thistype.taunts[i].getAlias() == alias) then
                    call thistype.taunts[i].destroy()
                    set thistype.taunts[i] = 0
                    set found = true
                // move elements in the list
                elseif (found and i > 0) then
                    set thistype.taunts[i - 1] = thistype.taunts[i]
                endif
                set i = i + 1
            endloop
        endmethod
        
        public method onDestroy takes nothing returns nothing
            local integer i = 0
            loop
                exitwhen (i == this.aliasIndex)
                call this.aliases[i].destroy()
                set i = i + 1
            endloop
            call thistype.removeTaunt(this)
        endmethod
        
        public static method getTauntByName takes string name returns thistype
            local integer i = 0
            loop
                exitwhen (i == thistype.tauntIndex)
                if (thistype.taunts[i].name == name) then
                    return thistype.taunts[i].
                endif
                set i = i + 1
            endloop
            return 0
        endmethod
        
        public static method getTauntByIndex takes integer index returns thistype
            return thistype.taunts[index]
        endmethod
        
        public static method countTaunts takes nothing returns integer
            return thistype.tauntIndex
        endmethod
    endstruct
    
    private function GetTauntByName takes string name returns Taunt
        return Taunt.getTauntByName(name)
    endfunction
    
    private function GetTauntByIndex takes integer index returns Taunt
        return Taunt.getTauntByIndex(index)
    endfunction

    function AddTaunt takes string name, string text, sound whichSound returns nothing
        call Taunt.create(name, text, whichSound)
    endfunction
    
    function RemoveTaunt takes string name returns nothing
        local Taunt taunt = GetTauntByName(name)
        if (taunt != 0) then
            call taunt.destroy()
        endif
    endfunction
    
    function GetTaunt takes integer index returns string
        local Taunt taunt = GetTauntByName(name)
        if (taunt != 0) then
            return taunt.getName()
        endif
    endfunction
    
    function CountTaunts takes nothing returns integer
        return Taunt.countTaunts()
    endfunction
    
    function AddTauntAlias takes string name, string alias returns nothing
        local Taunt taunt = GetTauntByName(name)
        if (taunt != 0) then
            call taunt.addAlias(alias)
        endif
    endfunction
    
    function RemoveTauntAlias takes string name, string alias returns nothing
        local Taunt taunt = GetTauntByName(name)
        if (taunt != 0) then
            call taunt.removeAlias(alias)
        endif
    endfunction
    
    function GetTauntAlias takes string name, integer index returns string
        local Taunt taunt = GetTauntByName(name)
        if (taunt != 0) then
            return taunt.getAlias(index)
        endif
        return ""
    endfunction
    
    function CountTauntAliases takes string name returns integer
        local Taunt taunt = GetTauntByName(name)
        if (taunt != 0) then
            return taunt.countAliases()
        endif
        return 0
    endfunction

    function EnableTauntAliasForPlayer takes string alias, player whichPlayer returns nothing
        call GetPlayerData(whichPlayer).enableTauntAlias(alias)
    endfunction

    function DisableTauntAliasForPlayer takes string alias, player whichPlayer returns nothing`
        call GetPlayerData(whichPlayer).disableTauntAlias(alias)
    endfunction
    
    function IsTauntAliasEnabledForPlayer takes string alias, player whichPlayer returns boolean
        return not GetPlayerData(whichPlayer).isTauntAliasDisabled(alias)
    endfunction
    
    function SendTaunt takes string name, player from, force to returns nothing
        local Taunt taunt = GetTauntByName(name)
        if (taunt != 0) then
            call taunt.send(from, to)
        endif
    endfunction
    
    function MuteTaunts takes player whichPlayer, force from returns nothing
        call GetPlayerData(whichPlayer).muteTaunt(from)
    endfunction
    
    function IsTauntMutedForPlayer takes player whichPlayer, player from returns boolean
        return GetPlayerData(whichPlayer).isTauntMuted(from)
    endfunction
    
    function MuteTauntSounds takes player whichPlayer, force from returns nothing
        call GetPlayerData(whichPlayer).muteTauntSounds(from)
    endfunction
    
    function IsTauntSoundsMutedForPlayer takes player whichPlayer, player from returns boolean
        return GetPlayerData(whichPlayer).isTauntSoundsMuted(from)
    endfunction
    
    function MuteTauntMessages takes player whichPlayer, force from returns nothing
        call GetPlayerData(whichPlayer).muteTauntMessages(from)
    endfunction
    
    function IsTauntMessagesMutedForPlayer takes player whichPlayer, player from returns boolean
        return GetPlayerData(whichPlayer).isTauntMessagesMuted(from)
    endfunction
    
    function UnmuteTaunts takes player whichPlayer, force from returns nothing
    endfunction
    
    function UnmuteTauntSounds takes player whichPlayer, force from returns nothing
    endfunction
    
    function UnmuteTauntMessages takes player whichPlayer, force from returns nothing
    endfunction
    
    function SetTauntCooldownForPlayer takes player whichPlayer, real cooldown returns nothing
        call GetPlayerData(whichPlayer).setCooldown(cooldown)
    endfunction
    
    function GetTauntCooldownForPlayer takes player whichPlayer returns real
        return GetPlayerData(whichPlayer).getCooldown()
    endfunction
    
    function GetCurrentPlayerTauntCooldown takes player whichPlayer returns real
        return GetPlayerData(whichPlayer).getCooldownTimerRemaining()
    endfunction
    
    function ResetTauntCooldownForPlayer takes player whichPlayer returns nothing
        call GetPlayerData(whichPlayer).startCooldownTimer()
    endfunction
    
    function DisplayTaunts takes force whichForce returns nothing
        local integer i = 0
        local integer j = 0
        local Taunt taunt = 0
        loop
            exitwhen (i == bj_MAX_PLAYERS)
            if (IsPlayerInForce(Player(i), whichForce) then
                call DisplayMessage(Player(i), GetDisplayTauntsTitle(Player(i)))
                set j = 0
                loop
                    exitwhen (j == CountTaunts())
                    set taunt = GetTauntByIndex(j)
                    if (IsTauntAliasEnabledForPlayer(Player(i))) then
                        call DisplayMessage(Player(i), GetDisplayTaunt(Player(i), GetTauntAliasesByIndex(j), taunt.getText(), taunt.getSound())
                    endif
                    set j = + 1
                endloop
                set i = i + 1
            endif
        endloop
    endfunction
    
    // standard taunts
    
    function AddTauntArcherSayNoMore takes nothing returns nothing
        call AddTaunt("saynomore", "Say no more!", null)
    endfunction

endlibrary
