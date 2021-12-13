library TauntSystemConfig

    globals
        constant boolean MOCK_SYSTEM_USE_COOLDOWN = true
        constant real MOCK_SYSTEM_COOLDOWN = 15.0
        constant boolean MOCK_SYSTEM_MOCKS_CHAT_COMMAND = true
        constant boolean MOCK_SYSTEM_MOCKSONOFF_CHAT_COMMANDS = true
        constant boolean MOCK_SYSTEM_MUTE_CHAT_COMMAND = true
    endglobals

endlibrary

library TauntSystem requires TauntSystemConfig

    private struct Taunt
        private string name
        private string text
        private sound whichSound
    endstruct

    
    function AddTaunt takes string name, string text, sound whichSound returns nothing
    endfunction
    
    function AddTauntAlias takes string name, string alias returns nothing
    endfunction

    function EnableTauntAliasForPlayer takes string name, string alias returns nothing
    endfunction

    function DisableTauntAliasForPlayer takes string name, string alias returns nothing`
    endfunction
    
    function EnableTauntForPlayer takes string name, player whichPlayer returns nothing
    endfunction
    
    function DisableTauntForPlayer takes string name, player whichPlayer returns nothing
    endfunction
    
    function SendTaunt takes string name, player from, force to returns nothing
    endfunction
    
    function MuteTaunts takes player whichPlayer, force from returns nothing
    endfunction
    
    function MuteTauntSounds takes player whichPlayer, force from returns nothing
    endfunction
    
    function MuteTauntMessages takes player whichPlayer, force from returns nothing
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
