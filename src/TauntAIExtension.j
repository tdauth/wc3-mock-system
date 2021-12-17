/**
 * Extension for the Taunt System which allows players to send AI commands to each other which might affect the behavior of their AI scripts.
 *
 * Add this library to your custom map script to provide the functions.
 */
library TauntAIExtension initializer Init requires TauntSystem

    globals
        constant integer MAX_TAUNT_AI_COMMANDS = 10
        
        private trigger callbackTrigger = CreateTrigger()
        private integer callbackAiCommand
        private integer callbackAiData
    endglobals

    private function TauntCallbackSendAiCommand takes nothing returns nothing
        local TauntAICommand tauntAICommand = 0
        local integer i = 0
        local integer j = 0
        local integer data = 0
        
        set j = 0
        loop
            exitwhen (j == TauntAICommand.getTauntAICommandCount())
            set tauntAICommand = GetTauntAICommand(j)
            if (tauntAICommand.isEnabledForTaunt(GetTriggerTaunt())) then
                loop
                    exitwhen (i == bj_MAX_PLAYERS)
                    if (IsPlayerInForce(Player(i), GetTriggerTauntTo()) and tauntAICommand.isEnabled(GetTriggerTauntFrom(), Player(i)) then
                        set data = tauntAICommand.getDataCalculator().evaluate(GetTriggerTaunt(), j, GetTriggerTauntFrom(), Player(i))
                        call CommandAI(Player(i), j, data)
                        set callbackAiCommand = j
                        set callbackAiData = data
                        call ConditionalTriggerExecute(callbackTrigger)
                    set i = i + 1
                endloop
            endif
            set j = j + 1
        endloop
    endfunction

    private function Init takes nothing returns nothing
        call RegisterTauntCallback(function TauntCallbackSendAiCommand)
    endfunction
    
    private function Index2D takes integer value0, integer value1, integer maxValue1 returns integer
		return (value0 * maxValue1) + value1
	endfunction
	
	function interface TauntAICommandDataCalculator takes string name, integer command, player from, force to returns integer
	
	private function dataCalculatorDefault takes string name, integer command, player from, force to returns integer
        return GetPlayerId(from)
    endfunction
    
    private function GetTauntAICommandTargetPlayerNumberFromString takes string whichString returns integer
        local integer i = StringLength(whichString)
        loop
            exitwhen (i == 0)
            if (SubString(whichString, i - 1, i)  == " ") then
                return I2S(SubString(whichString, i, StringLength(whichString)))
            endif
            set i = i + 1
        endloop
        return -1
    endfunction
    
    private function dataCalculatorTargetPlayer takes string name, integer command, player from, force to returns integer
        local integer targetPlayerNumber = GetTauntAICommandTargetPlayerNumberFromString(GetEventPlayerChatString())
        if (targetPlayerNumber == -1) then
            return GetPlayerId(from)
        endif
        return targetPlayerNumber - 1
    endfunction
    
    private function dataCalculatorTargetNumber takes string name, integer command, player from, force to returns integer
        local integer targetNumber = GetTauntAICommandTargetPlayerNumberFromString(GetEventPlayerChatString())
        if (targetNumber < 0) then
            return 0
        endif
        return targetNumber
    endfunction
    
    private struct TauntAICommand
        private static TauntAICommand array tauntAICommands[5000]´
        private static integer tauntAICommandsIndex = 0
        
        private TauntAICommandDataCalculator dataCalculator
        private string array enabledForTaunts[1000]
        private integer enabledForTauntsIndex = 0
        private boolean enabledMatrix[28 * 28]
        
        public method setDataCalculator takes TauntAICommandDataCalculator dataCalculator returns nothing
            set this.dataCalculator = dataCalculator
        endmethod
        
        public method getDataCalculator takes nothing returns TauntAICommandDataCalculator
            return this.dataCalculator
        endmethod
        
        public method enableForTaunt takes string name returns nothing
            set this.enabledForTaunts[this.enabledForTauntsIndex] = name
            set this.enabledForTauntsIndex = this.enabledForTauntsIndex + 1
        endmethod
        
        public method disableForTaunt takes string name returns nothing
            local boolean found = false
            local integer i = 0
            loop
                exitwhen (i == this.enabledForTauntsIndex)
                if (this.enabledForTaunts[i].name == name) then
                    set this.enabledForTaunts[i] = null
                    set found = true
                // move elements in the list
                elseif (found and i > 0) then
                    set this.enabledForTaunts[i - 1] = this.enabledForTaunts[i]
                endif
                set i = i + 1
            endloop
            if (found) then
                set this.enabledForTauntsIndex = this.enabledForTauntsIndex - 1
            endif
        endmethod
        
        public method isEnabledForTaunt takes string name returns boolean
            local integer i = 0
            loop
                exitwhen (i == this.enabledForTauntsIndex)
                if (this.enabledForTaunts[i] == name) then
                    return true
                endif
                set i = i + 1
            endloop
            return false
        endmethod
        
        public method isEnabled takes player from, player to returns boolean
            return not this.enabledMatrix[Index2D(GetPlayerId(from), GetPlayerId(to), bj_MAX_PLAYERS)]
        endmethod
        
        public method enable takes player from, player to returns nothing
            set this.enabledMatrix[Index2D(GetPlayerId(from), GetPlayerId(to), bj_MAX_PLAYERS)] = false
        endmethod
        
        public method disable takes player from, player to returns nothing
            set this.enabledMatrix[Index2D(GetPlayerId(from), GetPlayerId(to), bj_MAX_PLAYERS)] = true
        endmethod
        
        public method enableForForce takes force from, force to returns nothing
            local integer i = 0
            local integer j = 0
            loop
                exitwhen (i == bj_MAX_PLAYERS)
                if (IsPlayerInForce(Player(i), from)) then
                    set j = 0
                    loop
                        exitwhen (j == bj_MAX_PLAYERS)
                        if (IsPlayerInForce(Player(j), to)) then
                            call this.enable(Player(i), Player(j))
                        endif
                        set i = j + 1
                    endloop
                    set i = i + 1
                endif
            endloop
        endmethod
        
        public method disableForForce takes force from, force to returns nothing
            local integer i = 0
            local integer j = 0
            loop
                exitwhen (i == bj_MAX_PLAYERS)
                if (IsPlayerInForce(Player(i), from)) then
                    set j = 0
                    loop
                        exitwhen (j == bj_MAX_PLAYERS)
                        if (IsPlayerInForce(Player(j), to)) then
                            call this.disable(Player(i), Player(j))
                        endif
                        set i = j + 1
                    endloop
                    set i = i + 1
                endif
            endloop
        endmethod
        
        public static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.dataCalculator = dataCalculatorDefault
            set thistype.tauntAICommands[thistype.tauntAICommandsIndex] = this
            set thistype.tauntAICommandsIndex = thistype.tauntAICommandsIndex + 1
            
            return this
        endmethod
        
        public method onDestroy takes nothing returns nothing
            // TODO Remove
        endmethod
        
        public static method getTauntAICommand takes integer command returns thistype
            return thistype.tauntAICommands[command]
        endmethod
        
        public static method getTauntAICommandCount takes nothing returns integer
            return thistype.tauntAICommandsIndex
        endmethod
        
    endstruct
    
    private function GetTauntAICommand takes integer command returns TauntAICommand
        return TauntAICommand.getTauntAICommand(command)
    endfunction
    
    private function GetTauntAICommandCount takes nothing returns integer
        return TauntAICommand.getTauntAICommandCount()
    endfunction

    function AddTauntAICommand takes nothing returns integer
        call TauntAICommand.create()
        return GetTauntAICommandCount() - 1
    endfunction
    
    function SetTauntAICommandDataCalculator takes integer command, TauntAICommandDataCalculator dataCalculator returns nothing
        local TauntAICommand tauntAICommand = GetTauntAICommand(command)
        if (tauntAICommand != 0) then
            call tauntAICommand.setDataCalculator(dataCalculator)
        endif
    endfunction
    
    function SetTauntAICommandDataCalculatorSendingPlayer takes integer command returns nothing
        call SetTauntAICommandDataCalculator(command, function dataCalculatorDefault)
    endfunction
    
    function SetTauntAICommandDataCalculatorTargetPlayer takes integer command returns nothing
        call SetTauntAICommandDataCalculator(command, function dataCalculatorTargetPlayer)
    endfunction
    
    function SetTauntAICommandDataCalculatorTargetNumber takes integer command returns nothing
        call SetTauntAICommandDataCalculator(command, function dataCalculatorTargetNumber)
    endfunction
    
    function EnableTauntAICommandForTaunt takes integer command, string name returns nothing
        local TauntAICommand tauntAICommand = GetTauntAICommand(command)
        if (tauntAICommand != 0) then
            call tauntAICommand.enableForTaunt(name)
        endif
    endfunction
    
    function DisableTauntAICommandForTaunt takes integer command, string name returns nothing
        local TauntAICommand tauntAICommand = GetTauntAICommand(command)
        if (tauntAICommand != 0) then
            call tauntAICommand.disableForTaunt(name)
        endif
    endfunction

    function IsTauntAICommandEnabledForTaunt takes integer command, string name returns boolean
        local TauntAICommand tauntAICommand = GetTauntAICommand(command)
        if (tauntAICommand != 0) then
            return tauntAICommand.isEnabledForTaunt(name)
        endif
        
        return false
    endfunction
    
    function EnableTauntAICommandForPlayer takes integer command, player from, player to returns nothing
        local TauntAICommand tauntAICommand = GetTauntAICommand(command)
        if (tauntAICommand != 0) then
            call tauntAICommand.enable(from, to)
        endif
    endfunction
    
    function DisableTauntAICommandForPlayer takes integer command, player from, player to returns nothing
        local TauntAICommand tauntAICommand = GetTauntAICommand(command)
        if (tauntAICommand != 0) then
            call tauntAICommand.disable(from, to)
        endif
    endfunction

    function IsTauntAICommandEnabledForPlayer takes integer command, player from, player to returns boolean
        local TauntAICommand tauntAICommand = GetTauntAICommand(command)
        if (tauntAICommand != 0) then
            return tauntAICommand.isEnabled(from, to)
        endif
        
        return false
    endfunction

    function EnableAICommandComputerAllies takes integer command, player from returns nothing
        local TauntAICommand tauntAICommand = GetTauntAICommand(command)
        local force allies = GetPlayersAllies(from)
        if (tauntAICommand != 0) then
            call tauntAICommand.enableForForce(from, allies)
        endif
        call DestroyForce(allies)
        set allies = null
    endfunction
    
    function EnableAICommandComputerAlliesForAll takes integer command returns nothing
        local TauntAICommand tauntAICommand = GetTauntAICommand(command)
        local integer i = 0
        local integer j = 0
        if (tauntAICommand != 0) then
            loop
                exitwhen (i == bj_MAX_PLAYERS)
                set j = 0
                loop
                    exitwhen (j == bj_MAX_PLAYERS)
                    if (IsPlayerAlly(Player(i), Player(j))) then
                        call tauntAICommand.enable(Player(i), Player(j))
                    endif
                    set i = j + 1
                endloop
                set i = i + 1
            endloop
        endif
    endfunction
    
    function GetTriggerTauntAICommand takes nothing returns integer
        return callbackAiCommand
    endfunction
    
    function GetTriggerTauntAIData takes nothing returns integer
        return callbackAiData
    endfunction
    
    function RegisterTauntAICommandCallback takes code func returns nothing
        call TriggerAddAction(callbackTrigger, func)
    endfunction
    
    function UnregisterAllTauntAICommandCallbacks takes nothing returns nothing
        call TriggerClearActions(callbackTrigger)
    endfunction
    

endlibrary
