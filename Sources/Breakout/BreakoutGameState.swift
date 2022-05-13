import RedECS
import RedECSBasicComponents
import RedECSRenderingComponents
import Geometry

public enum BreakoutConstants {
    static let screenSize: Size = .init(width: 320, height: 480)
    static let paddleSize: Size = .init(width: 50, height: 10)
    static let blockSize: Size = .init(width: 30, height: 10)
    static let blockRows: Int = 4
    static let blockCols: Int = 8
}

public struct BreakoutGameState: GameState {
    public var entities: EntityRepository = .init()
    
    public var shape: [EntityId: ShapeComponent] = [:]
    public var transform: [EntityId: TransformComponent] = [:]
    public var movement: [EntityId: MovementComponent] = [:]
    public var momentum: [EntityId: MomentumComponent] = [:]
    
    public var keyboardInput: [EntityId: KeyboardInputComponent<BreakoutGameAction>] = [:]
    
    var lastDelta: Double = 0
    var lastInputLocation: Point? = nil
    
    public var screenSize: Size = BreakoutConstants.screenSize
     
    /**
        
    - collision (proximity interaction)
    - asteroid positioning safely away from ship
    - asteroid explode on collision
     */
    
    public init() {}
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
