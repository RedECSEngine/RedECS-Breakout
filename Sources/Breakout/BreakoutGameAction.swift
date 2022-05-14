import RedECS
import RedECSBasicComponents
import Geometry

public enum BreakoutGameAction: Equatable & Codable {
    
    case newGame
    case createNewBall(position: Point, velocity: Point)
    case fireDeflectileFromCurrentPlayerPosition
    case fireDeflectile(position: Point, velocity: Point)
    case ballDied(EntityId)
    case reset
    case noop
    
    
    // Input
    case keyboardInput(KeyboardInputAction)
    case locationInput(Point?)
    case moveLeft
    case moveRight
}

extension BreakoutGameAction {
    static var createNewBallDefault: BreakoutGameAction {
        .createNewBall(position: .init(x: 240, y: 240), velocity: .init(x: 0, y: -1))
    }
}
