import RedECS
import RedECSBasicComponents
import RedECSRenderingComponents
import Geometry

public enum BreakoutGameMode: Equatable, Codable {
    case normal
    case wild
}

public struct BreakoutGameState: GameState, OperationCapable, HUDRenderingCapable {
    public var entities: EntityRepository = .init()
    
    public var shape: [EntityId: ShapeComponent] = [:]
    public var transform: [EntityId: TransformComponent] = [:]
    public var movement: [EntityId: MovementComponent] = [:]
    public var momentum: [EntityId: MomentumComponent] = [:]
    
    public var player: [EntityId: PlayerComponent] = [:]
    public var block: [EntityId: BlockComponent] = [:]
    public var ball: [EntityId: BallComponent] = [:]
    
    public var hud: [EntityId: HUDComponent<BreakoutHUDFormatter>] = [:]
    public var keyboardInput: [EntityId: KeyboardInputComponent<BreakoutGameAction>] = [:]
    public var operation: [EntityId: OperationComponent<BreakoutGameAction>] = [:]
    
    var mode: BreakoutGameMode = .wild
    var lives: Int = 3
    var score: Int = 0
    
    var lastDelta: Double = 0
//    var lastInputLocation: Point? = nil
    
    public var screenSize: Size = BreakoutConstants.screenSize
     
    public init() {}
    
    public mutating func resetProperties() {
        lives = 3
        score = 0
        lastDelta = 0
//        lastInputLocation = nil
    }
}

public extension BreakoutGameState {
    var shapeContext: ShapeRenderingContext {
        get {
            ShapeRenderingContext(
                entities: entities,
                transform: transform,
                shape: shape
            )
        }
        set {
            self.transform = newValue.transform
            self.shape = newValue.shape
        }
    }
}

public extension BreakoutGameState {
    var movementContext: MovementReducerContext {
        get {
            MovementReducerContext(
                entities: entities,
                transform: transform,
                movement: movement
            )
        }
        set {
            self.transform = newValue.transform
            self.movement = newValue.movement
        }
    }
}

public extension BreakoutGameState {
    var momentumContext: MomentumReducerContext {
        get {
            MomentumReducerContext(
                entities: entities,
                momentum: momentum,
                movement: movement
            )
        }
        set {
            self.momentum = newValue.momentum
            self.movement = newValue.movement
        }
    }
}

public extension BreakoutGameState {
    var keyboardInputContext: KeyboardInputReducerContext<BreakoutGameAction> {
        get {
            KeyboardInputReducerContext(entities: entities, keyboardInput: keyboardInput)
        }
        set {
            self.keyboardInput = newValue.keyboardInput
        }
    }
}

public extension BreakoutGameState {
    var operationContext: OperationComponentContext<BreakoutGameAction> {
        get {
            OperationComponentContext(entities: entities, operation: operation)
        }
        set {
            self.operation = newValue.operation
        }
    }
}
