library TauntSystemConfig requires TauntSystemUtil

    globals
        constant string TAUNT_SYSTEM_CHAT_PREFIX = "-"
        constant boolean TAUNT_SYSTEM_ENABLE_CHAT_COMMAND = true
		constant string TAUNT_SYSTEM_CHAT_COMMAND = "-taunts"
		constant boolean TAUNT_SYSTEM_USE_SPECIFIC_COOLDOWN = false
        constant real TAUNT_SYSTEM_DEFAULT_COOLDOWN = 15.0
		constant boolean TAUNT_SYSTEM_USE_SOUND_LENGTH_COOLDOWN = true
		constant boolean TAUNT_SYSTEM_SHOW_COOLDOWN_MESSAGE = true
		constant boolean TAUNT_SYSTEM_TARGET_ONLY_PLAYING = true
		constant boolean TAUNT_SYSTEM_TARGET_ONLY_HUMAN = false
        // Adds "-mute X" chat commands where X can be the player number or color. All taunts from the player will be muted.
        constant boolean TAUNT_SYSTEM_ENABLE_MUTE_CHAT_COMMAND = true
		constant string TAUNT_SYSTEM_MUTE_CHAT_COMMAND = "-mute"
		constant string TAUNT_SYSTEM_UNMUTE_CHAT_COMMAND = "-unmute"
		constant string TAUNT_SYSTEM_MUTED_CHAT_COMMAND = "-muted"
		constant boolean TAUNT_SYSTEM_ENABLE_QUEST = true
		constant integer TAUNT_SYSTEM_QUEST_TYPE = bj_QUESTTYPE_OPT_DISCOVERED
		constant string TAUNT_SYSTEM_QUEST_ICON = "ReplaceableTextures\\CommandButtons\\BTNTaunt.blp"
    endglobals
    
    /**
     * \param whichString Can be "all"/"allies"/"enemies"/"X" etc. where X is a player number If not specified or empty it will return an empty force.
     */
    function GetForceFromString takes string name, player from, string whichString returns force
		local string target = ExtractChatMessageTarget(name, whichString)
		local integer i
		local force result = null
		local boolean needsToBeFiltered = false
		
		if (target == "all") then
			set result = GetPlayersAllCopy()
			set needsToBeFiltered = true
		elseif (target == "allies") then
			set result = GetPlayersAllies(from)
			set needsToBeFiltered = true
		elseif (target == "enemies") then
			set result = GetPlayersEnemies(from)
			set needsToBeFiltered = true
		endif
		
		if (result == null) then
			set i = 0
			loop
				exitwhen (i == bj_MAX_PLAYERS)
				if (target == I2S(i + 1) or target == GetPlayerColorNameTaunt(GetPlayerColor(Player(i)))) then
					set result = GetForceOfPlayer(Player(i))
				endif
				set i = i + 1
			endloop
		endif
		
		if (result == null) then
			// default is all players
			set result = GetPlayersAllCopy()
			set needsToBeFiltered = true
		endif
		
		// filter for playing and human players only if enabled
		if (needsToBeFiltered and (TAUNT_SYSTEM_TARGET_ONLY_PLAYING or TAUNT_SYSTEM_TARGET_ONLY_HUMAN)) then
			set i = 0
			loop
				exitwhen (i == bj_MAX_PLAYERS)
				if (IsPlayerInForce(Player(i), result) and ((TAUNT_SYSTEM_TARGET_ONLY_PLAYING and GetPlayerSlotState(Player(i)) != PLAYER_SLOT_STATE_PLAYING) or (TAUNT_SYSTEM_TARGET_ONLY_HUMAN and GetPlayerController(Player(i)) != MAP_CONTROL_USER))) then
					call ForceRemovePlayer(result, Player(i))
				endif
				set i = i + 1
			endloop
		endif
	
        return result
    endfunction
    
    // callback
    function GetTauntMessage takes string name, string text, sound whichSound, player from, force to returns string
		if (text != null and StringLength(text) > 0) then
			return GetColoredPlayerNameTaunt(from) + " to " + GetPlayerNamesTaunt(to) + ": \"" + text + "\""
		else
			return GetColoredPlayerNameTaunt(from) + " to " + GetPlayerNamesTaunt(to) + ": (" + name + ")"
		endif
    endfunction

    // callback
    function GetTauntMessageMuted takes string name, string text, sound whichSound, player from, player to returns string
        return GetColoredPlayerNameTaunt(to) + " has muted you or all players."
    endfunction
    
    // callback
    function GetTauntMessageCooldown takes string name, string text, sound whichSound, player from, force to, real cooldownTimerRemaining returns string
        return "Wait " + I2S(R2I(cooldownTimerRemaining)) + " seconds for the next taunt."
    endfunction
	
	// callback
	function GetTauntMessageMute takes player to, force from returns string
		return "Muting: " + GetPlayerNamesTaunt(from)
	endfunction
	
	// callback
	function GetTauntMessageUnmute takes player to, force from returns string
		return "Unmuting: " + GetPlayerNamesTaunt(from)
	endfunction
	
	// callback
	function GetTauntMessageListMuted takes player to, force muted returns string
		return "Muted: " + GetPlayerNamesTaunt(muted)
	endfunction
    
    // callback
    function GetDisplayTauntsTitle takes player whichPlayer returns string
        local string result = "Available taunts:\nX = (1-24,red/blue/green,allies,enemies,all,self)"
		if (TAUNT_SYSTEM_ENABLE_MUTE_CHAT_COMMAND) then
			set result = result + "\n" + TAUNT_SYSTEM_MUTE_CHAT_COMMAND + "/" + TAUNT_SYSTEM_UNMUTE_CHAT_COMMAND + " X: Mutes/unmutes taunts from source(s) X."
			set result = result + "\n" + TAUNT_SYSTEM_MUTED_CHAT_COMMAND + ": Lists muted players."
		endif
		return result
    endfunction
    
    // callback
    function GetDisplayTaunt takes player whichPlayer, string aes, string text, sound whichSound returns string
		if (text != null and StringLength(text) > 0) then
			return TAUNT_SYSTEM_CHAT_PREFIX + aes + " X: " + text
		else
			return TAUNT_SYSTEM_CHAT_PREFIX + aes + " X"
		endif
    endfunction
    
endlibrary

library TauntSystemUtil

	function GetPlayerColorNameTaunt takes playercolor playerColor returns string
		if (playerColor == PLAYER_COLOR_RED) then
			return "red"
		elseif (playerColor == PLAYER_COLOR_BLUE) then
			return "blue"
		elseif (playerColor == PLAYER_COLOR_CYAN) then
			return "cyan"
		elseif (playerColor == PLAYER_COLOR_PURPLE) then
			return "purple"
		elseif (playerColor == PLAYER_COLOR_YELLOW) then
			return "yellow"
		elseif (playerColor == PLAYER_COLOR_ORANGE) then
			return "orange"
		elseif (playerColor == PLAYER_COLOR_GREEN) then
			return "green"
		elseif (playerColor == PLAYER_COLOR_PINK) then
			return "pink"
		elseif (playerColor == PLAYER_COLOR_LIGHT_GRAY) then
			return "lgray"
		elseif (playerColor == PLAYER_COLOR_LIGHT_BLUE) then
			return "lblue"
		elseif (playerColor == PLAYER_COLOR_AQUA) then
			return "aqua"
		elseif (playerColor == PLAYER_COLOR_BROWN) then
			return "brown"
		elseif (playerColor == PLAYER_COLOR_MAROON) then
			return "maroon"
		elseif (playerColor == PLAYER_COLOR_NAVY) then
			return "navy"
		elseif (playerColor == PLAYER_COLOR_TURQUOISE) then
			return "turquoise"
		elseif (playerColor == PLAYER_COLOR_VIOLET) then
			return "violet"
		elseif (playerColor == PLAYER_COLOR_WHEAT) then
			return "wheat"
		elseif (playerColor == PLAYER_COLOR_PEACH) then
			return "peach"
		elseif (playerColor == PLAYER_COLOR_MINT) then
			return "mint"
		elseif (playerColor == PLAYER_COLOR_LAVENDER) then
			return "lavender"
		elseif (playerColor == PLAYER_COLOR_COAL) then
			return "coal"
		elseif (playerColor == PLAYER_COLOR_SNOW) then
			return "snow"
		elseif (playerColor == PLAYER_COLOR_EMERALD) then
			return "emerald"
		elseif (playerColor == PLAYER_COLOR_PEANUT) then
			return "peanut"
		endif

		//Player Neutral: Black |cff2e2d2e

		return "black"
	endfunction

	function PlayerColorToStringTaunt takes playercolor playerColor returns string
		if (playerColor == PLAYER_COLOR_RED) then
			return "00FF0303"
		elseif (playerColor == PLAYER_COLOR_BLUE) then
			return "000042FF"
		elseif (playerColor == PLAYER_COLOR_CYAN) then
			return "001CE6B9"
		elseif (playerColor == PLAYER_COLOR_PURPLE) then
			return "00540081"
		elseif (playerColor == PLAYER_COLOR_YELLOW) then
			return "00FFFC01"
		elseif (playerColor == PLAYER_COLOR_ORANGE) then
			return "00fEBA0E"
		elseif (playerColor == PLAYER_COLOR_GREEN) then
			return "0020C000"
		elseif (playerColor == PLAYER_COLOR_PINK) then
			return "00E55BB0"
		elseif (playerColor == PLAYER_COLOR_LIGHT_GRAY) then
			return "00959697"
		elseif (playerColor == PLAYER_COLOR_LIGHT_BLUE) then
			return "007EBFF1"
		elseif (playerColor == PLAYER_COLOR_AQUA) then
			return "00106246"
		elseif (playerColor == PLAYER_COLOR_BROWN) then
			return "004E2A04"
		elseif (playerColor == PLAYER_COLOR_MAROON) then
			return "ff9c0000"
		elseif (playerColor == PLAYER_COLOR_NAVY) then
			return "ff0000c3"
		elseif (playerColor == PLAYER_COLOR_TURQUOISE) then
			return "ff00ebff"
		elseif (playerColor == PLAYER_COLOR_VIOLET) then
			return "ffbd00ff"
		elseif (playerColor == PLAYER_COLOR_WHEAT) then
			return "ffecce87"
		elseif (playerColor == PLAYER_COLOR_PEACH) then
			return "fff7a58b"
		elseif (playerColor == PLAYER_COLOR_MINT) then
			return "ffbfff81"
		elseif (playerColor == PLAYER_COLOR_LAVENDER) then
			return "ffdbb8eb"
		elseif (playerColor == PLAYER_COLOR_COAL) then
			return "ff4f5055"
		elseif (playerColor == PLAYER_COLOR_SNOW) then
			return "ffecf0ff"
		elseif (playerColor == PLAYER_COLOR_EMERALD) then
			return "ff00781e"
		elseif (playerColor == PLAYER_COLOR_PEANUT) then
			return "ffa56f34"
		endif

		//Player Neutral: Black |cff2e2d2e

		return "ff2e2d2e"
	endfunction
	
	function GetTextWithPlayerColorTaunt takes playercolor playerColor, string text returns string
		return "|c" + PlayerColorToStringTaunt(playerColor) + text + "|r"
	endfunction
	
    function GetColoredPlayerNameTaunt takes player whichPlayer returns string
		return GetTextWithPlayerColorTaunt(GetPlayerColor(whichPlayer), GetPlayerName(whichPlayer))
    endfunction
	
	globals
		private string playerNamesColored = ""
	endglobals
	
	private function ForForceAddPlayerNameColored takes nothing returns nothing
		if (playerNamesColored != null and StringLength(playerNamesColored) > 0) then
			set playerNamesColored = playerNamesColored + ", "
		endif
		set playerNamesColored = playerNamesColored + GetColoredPlayerNameTaunt(GetEnumPlayer())
	endfunction
	
	// TODO not all names if all allies/enemies etc.
	function GetPlayerNamesTaunt takes force whichForce returns string
		local string result = ""
		call ForForce(whichForce, function ForForceAddPlayerNameColored)
		set result = playerNamesColored
		set playerNamesColored = ""
		return result
	endfunction
	
	function GetPlayersAllCopy takes nothing returns force
		local force result = CreateForce()
		local integer i = 0
		loop
			exitwhen (i == bj_MAX_PLAYERS)
			call ForceAddPlayer(result, Player(i))
			set i = i + 1
		endloop
		return result
	endfunction
	
	function StringStartsWith takes string actual, string expectedStart returns boolean
		local integer i = 0
		loop
			exitwhen (i >= StringLength(actual) or i >= StringLength(expectedStart))
			if (SubString(actual, i, i + 1) != SubString(expectedStart, i, i + 1)) then
				return false
			endif
			set i = i + 1
		endloop
		return i >= StringLength(expectedStart)
	endfunction
	
	function ExtractChatMessageTarget takes string name, string whichString returns string
		local string modifiedString = whichString
		local integer i
		local force result = null
		local boolean needsToBeFiltered = false
		
		//call BJDebugMsg("target0: " + modifiedString)
		
		// Remove complete alias.
		if (name != null and StringLength(name) > 0 and SubString(modifiedString, 0, StringLength(name)) == name) then
			set modifiedString = SubString(modifiedString, StringLength(name), StringLength(modifiedString))
		endif
		
		//call BJDebugMsg("target1: " + modifiedString)
		
        // Remove prefix.
		if (TAUNT_SYSTEM_CHAT_PREFIX != null and StringLength(TAUNT_SYSTEM_CHAT_PREFIX) > 0 and SubString(modifiedString, 0, StringLength(TAUNT_SYSTEM_CHAT_PREFIX)) == TAUNT_SYSTEM_CHAT_PREFIX) then
			set modifiedString = SubString(modifiedString, StringLength(TAUNT_SYSTEM_CHAT_PREFIX), StringLength(modifiedString))
		endif
		
		//call BJDebugMsg("target2: " + modifiedString)
		
		// Remove alias.
		if (name != null and StringLength(name) > 0 and SubString(modifiedString, 0, StringLength(name)) == name) then
			set modifiedString = SubString(modifiedString, StringLength(name), StringLength(modifiedString))
		endif
		
		//call BJDebugMsg("target3: " + modifiedString)
		
		// Remove spaces.
		set i = 1
		loop
			exitwhen (i > StringLength(modifiedString) or SubString(modifiedString, i - 1, i) != " ")
			set i = i + 1
		endloop
		
		return SubString(modifiedString, i - 1, StringLength(modifiedString))
	endfunction

endlibrary

library TauntSystem initializer Init requires TauntSystemConfig

    globals
        private hashtable tauntHashTable = InitHashtable()
		private quest array tauntsQuest[28]
    endglobals
	
	private function ForceAddForce takes force target, force source returns nothing
		local integer i = 0
		loop
			exitwhen (i == bj_MAX_PLAYERS)
			if (IsPlayerInForce(Player(i), source)) then
				call ForceAddPlayer(target, Player(i))
			endif
			set i = i + 1
		endloop
	endfunction
	
	private function ForceRemoveForce takes force target, force source returns nothing
		local integer i = 0
		loop
			exitwhen (i == bj_MAX_PLAYERS)
			if (IsPlayerInForce(Player(i), source)) then
				call ForceRemovePlayer(target, Player(i))
			endif
			set i = i + 1
		endloop
	endfunction
    
    private struct PlayerData
		private static PlayerData array playerData[28]
        private player whichPlayer
        private real cooldown
        private force mutedTauntSounds
        private force mutedTauntMessages
        private timer cooldownTimer
        
        private string array disabledTauntAliases[500]
        private integer disabledTauntAliasesIndex
        
        public method enableTauntAlias takes string a returns nothing
            local boolean found = false
            local integer i = 0
            loop
                exitwhen (i == this.disabledTauntAliasesIndex)
                if (this.disabledTauntAliases[i] == a) then
                    set this.disabledTauntAliases[i] = null
                    set found = true
                // move elements in the list
                elseif (found and i > 0) then
                    set this.disabledTauntAliases[i - 1] = this.disabledTauntAliases[i]
                endif
                set i = i + 1
            endloop
        endmethod
        
        public method disableTauntAlias takes string a returns nothing
            set this.disabledTauntAliases[this.disabledTauntAliasesIndex] = a
            set this.disabledTauntAliasesIndex = this.disabledTauntAliasesIndex + 1
        endmethod
        
        public method isTauntAliasDisabled takes string a returns boolean
            local integer i = 0
            loop
                exitwhen (i == this.disabledTauntAliasesIndex)
                if (this.disabledTauntAliases[i] == a) then
                    return true
                endif
                set i = i + 1
            endloop
            
            return false
        endmethod
        
        public method muteTauntSounds takes force from returns nothing
			call ForceAddForce(mutedTauntSounds, from)
        endmethod
        
        public method muteTauntTexts takes force from returns nothing
			call ForceAddForce(mutedTauntSounds, from)
        endmethod
        
        public method muteTaunt takes force from returns nothing
            call this.muteTauntSounds(from)
            call this.muteTauntTexts(from)
			
			call DisplayTextToPlayer(this.whichPlayer, 0.0, 0.0, GetTauntMessageMute(this.whichPlayer, from))
        endmethod
		
		public method unmuteTauntSounds takes force from returns nothing
			call ForceRemoveForce(mutedTauntSounds, from)
        endmethod
        
        public method unmuteTauntTexts takes force from returns nothing
			call ForceRemoveForce(mutedTauntMessages, from)
        endmethod
        
        public method unmuteTaunt takes force from returns nothing
            call this.unmuteTauntSounds(from)
            call this.unmuteTauntTexts(from)
			
			call DisplayTextToPlayer(this.whichPlayer, 0.0, 0.0, GetTauntMessageUnmute(this.whichPlayer, from))
        endmethod
        
        public method isSoundMuted takes player from returns boolean
			return IsPlayerInForce(from, mutedTauntSounds)
        endmethod
		
		public method isTextMuted takes player from returns boolean
			return IsPlayerInForce(from, mutedTauntMessages)
        endmethod
		
		public method isMuted takes player from returns boolean
			return isSoundMuted(from) and isTextMuted(from)
        endmethod
		
		public method displayMuted takes nothing returns nothing
			local force all = CreateForce()
			call ForceAddForce(all, mutedTauntSounds)
			call ForceAddForce(all, mutedTauntMessages)
			call DisplayTextToPlayer(this.whichPlayer, 0.0, 0.0, GetTauntMessageListMuted(this.whichPlayer, all))
			call DestroyForce(all)
			set all = null
		endmethod
        
        public method setCooldown takes real cooldown returns nothing
            set this.cooldown = cooldown
        endmethod
        
        public method getCooldown takes nothing returns real
            return this.cooldown
        endmethod
        
        public method isInCooldown takes nothing returns boolean
            return TimerGetRemaining(this.cooldownTimer) > 0.0
        endmethod
        
        public method startCooldownTimer takes nothing returns nothing
            call TimerStart(cooldownTimer, cooldown, false, null)
        endmethod
		
		public method startCooldownTimerEx takes real cooldown returns nothing
			call TimerStart(cooldownTimer, cooldown, false, null)
		endmethod
		
		public method resetCooldownTimer takes nothing returns nothing
            call TimerStart(cooldownTimer, 0.0, false, null)
        endmethod
        
        public method getCooldownTimerRemaining takes nothing returns real
            return TimerGetRemaining(cooldownTimer)
        endmethod
        
        public static method create takes player whichPlayer, real cooldown returns thistype
            local thistype this = thistype.allocate()
            set this.whichPlayer = whichPlayer
            set this.cooldown = cooldown
            set this.mutedTauntSounds = CreateForce()
            set this.mutedTauntMessages = CreateForce()
            set this.cooldownTimer = CreateTimer()
			
			set thistype.playerData[GetPlayerId(whichPlayer)] = this
            
            return this
        endmethod
        
        public method onDestroy takes nothing returns nothing
			call PauseTimer(this.cooldownTimer)
			call DestroyTimer(this.cooldownTimer)
			call DestroyForce(this.mutedTauntSounds)
			call DestroyForce(this.mutedTauntMessages)
			
			set thistype.playerData[GetPlayerId(whichPlayer)] = 0
        endmethod
		
		public static method getPlayerData takes integer playerId returns thistype
			return thistype.playerData[playerId]
		endmethod
    endstruct
    
    private function GetPlayerData takes player whichPlayer returns PlayerData
		return PlayerData.getPlayerData(GetPlayerId(whichPlayer))
    endfunction
    
	private keyword Taunt
    
    private struct Alias
        private Taunt taunt
        private trigger aChatTrigger
        private string a
        
        public method getAlias takes nothing returns string
            return this.a
        endmethod
        
        private static method triggerActionTaunt takes nothing returns nothing
            local thistype this = LoadInteger(tauntHashTable, GetHandleId(GetTriggeringTrigger()), 0)
            call this.taunt.sendFromPlayer.evaluate(GetTriggerPlayer(), GetEventPlayerChatString())
        endmethod
        
        public static method create takes Taunt taunt, string a returns thistype
            local thistype this = thistype.allocate()
			local integer i = 0
            set this.taunt = taunt
            set this.aChatTrigger = CreateTrigger()
			call SaveInteger(tauntHashTable, GetHandleId(aChatTrigger), 0, this)
            // TODO chat event
			loop
				exitwhen (i == bj_MAX_PLAYERS)
				call TriggerRegisterPlayerChatEvent(aChatTrigger, Player(i), TAUNT_SYSTEM_CHAT_PREFIX + a, false)
				set i = i + 1
			endloop
            call TriggerAddAction(aChatTrigger, function thistype.triggerActionTaunt)
            set this.a = a
            
            return this
        endmethod
        
        public method onDestroy takes nothing returns nothing
            call FlushChildHashtable(tauntHashTable, GetHandleId(this.aChatTrigger))
            call DestroyTrigger(this.aChatTrigger)
            set this.aChatTrigger = null
        endmethod
    endstruct

    private struct Taunt
        private static Taunt array taunts[5000]
        private static integer tauntIndex = 0
    
        private string name
        private string text
        private sound whichSound
        
        private Alias array aes[100]
        private integer aIndex = 0
        
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
                exitwhen (i == bj_MAX_PLAYERS)
                if (IsPlayerInForce(Player(i), to)) then
                    if (not GetPlayerData(Player(i)).isMuted(from)) then
                        call DisplayTextToPlayer(Player(i), 0.0, 0.0, GetTauntMessage(this.name, this.text, this.whichSound, from, to))
						call StartSoundForPlayerBJ(Player(i), this.whichSound)
                    elseif (TAUNT_SYSTEM_SHOW_COOLDOWN_MESSAGE) then
                        call DisplayTextToPlayer(from, 0.0, 0.0, GetTauntMessageMuted(this.name, this.text, this.whichSound, from, Player(i)))
                    endif
                endif
                set i = i + 1
            endloop
        endmethod
		
		public method sendFromPlayer takes player whichPlayer, string msg returns nothing
			local force target = GetForceFromString(this.getName(), whichPlayer, msg)
            
            if (not GetPlayerData(whichPlayer).isInCooldown()) then
                call this.send(GetTriggerPlayer(), target)
                
				if (TAUNT_SYSTEM_USE_SPECIFIC_COOLDOWN) then
					call GetPlayerData(whichPlayer).startCooldownTimer()
				elseif (TAUNT_SYSTEM_USE_SOUND_LENGTH_COOLDOWN) then
					call GetPlayerData(whichPlayer).startCooldownTimerEx(GetSoundDurationBJ(this.whichSound))
                endif
            else
                call DisplayTextToPlayer(whichPlayer, 0.0, 0.0, GetTauntMessageCooldown(this.name, this.text, this.whichSound, whichPlayer, target, GetPlayerData(whichPlayer).getCooldownTimerRemaining()))
            endif
			
			call DestroyForce(target)
			set target = null
		endmethod
        
        public method getAlias takes integer index returns string
            if (index >= this.aIndex or index < 0) then
                return ""
            endif
            
            return this.aes[index].getAlias()
        endmethod
        
        public method countAliases takes nothing returns integer
            return this.aIndex
        endmethod
        
        public method addAlias takes string a returns integer
            set this.aes[this.aIndex] = Alias.create(this, a)
            set this.aIndex = this.aIndex + 1
            
            return this.aIndex
        endmethod
        
        public method removeAlias takes string a returns boolean
            local boolean found = false
            local integer i = 0
            loop
                exitwhen (i == this.aIndex)
                if (this.aes[i].getAlias() == a) then
                    call this.aes[i].destroy()
                    set this.aes[i] = 0
                    set found = true
                // move elements in the list
                elseif (found and i > 0) then
                    set this.aes[i - 1] = this.aes[i]
                endif
                set i = i + 1
            endloop
			return found
        endmethod
		
		public method getAliasesJoinedForPlayer takes player whichPlayer returns string
			local string result = ""
			local integer i = 0
			loop
				exitwhen (i == this.aIndex)
				if (not GetPlayerData(whichPlayer).isTauntAliasDisabled(this.getAlias(i))) then
					if (StringLength(result) == 0) then
						set result = this.getAlias(i)
					else
						set result = result + ", " + this.getAlias(i)
					endif
				endif
				set i = i + 1
			endloop
			return result
		endmethod
        
        private static method addTaunt takes thistype taunt returns nothing
            set thistype.taunts[thistype.tauntIndex] = taunt
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
                if (thistype.taunts[i].name == taunt.name) then
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
                exitwhen (i == this.aIndex)
                call this.aes[i].destroy()
                set i = i + 1
            endloop
            call thistype.removeTaunt(this)
        endmethod
        
        public static method getTauntByName takes string name returns thistype
            local integer i = 0
            loop
                exitwhen (i == thistype.tauntIndex)
                if (thistype.taunts[i].name == name) then
                    return thistype.taunts[i]
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
	
	private function PrintTaunts takes player whichPlayer returns string
		local string result = GetDisplayTauntsTitle(whichPlayer)
        local integer j = 0
        local Taunt taunt = 0
		set j = 0
		loop
			exitwhen (j == Taunt.countTaunts)
			set taunt = GetTauntByIndex(j)
			set result = result + "\n" + GetDisplayTaunt(whichPlayer, taunt.getAliasesJoinedForPlayer(whichPlayer), taunt.getText(), taunt.getSound())
			set j = j + 1
		endloop
		return result
	endfunction
    
	
	private function UpdateTauntsQuest takes nothing returns nothing
		local integer i = 0
		loop
			exitwhen (i == bj_MAX_PLAYERS)
			//if (IsQuestEnabled(tauntsQuest[i]) then
				call QuestSetDescription(tauntsQuest[i], PrintTaunts(Player(i)))
			//endif
			set i = i + 1
		endloop
	endfunction

    function AddTaunt takes string name, string text, sound whichSound returns nothing
        call Taunt.create(name, text, whichSound)
		call UpdateTauntsQuest()
    endfunction
	
	private function CreateSoundFromPath takes string path returns sound
		local sound whichSound = CreateSound( path, false, false, true, 1, 1, "DefaultEAXON" )
		//call SetSoundParamsFromLabel( whichSound, "ArthasYes" )
		call SetSoundDuration( whichSound, 655 )
		call SetSoundChannel( whichSound, 8 )
		call SetSoundVolume( whichSound, 127 )
		return whichSound
	endfunction
	
	function AddTauntWithStandardSound takes string name, string text, string soundPath returns nothing
		call Taunt.create(name, text, CreateSoundFromPath(soundPath))
		call UpdateTauntsQuest()
	endfunction
    
    function RemoveTaunt takes string name returns nothing
        local Taunt taunt = GetTauntByName(name)
        if (taunt != 0) then
            call taunt.destroy()
        endif
		call UpdateTauntsQuest()
    endfunction
    
    function GetTaunt takes integer index returns string
        local Taunt taunt = GetTauntByIndex(index)
        if (taunt != 0) then
            return taunt.getName()
        endif
		return ""
    endfunction
    
    function CountTaunts takes nothing returns integer
        return Taunt.countTaunts()
    endfunction
    
    function AddTauntAlias takes string name, string a returns nothing
        local Taunt taunt = GetTauntByName(name)
        if (taunt != 0) then
            call taunt.addAlias(a)
			call UpdateTauntsQuest()
        endif
    endfunction
    
    function RemoveTauntAlias takes string name, string a returns nothing
        local Taunt taunt = GetTauntByName(name)
        if (taunt != 0) then
            call taunt.removeAlias(a)
			call UpdateTauntsQuest()
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

    function EnableTauntAliasForPlayer takes string a, player whichPlayer returns nothing
        call GetPlayerData(whichPlayer).enableTauntAlias(a)
		call UpdateTauntsQuest()
    endfunction

    function DisableTauntAliasForPlayer takes string a, player whichPlayer returns nothing
        call GetPlayerData(whichPlayer).disableTauntAlias(a)
		call UpdateTauntsQuest()
    endfunction
    
    function IsTauntAliasEnabledForPlayer takes string a, player whichPlayer returns boolean
        return not GetPlayerData(whichPlayer).isTauntAliasDisabled(a)
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
        return GetPlayerData(whichPlayer).isMuted(from)
    endfunction
    
    function MuteTauntSounds takes player whichPlayer, force from returns nothing
        call GetPlayerData(whichPlayer).muteTauntSounds(from)
    endfunction
    
    function IsTauntSoundsMutedForPlayer takes player whichPlayer, player from returns boolean
        return GetPlayerData(whichPlayer).isSoundMuted(from)
    endfunction
    
    function MuteTauntMessages takes player whichPlayer, force from returns nothing
        call GetPlayerData(whichPlayer).muteTauntTexts(from)
    endfunction
    
    function IsTauntMessagesMutedForPlayer takes player whichPlayer, player from returns boolean
        return GetPlayerData(whichPlayer).isTextMuted(from)
    endfunction
    
    function UnmuteTaunts takes player whichPlayer, force from returns nothing
		call GetPlayerData(whichPlayer).unmuteTaunt(from)
    endfunction
    
    function UnmuteTauntSounds takes player whichPlayer, force from returns nothing
		call GetPlayerData(whichPlayer).unmuteTauntSounds(from)
    endfunction
    
    function UnmuteTauntMessages takes player whichPlayer, force from returns nothing
		call GetPlayerData(whichPlayer).unmuteTauntTexts(from)
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
        call GetPlayerData(whichPlayer).resetCooldownTimer()
    endfunction
	
    function DisplayTaunts takes force whichForce returns nothing
        local integer i = 0
        loop
            exitwhen (i == bj_MAX_PLAYERS)
            if (IsPlayerInForce(Player(i), whichForce)) then
                call DisplayTextToPlayer(Player(i), 0.0, 0.0,PrintTaunts(Player(i)))
            endif
			set i = i + 1
        endloop
    endfunction
    
    // standard taunts
    
    function AddTauntArthasOfCourse takes nothing returns nothing
        call AddTauntWithStandardSound("ofcourse", "Of course!", "Units/Human/Arthas/ArthasYes1.flac")
    endfunction
	
	function AddTauntPeasantHelp takes nothing returns nothing
		call AddTauntWithStandardSound("help", "Help, help, I am being repressed!", "Units/Human/Peasant/PeasantPissed3.flac")
	endfunction
	
	// init
	
	private function InitPlayerData takes nothing returns nothing
        call PlayerData.create(GetEnumPlayer(), TAUNT_SYSTEM_DEFAULT_COOLDOWN)
    endfunction
	
	private function TriggerConditionTauntsChatCommand takes nothing returns boolean
		return StringStartsWith(GetEventPlayerChatString(), TAUNT_SYSTEM_CHAT_COMMAND)
	endfunction
	
	private function TriggerActionTauntsChatCommand takes nothing returns nothing
		local force whichForce = GetForceOfPlayer(GetTriggerPlayer())
		call DisplayTaunts(whichForce)
		call DestroyForce(whichForce)
		set whichForce = null
	endfunction
	
	private function InitTauntsChatCommandTrigger takes nothing returns nothing
		local trigger tauntsChatCommandTrigger = CreateTrigger()
		local integer i = 0
		loop
			exitwhen (i == bj_MAX_PLAYERS)
			call TriggerRegisterPlayerChatEvent(tauntsChatCommandTrigger, Player(i), TAUNT_SYSTEM_CHAT_COMMAND, true)
			set i = i + 1
		endloop
		call TriggerAddCondition(tauntsChatCommandTrigger, Condition(function TriggerConditionTauntsChatCommand))
		call TriggerAddAction(tauntsChatCommandTrigger, function TriggerActionTauntsChatCommand)
	endfunction
	
	private function TriggerConditionTauntsMuteChatCommand takes nothing returns boolean
		return StringStartsWith(GetEventPlayerChatString(), TAUNT_SYSTEM_MUTE_CHAT_COMMAND) and GetEventPlayerChatString() != TAUNT_SYSTEM_MUTED_CHAT_COMMAND
	endfunction
	
	private function TriggerActionTauntsMuteChatCommand takes nothing returns nothing
		local force whichForce = GetForceFromString(TAUNT_SYSTEM_MUTE_CHAT_COMMAND, GetTriggerPlayer(), GetEventPlayerChatString())
		call ForceRemovePlayer(whichForce, GetTriggerPlayer())
		call GetPlayerData(GetTriggerPlayer()).muteTaunt(whichForce)
		call DestroyForce(whichForce)
		set whichForce = null
	endfunction
	
	private function InitTauntsMuteChatCommandTrigger takes nothing returns nothing
		local trigger tauntsMuteChatCommandTrigger = CreateTrigger()
		local integer i = 0
		loop
			exitwhen (i == bj_MAX_PLAYERS)
			call TriggerRegisterPlayerChatEvent(tauntsMuteChatCommandTrigger, Player(i), TAUNT_SYSTEM_MUTE_CHAT_COMMAND, false)
			set i = i + 1
		endloop
		call TriggerAddCondition(tauntsMuteChatCommandTrigger, Condition(function TriggerConditionTauntsMuteChatCommand))
		call TriggerAddAction(tauntsMuteChatCommandTrigger, function TriggerActionTauntsMuteChatCommand)
	endfunction
	
	private function TriggerConditionTauntsUnmuteChatCommand takes nothing returns boolean
		return StringStartsWith(GetEventPlayerChatString(), TAUNT_SYSTEM_UNMUTE_CHAT_COMMAND)
	endfunction
	
	private function TriggerActionTauntsUnmuteChatCommand takes nothing returns nothing
		local force whichForce = GetForceFromString(TAUNT_SYSTEM_UNMUTE_CHAT_COMMAND, GetTriggerPlayer(), GetEventPlayerChatString())
		call ForceRemovePlayer(whichForce, GetTriggerPlayer())
		call GetPlayerData(GetTriggerPlayer()).unmuteTaunt(whichForce)
		call DestroyForce(whichForce)
		set whichForce = null
	endfunction
	
	private function InitTauntsUnmuteChatCommandTrigger takes nothing returns nothing
		local trigger tauntsUnmuteChatCommandTrigger = CreateTrigger()
		local integer i = 0
		loop
			exitwhen (i == bj_MAX_PLAYERS)
			call TriggerRegisterPlayerChatEvent(tauntsUnmuteChatCommandTrigger, Player(i), TAUNT_SYSTEM_UNMUTE_CHAT_COMMAND, false)
			set i = i + 1
		endloop
		call TriggerAddCondition(tauntsUnmuteChatCommandTrigger, Condition(function TriggerConditionTauntsUnmuteChatCommand))
		call TriggerAddAction(tauntsUnmuteChatCommandTrigger, function TriggerActionTauntsUnmuteChatCommand)
	endfunction
	
	private function TriggerConditionTauntsMutedChatCommand takes nothing returns boolean
		return StringStartsWith(GetEventPlayerChatString(), TAUNT_SYSTEM_MUTED_CHAT_COMMAND)
	endfunction
	
	private function TriggerActionTauntsMutedChatCommand takes nothing returns nothing
		call GetPlayerData(GetTriggerPlayer()).displayMuted()
	endfunction
	
	private function InitTauntsMutedChatCommandTrigger takes nothing returns nothing
		local trigger tauntsUnmuteChatCommandTrigger = CreateTrigger()
		local integer i = 0
		loop
			exitwhen (i == bj_MAX_PLAYERS)
			call TriggerRegisterPlayerChatEvent(tauntsUnmuteChatCommandTrigger, Player(i), TAUNT_SYSTEM_MUTED_CHAT_COMMAND, false)
			set i = i + 1
		endloop
		call TriggerAddCondition(tauntsUnmuteChatCommandTrigger, Condition(function TriggerConditionTauntsMutedChatCommand))
		call TriggerAddAction(tauntsUnmuteChatCommandTrigger, function TriggerActionTauntsMutedChatCommand)
	endfunction
	
	private function InitTauntsQuest takes nothing returns nothing
		local boolean required   = (TAUNT_SYSTEM_QUEST_TYPE == bj_QUESTTYPE_REQ_DISCOVERED) or (TAUNT_SYSTEM_QUEST_TYPE == bj_QUESTTYPE_REQ_UNDISCOVERED)
		local boolean discovered = (TAUNT_SYSTEM_QUEST_TYPE == bj_QUESTTYPE_REQ_DISCOVERED) or (TAUNT_SYSTEM_QUEST_TYPE == bj_QUESTTYPE_OPT_DISCOVERED)
		local integer i = 0
		loop
			exitwhen (i == bj_MAX_PLAYERS)
			set tauntsQuest[i] = CreateQuest()
			call QuestSetTitle(tauntsQuest[i], "Taunts")
			call QuestSetDescription(tauntsQuest[i], "")
			call QuestSetIconPath(tauntsQuest[i], TAUNT_SYSTEM_QUEST_ICON)
			call QuestSetEnabled(tauntsQuest[i], false)

			if (Player(i) == GetLocalPlayer()) then			
				call QuestSetRequired(tauntsQuest[i], required)
				call QuestSetDiscovered(tauntsQuest[i], discovered)
				call QuestSetEnabled(tauntsQuest[i], true)
				call QuestSetCompleted(tauntsQuest[i], false)
			endif
			
			call CreateQuestItemBJ(tauntsQuest[i], "Creator: Baradé")
			set i = i + 1
		endloop
		call UpdateTauntsQuest()
	endfunction
    
    private function Init takes nothing returns nothing
        call ForForce(GetPlayersAll(), function InitPlayerData)
		
		if (TAUNT_SYSTEM_ENABLE_CHAT_COMMAND) then
			call InitTauntsChatCommandTrigger()
		endif
		
		if (TAUNT_SYSTEM_ENABLE_MUTE_CHAT_COMMAND) then
			call InitTauntsMuteChatCommandTrigger()
			call InitTauntsUnmuteChatCommandTrigger()
			call InitTauntsMutedChatCommandTrigger()
		endif
		
		if (TAUNT_SYSTEM_ENABLE_QUEST) then
			call InitTauntsQuest()
		endif
    endfunction

endlibrary
