import RedECS
import RedECSBasicComponents
import RedECSRenderingComponents
import Geometry
import RealModule

public struct BreakoutInputReducer: Reducer {
    public func reduce(
        state: inout BreakoutGameState,
        delta: Double,
        environment: Void
    ) -> GameEffect<BreakoutGameState, BreakoutGameAction> {
        
// movement based on last mouse input
//        guard let location = state.lastInputLocation,
//                let playerPosition = state.transform[BreakoutConstants.playerId]?.position else {
//            return .none
//        }
//
//        let locationX = location.x - (BreakoutConstants.paddleSize.width / 2)
//        if abs(playerPosition.x - locationX) > 3 {
//            if playerPosition.x < locationX {
//                return .game(.moveRight)
//            } else if playerPosition.x > locationX {
//                return .game(.moveLeft)
//            }
//        }
        
        return .none
    }
    
    public func reduce(
        state: inout BreakoutGameState,
        action: BreakoutGameAction,
        environment: Void
    ) -> GameEffect<BreakoutGameState, BreakoutGameAction> {
        switch action {
        case .moveLeft:
            guard var playerMovement = state.movement[BreakoutConstants.playerId] else { break }
            playerMovement.velocity.x -= 1
            state.movement[BreakoutConstants.playerId] = playerMovement
        case .moveRight:
            guard var playerMovement = state.movement[BreakoutConstants.playerId] else { break }
            playerMovement.velocity.x += 1
            state.movement[BreakoutConstants.playerId] = playerMovement
        case .keyboardInput:
//            state.lastInputLocation = nil
            return .none
        case .locationInput(let location):
//            state.lastInputLocation = location
            break
            
        case .hud(let hudAction):
            switch hudAction {
            case .elementTapped(let element):
                switch element {
                case .score, .lives: break
                case .leftButton:
                    return .game(.moveLeft)
                case .rightButton:
                    return .game(.moveRight)
                case .shootButton:
                    return .game(.fireDeflectileFromCurrentPlayerPosition)
                }
            case .input:
                break
            }
        default:
            break
        }
        return .none
    }
}
