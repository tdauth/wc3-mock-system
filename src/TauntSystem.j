library TauntSystemConfig

    globals
        constant string MOCK_SYSTEM_CHAT_PREFIX = "-"
        constant boolean MOCK_SYSTEM_USE_COOLDOWN = true
        constant real MOCK_SYSTEM_COOLDOWN = 15.0
        constant boolean MOCK_SYSTEM_MOCKS_CHAT_COMMAND = true
        constant boolean MOCK_SYSTEM_MOCKSONOFF_CHAT_COMMANDS = true
        constant boolean MOCK_SYSTEM_MUTE_CHAT_COMMAND = true
    endglobals

endlibrary

library TauntSystem requires TauntSystemConfig

    globals
        private hashtable tauntHashTable = InitHashTable()
    endglobals

    private struct Taunt
        private string name
        private string text
        private sound whichSound
        
        private trigger array chatTriggers[100]
        private string array aliases[100]
        private integer aliasIndex = 0
        
        public method send takes force whichForce returns nothing
        endmethod
        
        public static method create takes string name, string text, sound whichSound returns thistype
            local thistype this = thistype.allocate()
            set this.name = name
            set this.text = text
            set this.whichSound = whichSound
            
            set this.chatTriggers[0] = CreateTrigger()
            // TODO Event and condition
            
            return this
        endmethod
        
        public method onDestroy takes nothing returns nothing
        endmethod
    endstruct

    
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
    endfunction
    
    function DisplayTaunts takes force whichForce returns nothing
    endfunction
    
    // standard taunts
    
    function AddTauntArcherSayNoMore takes nothing returns nothing
        call AddTaunt("saynomore", "Say no more!", null)
    endfunction

endlibrary
