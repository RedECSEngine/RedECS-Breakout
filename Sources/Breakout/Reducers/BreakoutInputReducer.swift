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
        state.lastDelta = delta
        
        guard let location = state.lastInputLocation,
                let playerPosition = state.transform["player"]?.position else {
            return .none
        }
        
        let locationX = location.x - (BreakoutConstants.paddleSize.width / 2)
        if abs(playerPosition.x - locationX) > 3 {
            if playerPosition.x < locationX {
                return .game(.moveRight)
            } else if playerPosition.x > locationX {
                return .game(.moveLeft)
            }
        }
        
        return .none
    }
    
    public func reduce(
        state: inout BreakoutGameState,
        action: BreakoutGameAction,
        environment: Void
    ) -> GameEffect<BreakoutGameState, BreakoutGameAction> {
        switch action {
        case .newGame:
            return .many([
                generatePlayer(position: .init(x: 240, y: 10)),
                generateBall(position: .init(x: 240, y: 240), velocity: .init(x: 0, y: -1)),
                generateBlocks()
            ])
        case .moveLeft:
            guard var playerMovement = state.movement["player"] else { break }
            playerMovement.velocity.x -= 1
            state.movement["player"] = playerMovement
        case .moveRight:
            guard var playerMovement = state.movement["player"] else { break }
            playerMovement.velocity.x += 1
            state.movement["player"] = playerMovement
        case .keyboardInput:
            return .none
        case .locationInput(let location):
            state.lastInputLocation = location
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
    let movement = MovementComponent(entity: playerId, velocity: .zero, travelSpeed: 2)
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
    
    let blockWidth = BreakoutConstants.screenSize.width / Double(BreakoutConstants.blockCols) - 10
    
    for row in 0..<BreakoutConstants.blockRows {
        for col in 0..<BreakoutConstants.blockCols {
            let blockId = "block-\(row)-\(col)"
            let shape = ShapeComponent(entity: blockId, shape: .polygon(Path(points: [
                Point(x: 0, y: 0),
                Point(x: blockWidth, y: 0),
                Point(x: blockWidth, y: BreakoutConstants.blockSize.height),
                Point(x: 0, y: BreakoutConstants.blockSize.height)
            ])))
            let transform = TransformComponent(
                entity: blockId,
                position: Point(x: 5 + Double(col) * (blockWidth + 10), y: Double(row * 20) + 400)
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
    let shape = ShapeComponent(entity: ballId, shape: .circle(.init(radius: 5)))
    let transform = TransformComponent(entity: ballId, position: position)
    let movement = MovementComponent(entity: ballId, velocity: .zero, travelSpeed: 2)
    let momentum = MomentumComponent(entity: ballId, velocity: velocity)
    return .many([
        .system(.addEntity(ballId, ["ball"])),
        .system(.addComponent(shape, into: \.shape)),
        .system(.addComponent(transform, into: \.transform)),
        .system(.addComponent(movement, into: \.movement)),
        .system(.addComponent(momentum, into: \.momentum))
    ])
}
