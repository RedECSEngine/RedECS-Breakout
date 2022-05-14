//
//  BreakoutCoreReducer.swift
//  
//
//  Created by K N on 2022-05-13.
//

import RedECS
import RedECSBasicComponents

public let breakoutCoreReducer: AnyReducer<
    BreakoutGameState,
    BreakoutGameAction,
    Void
> = (
    zip(
        BreakoutBoundsReducer(),
        BreakoutInputReducer(),
        BlockCollisionReducer(),
        PlayerCollisionReducer(),
        BreakoutGameLogicReducer(),
        
        // Wild mode-only reducers
        zip(
            WildModeDeflectileFiringReducer(),
            WildModeCollisionReducer(),
            WildModeBallFiringReducer().throttle(300)
        )
        .filter({ state, action in state.mode == .wild })
    )
    
    + OperationReducer()
        .pullback(toLocalState: \.operationContext)
    + MovementReducer()
        .pullback(toLocalState: \.movementContext)
    + MomentumReducer()
        .pullback(toLocalState: \.momentumContext)
    + KeyboardInputReducer()
        .pullback(
            toLocalState: \.keyboardInputContext,
            toLocalAction: { globalAction in
                switch globalAction {
                case .keyboardInput(let keyAction):
                    return keyAction
                default:
                    return nil
                }
            },
            toGlobalAction: { .keyboardInput($0) }
        )
    + KeyboardKeyMapReducer()
        .pullback(
            toLocalState: \.keyboardInputContext
        )
).eraseToAnyReducer()
