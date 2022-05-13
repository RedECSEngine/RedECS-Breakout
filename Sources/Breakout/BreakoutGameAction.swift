import RedECSBasicComponents
import Geometry

public enum BreakoutGameAction: Equatable & Codable {
    case newGame
    case keyboardInput(KeyboardInputAction)
    case locationInput(Point?)
    case moveLeft
    case moveRight
}
