globals
    constant integer COMMAND_SEND_GOLD = 0
    constant integer COMMAND_SEND_WOOD = 1
    constant integer COMMAND_ATTACK_PLAYER = 2
    constant integer COMMAND_WORKERS_GOLD = 3
    constant integer COMMAND_WORKERS_WOOD = 4
    constant integer COMMAND_TRAIN_FOOTMEN = 5
    constant integer COMMAND_BUILD_WATCH_TOWERS = 6
    constant integer COMMAND_SIEGE = 7
endglobals

function AddHumanAICommands takes nothing returns nothing
    call AddTaunt("gold", "Take this gold!", null)
    call AddTauntAICommand()
    call SetTauntAICommandDataCalculatorSendingPlayer(COMMAND_SEND_GOLD)
    call EnableTauntAICommandForTaunt(COMMAND_SEND_GOLD, "gold")
    call EnableAICommandComputerAlliesForAll(COMMAND_SEND_GOLD)

    call AddTaunt("wood", "Take this wood!", null)
    call AddTauntAICommand()
    call SetTauntAICommandDataCalculatorSendingPlayer(COMMAND_SEND_WOOD)
    call EnableTauntAICommandForTaunt(COMMAND_SEND_WOOD, "wood")
    call EnableAICommandComputerAlliesForAll(COMMAND_WORKERS_WOOD)
    
    call AddTaunt("attack", "Attack!", null)
    call AddTauntAICommand()
    call SetTauntAICommandDataCalculatorTargetPlayer(COMMAND_ATTACK_PLAYER)
    call EnableTauntAICommandForTaunt(COMMAND_ATTACK_PLAYER, "attack")
    call EnableAICommandComputerAlliesForAll(COMMAND_ATTACK_PLAYER)
    
    call AddTaunt("workersgold", "Train more gold workers!", null)
    call AddTauntAICommand()
    call SetTauntAICommandDataCalculatorTargetPlayer(COMMAND_WORKERS_GOLD)
    call EnableTauntAICommandForTaunt(COMMAND_WORKERS_GOLD, "workersgold")
    call EnableAICommandComputerAlliesForAll(COMMAND_WORKERS_GOLD)
    
    call AddTaunt("workerswood", "Train more wood workers!", null)
    call AddTauntAICommand()
    call SetTauntAICommandDataCalculatorTargetPlayer(COMMAND_WORKERS_WOOD)
    call EnableTauntAICommandForTaunt(COMMAND_WORKERS_WOOD, "workerswood")
    call EnableAICommandComputerAlliesForAll(COMMAND_WORKERS_WOOD)
    
    call AddTaunt("footmen", "Train footmen!", null)
    call AddTauntAICommand()
    call SetTauntAICommandDataCalculatorTargetNumber(COMMAND_TRAIN_FOOTMEN)
    call EnableTauntAICommandForTaunt(COMMAND_TRAIN_FOOTMEN, "footmen")
    call EnableAICommandComputerAlliesForAll(COMMAND_TRAIN_FOOTMEN)
    
    call AddTaunt("watchtowers", "Build watch towers!", null)
    call AddTauntAICommand()
    call SetTauntAICommandDataCalculatorTargetNumber(COMMAND_BUILD_WATCH_TOWERS)
    call EnableTauntAICommandForTaunt(COMMAND_BUILD_WATCH_TOWERS, "watchtowers")
    call EnableAICommandComputerAlliesForAll(COMMAND_BUILD_WATCH_TOWERS)
    
    call AddTaunt("siege", "Train siege engines!", null)
    call AddTauntAICommand()
    call SetTauntAICommandDataCalculatorTargetNumber(COMMAND_SIEGE)
    call EnableTauntAICommandForTaunt(COMMAND_SIEGE, "siege")
    call EnableAICommandComputerAlliesForAll(COMMAND_SIEGE)
endfunction
