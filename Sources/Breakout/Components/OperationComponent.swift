import RedECS

public protocol OperationCapable {
    associatedtype GameAction: Equatable & Codable
    var operation: [EntityId: OperationComponent<GameAction>] { get set }
}

public struct OperationComponent<GameAction: Equatable & Codable>: GameComponent {
    public enum OperationType: Equatable & Codable {
        case wait(Double)
    }
    
    public var entity: EntityId
    public var type: OperationType
    public var delta: Double
    public var onComplete: GameAction
    
    public init (
        entity: EntityId,
        type: OperationType,
        delta: Double,
        onComplete: GameAction
    ) {
        self.entity =  entity
        self.type = type
        self.delta = delta
        self.onComplete = onComplete
    }
}

public struct OperationComponentContext<GameAction: Equatable & Codable>: GameState, OperationCapable {
    public var entities: EntityRepository = .init()
    public var operation: [EntityId: OperationComponent<GameAction>] = [:]
    
    public init(
        entities: EntityRepository = .init(),
        operation: [EntityId : OperationComponent<GameAction>] = [:]
    ) {
        self.entities = entities
        self.operation = operation
    }
}


public struct OperationReducer<GameAction: Equatable & Codable>: Reducer {
    public func reduce(state: inout OperationComponentContext<GameAction>, action: GameAction, environment: ()) -> GameEffect<OperationComponentContext<GameAction>, GameAction> {
        .none
    }
    
    public init() { }
    public func reduce(
        state: inout OperationComponentContext<GameAction>,
        delta: Double,
        environment: Void
    ) -> GameEffect<OperationComponentContext<GameAction>, GameAction> {
        var effects: [GameEffect<OperationComponentContext<GameAction>, GameAction>] = []
        state.operation.forEach { (id, operation) in
            var op = operation
            op.delta += delta
            switch op.type {
            case .wait(let amount):
                if op.delta >= amount {
                    effects.append(.system(.removeEntity(id)))
                    effects.append(.game(op.onComplete))
                }
            }
            state.operation[id] = op
        }
        return .many(effects)
    }
}

public extension GameEffect where State: OperationCapable, LogicAction == State.GameAction {
    static func operation(
        _ type: OperationComponent<LogicAction>.OperationType,
        then: LogicAction
    ) -> Self {
        let id = "operation-\(Int.random(in: 0...Int.max))"
        let operation = OperationComponent(entity: id, type: type, delta: 0, onComplete: then)
        return .many([
            .system(.addEntity(id, ["operation"])),
            .system(.addComponent(operation, into: \.operation))
        ])
    }
}
