import RedECS
import RedECSBasicComponents
import RedECSRenderingComponents
import Geometry
import RealModule

public struct BreakoutGameLogicReducer: Reducer {
    public func reduce(
        state: inout BreakoutGameState,
        delta: Double,
        environment: Void
    ) -> GameEffect<BreakoutGameState, BreakoutGameAction> {
        state.lastDelta = delta
        
        return .none
    }
    
    public func reduce(
        state: inout BreakoutGameState,
        action: BreakoutGameAction,
        environment: Void
    ) -> GameEffect<BreakoutGameState, BreakoutGameAction> {
        switch action {
        case .newGame:
            state.resetProperties()
            return .many([
                generatePlayer(position: .init(x: 240, y: 10)),
                generateBlocks(),
                .game(.createNewBall)
            ])
        case .createNewBall:
            return .many([
                generateBall(position: .init(x: 240, y: 240), velocity: .init(x: 0, y: -1))
            ])
        case .ballDied(let ballId):
            state.lives -= 1
            if state.lives <= 0 {
                return .many([
                    .system(.removeEntity(ballId)),
                    .system(.removeEntity("player")),
                    .operation(.wait(100), then: .reset),
                    .operation(.wait(300), then: .newGame),
                ])
            } else {
                return .many([
                    .system(.removeEntity(ballId)),
                    .operation(.wait(200), then: .createNewBall)
                ])
            }
        case .reset:
            return .many(state.entities.entities.compactMap { (id, entity) in
                guard !entity.tags.contains("operation") else { return nil }
                return .system(.removeEntity(id))
            })
        default:
            break
        }
        return .none
    }
}

func generatePlayer(position: Point) -> BreakoutGameEffect {
    let playerId: EntityId = "player"
    let shape = ShapeComponent(
        entity: playerId,
        shape: .polygon(Path(points: [
            Point(x: 0, y: BreakoutConstants.paddleSize.height),
            Point(x: BreakoutConstants.paddleSize.width, y: BreakoutConstants.paddleSize.height),
            Point(x: BreakoutConstants.paddleSize.width, y: 0),
            Point(x: 0, y: 0)
        ]))
    )
    let transform = TransformComponent(entity: playerId, position: position)
    let movement = MovementComponent(entity: playerId, velocity: .zero, travelSpeed: BreakoutConstants.paddleSpeed)
    let keyboard = KeyboardInputComponent<BreakoutGameAction>(
        entity: playerId,
        keyMap: [
            ([.a, .leftKey], .moveLeft),
            ([.d, .rightKey], .moveRight),
        ]
    )
    return .many([
        .system(.addEntity(playerId, [])),
        .system(.addComponent(shape, into: \.shape)),
        .system(.addComponent(transform, into: \.transform)),
        .system(.addComponent(movement, into: \.movement)),
        .system(.addComponent(keyboard, into: \.keyboardInput)),
    ])
}

func generateBlocks() -> BreakoutGameEffect {
    var effects: [BreakoutGameEffect] = []
    
    let space: Double = 10
    let blockWidth = BreakoutConstants.screenSize.width / Double(BreakoutConstants.blockCols) - space
    
    for row in 0..<BreakoutConstants.blockRows {
        for col in 0..<BreakoutConstants.blockCols {
            let blockId = "block-\(row)-\(col)"
            let shape = ShapeComponent(
                entity: blockId,
                shape: .polygon(Path(points: [
                Point(x: 0, y: 0),
                Point(x: blockWidth, y: 0),
                Point(x: blockWidth, y: BreakoutConstants.blockSize.height),
                Point(x: 0, y: BreakoutConstants.blockSize.height)
            ])),
                fillColor: .random()
            )
            let transform = TransformComponent(
                entity: blockId,
                position: Point(
                    x: 5 + Double(col) * (blockWidth + space),
                    y: Double(row * 20) + 400
                )
            )
            effects.append(.many([
                .system(.addEntity(blockId, ["block"])),
                .system(.addComponent(shape, into: \.shape)),
                .system(.addComponent(transform, into: \.transform))
            ]))
        }
    }
    return .many(effects)
}

func generateBall(position: Point, velocity: Point) -> BreakoutGameEffect {
    let ballId: EntityId = "\(Int.random(in: 1..<Int.max))ball"
    let shape = ShapeComponent(
        entity: ballId,
        shape: .circle(.init(radius: BreakoutConstants.ballRadius)),
        fillColor: .red
    )
    let transform = TransformComponent(
        entity: ballId,
        position: position
    )
    let movement = MovementComponent(
        entity: ballId,
        velocity: .zero,
        travelSpeed: BreakoutConstants.ballSpeed
    )
    let momentum = MomentumComponent(entity: ballId, velocity: velocity)
    return .many([
        .system(.addEntity(ballId, ["ball"])),
        .system(.addComponent(shape, into: \.shape)),
        .system(.addComponent(transform, into: \.transform)),
        .system(.addComponent(movement, into: \.movement)),
        .system(.addComponent(momentum, into: \.momentum))
    ])
}
