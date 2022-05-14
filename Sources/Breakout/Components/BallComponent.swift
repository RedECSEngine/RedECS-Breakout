import RedECS

public struct BallComponent: GameComponent {
    public var entity: EntityId
    public var lastEntityHit: EntityId?
    public var hasHitPlayerControlledObject: Bool = false
    public var lives: Int = 3
}
