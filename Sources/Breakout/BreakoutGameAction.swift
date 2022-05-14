import RedECS
import RedECSBasicComponents
import Geometry

public enum BreakoutGameAction: Equatable & Codable {
    
    case newGame
    case createNewBall
    case ballDied(EntityId)
    case reset
    
    
    // Input
    case keyboardInput(KeyboardInputAction)
    case locationInput(Point?)
    case moveLeft
    case moveRight
}
