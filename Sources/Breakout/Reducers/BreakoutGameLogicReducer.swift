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
                createUI(),
                generatePlayer(position: .init(x: 241, y: 64)),
                generateBlocks(),
                .game(state.mode == .wild ? .noop : .createNewBallDefault)
            ])
        case .createNewBall(let position, let velocity):
            return .many([
                generateBall(position: position, velocity: velocity)
            ])
        case .ballDied(let ballId):
            state.lives -= 1
            guard state.lives <= 0 else {
                return .many([
                    .system(.removeEntity(ballId)),
                    state.mode == .normal ? .operation(.wait(200), then: .createNewBallDefault) : .none
                ])
            }
            if state.lives == 0 {
                return .many([
                    .system(.removeEntity(ballId)),
                    .system(.removeEntity(BreakoutConstants.playerId)),
                    .operation(.wait(100), then: .reset)
                ])
            } else { // cleanup after game over
                return .many([
                    .system(.removeEntity(ballId))
                ])
            }
        case .reset:
            return .many(state.entities.entities.compactMap { (id, entity) in
                return .system(.removeEntity(id))
            } + [.operation(.wait(300), then: .newGame)])
        default:
            break
        }
        return .none
    }
}

public struct BreakoutHUDFormatter: HUDElementFormattable, Codable {
    public enum BreakoutHUDElement: Codable {
        case lives
        case score
        
        case leftButton
        case rightButton
        case shootButton
    }
    public func format(_ elementId: BreakoutHUDElement, _ state: BreakoutGameState) -> String {
        switch elementId {
        case .lives:
            return "Lives: \(state.lives)"
        case .score:
            return "Score: \(state.score)"
        case .leftButton:
            return "Left"
        case .rightButton:
            return "Right"
        case .shootButton:
            return "Shoot"
        }
    }
}

func createUI() -> BreakoutGameEffect {
    let hud = HUDComponent<BreakoutHUDFormatter>(
        entity: "hud",
        children: [
            .init(
                id: .score,
                position: .init(x: 0, y: 0),
                type: .label(HUDLabel(
                    size: 18,
                    strategy: .dynamic(BreakoutHUDFormatter())
                ))
            ),
            .init(
                id: .lives,
                position: .init(x: BreakoutConstants.screenSize.width - 100, y: 0),
                type: .label(HUDLabel(
                    size: 18,
                    strategy: .dynamic(BreakoutHUDFormatter())
                ))
            ),
            .init(
                id: .leftButton,
                position: .init(
                    x: 12,
                    y: BreakoutConstants.screenSize.height - 46
                ),
                type: .button(HUDButton(
                    shape: .polygon(.init(points: [
                        Point(x: 16, y: 0),
                        Point(x:  0, y: 17),
                        Point(x: 16, y: 34),
                        Point(x: 16, y: 22),
                        Point(x: 40, y: 22),
                        Point(x: 40, y: 12),
                        Point(x: 16, y: 12),
                    ])),
                    fillColor: .red
                ))
            ),
            .init(
                id: .rightButton,
                position: .init(
                    x: 64,
                    y: BreakoutConstants.screenSize.height - 46
                ),
                type: .button(HUDButton(
                    shape: .polygon(.init(points: [
                        Point(x: 24, y: 0),
                        Point(x: 40, y: 17),
                        Point(x: 24, y: 34),
                        
                        Point(x: 24, y: 22),
                        Point(x: 0, y: 22),
                        Point(x: 0, y: 12),
                        Point(x: 24, y: 12),
                    ])),
                    fillColor: .red
                ))
            ),
            .init(
                id: .shootButton,
                position: .init(
                    x: BreakoutConstants.screenSize.width - 36,
                    y: BreakoutConstants.screenSize.height - 36
                ),
                type: .button(HUDButton(
                    shape: .circle(Circle(center: .zero, radius: 24)),
                    fillColor: .red
                ))
            ),
        ]
    )
    return .system(.addComponent(hud, into: \.hud))
}

func generatePlayer(position: Point) -> BreakoutGameEffect {
    let playerId: EntityId = BreakoutConstants.playerId
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
            ([.w, .upKey], .fireDeflectileFromCurrentPlayerPosition)
        ]
    )
    return .many([
        .system(.addEntity(playerId, [])),
        .system(.addComponent(PlayerComponent(entity: playerId), into: \.player)),
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
                    y: Double(row * 20) + 390
                )
            )
            effects.append(.many([
                .system(.addEntity(blockId, ["block"])),
                .system(.addComponent(shape, into: \.shape)),
                .system(.addComponent(transform, into: \.transform)),
                .system(.addComponent(BlockComponent(entity: blockId, lives: 1), into: \.block)),
            ]))
        }
    }
    return .many(effects)
}

func generateBall(position: Point, velocity: Point) -> BreakoutGameEffect {
    let ballId: EntityId = newEntityId(prefix: "ball")
    let ball = BallComponent(entity: ballId)
    let shape = ShapeComponent(
        entity: ballId,
        shape: .circle(.init(radius: BreakoutConstants.ballRadius)),
        fillColor: .colorForLives(ball.lives)
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
        .system(.addComponent(momentum, into: \.momentum)),
        .system(.addComponent(ball, into: \.ball)),
    ])
}
