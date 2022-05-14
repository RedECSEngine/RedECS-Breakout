import RedECS

public struct BlockComponent: GameComponent {
    public var entity: EntityId
    public var lives: Int = 1
    public var timeSinceFiring: Double = 0
}
