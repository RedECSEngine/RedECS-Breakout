import Breakout
import SpriteKit
import RedECS
import RedECSBasicComponents
import RedECSRenderingComponents
import RedECSSpriteKitSupport
import Geometry

typealias AnyBreakoutSpriteKitReducer = AnyReducer<BreakoutGameState, BreakoutGameAction, BreakoutSpriteKitEnvironment>

public final class BreakoutSpriteKitEnvironment: SpriteKitRenderingEnvironment {
    public var renderer: SpriteKitRenderer
    
    public init(renderer: SpriteKitRenderer) {
        self.renderer = renderer
    }
}

let breakoutSpriteKitReducer: AnyBreakoutSpriteKitReducer = (
    breakoutCoreReducer.pullback(
        toLocalState: \.self,
        toLocalAction: { $0 },
        toGlobalAction: { $0 },
        toLocalEnvironment: { _ in () }
    )
    +
    SpriteKitShapeRenderingReducer()
        .pullback(toLocalState: \.shapeContext, toLocalEnvironment: { $0 as SpriteKitRenderingEnvironment })
).eraseToAnyReducer()

public class BreakoutGameScene: SKScene {
    
    var store: GameStore<AnyBreakoutSpriteKitReducer>!
    
    public override init() {
        let state = BreakoutGameState()
        super.init(size: .init(width: state.screenSize.width, height: state.screenSize.height))
        store = GameStore(
            state: state,
            environment: BreakoutSpriteKitEnvironment(renderer: .init(scene: self)),
            reducer: breakoutSpriteKitReducer,
            registeredComponentTypes: [
                .init(keyPath: \.movement),
                .init(keyPath: \.transform),
                .init(keyPath: \.momentum),
                .init(keyPath: \.shape),
                .init(keyPath: \.keyboardInput),
                .init(keyPath: \.operation)
            ]
        )
        
        store.sendAction(.newGame)
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) { nil }
    
    var lastTime: TimeInterval?
    
    public override func update(_ currentTime: TimeInterval) {
        
        if let lastTime = lastTime {
            store.sendDelta((currentTime - lastTime) * 100)
        }
        lastTime = currentTime
    }
    
}

#if os(OSX)
extension BreakoutGameScene {
    public override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        if let key = KeyboardInput(rawValue: event.keyCode) {
            store.sendAction(.keyboardInput(.keyDown(key)))
        } else {
            print("unmapped key down", event.keyCode)
        }
    }
    
    public override func keyUp(with event: NSEvent) {
        super.keyUp(with: event)
        if let key = KeyboardInput(rawValue: event.keyCode) {
            store.sendAction(.keyboardInput(.keyUp(key)))
        } else {
            print("unmapped key up", event.keyCode)
        }
    }
    
    public override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        store.sendAction(.locationInput(Point(x: location.x, y: location.y)))
    }
    
}
#endif
