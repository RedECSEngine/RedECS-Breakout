import RedECS

public struct PlayerComponent: GameComponent {
    public var entity: EntityId
    public var projectileTimeout: Double = 0
}
