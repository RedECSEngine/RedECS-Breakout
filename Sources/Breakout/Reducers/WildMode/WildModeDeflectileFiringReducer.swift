import RedECS
import RedECSBasicComponents
import RedECSRenderingComponents
import Geometry

public struct WildModeDeflectileFiringReducer: Reducer {
    public func reduce(
        state: inout BreakoutGameState,
        delta: Double,
        environment: Void
    ) -> BreakoutGameEffect {
        if var player = state.player[BreakoutConstants.playerId] {
            player.projectileTimeout += delta
            state.player[BreakoutConstants.playerId] = player
        }
        return .none
    }
    
    public func reduce(
        state: inout BreakoutGameState,
        action: BreakoutGameAction,
        environment: Void
    ) -> BreakoutGameEffect {
        switch action {
        case .fireDeflectileFromCurrentPlayerPosition:
            guard let player = state.player[BreakoutConstants.playerId],
                  player.projectileTimeout > BreakoutConstants.playerProjectileTimeout,
                  let transform = state.transform[BreakoutConstants.playerId] else {
                return .none
            }
            state.score -= BreakoutConstants.deflectileCost
            state.player[BreakoutConstants.playerId]?.projectileTimeout = 0
            return .game(.fireDeflectile(position: transform.position, velocity: .init(x: 0, y: 0.75)))
        case .fireDeflectile(let position, let velocity):
            return generateDeflectile(position: position, velocity: velocity)
        default:
            break
        }
        return .none
    }
}

func generateDeflectile(position: Point, velocity: Point) -> BreakoutGameEffect {
    let deflectileId: EntityId = newEntityId(prefix: "deflectile")
    let shape = ShapeComponent(
        entity: deflectileId,
        shape: .polygon(Path(points: [
            Point(x: 0, y: BreakoutConstants.deflectileSize.height),
            Point(x: BreakoutConstants.deflectileSize.width, y: BreakoutConstants.deflectileSize.height),
            Point(x: BreakoutConstants.deflectileSize.width, y: 0),
            Point(x: 0, y: 0)
        ]))
    )
    let transform = TransformComponent(
        entity: deflectileId,
        position: position
    )
    let movement = MovementComponent(
        entity: deflectileId,
        velocity: .zero,
        travelSpeed: BreakoutConstants.deflectileSpeed
    )
    let momentum = MomentumComponent(entity: deflectileId, velocity: velocity)
    return .many([
        .system(.addEntity(deflectileId, ["deflectile"])),
        .system(.addComponent(shape, into: \.shape)),
        .system(.addComponent(transform, into: \.transform)),
        .system(.addComponent(movement, into: \.movement)),
        .system(.addComponent(momentum, into: \.momentum)),
    ])
}
