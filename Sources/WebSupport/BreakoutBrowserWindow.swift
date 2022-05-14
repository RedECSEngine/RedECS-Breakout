import Breakout
import JavaScriptKit
import RedECS
import RedECSBasicComponents
import RedECSRenderingComponents
import RedECSWebSupport
import Geometry

typealias AnyBreakoutWebReducer = AnyReducer<BreakoutGameState, BreakoutGameAction, BreakoutWebEnvironment>

let breakoutWebReducer: AnyBreakoutWebReducer = (
    breakoutCoreReducer.pullback(
        toLocalState: \.self,
        toLocalAction: { $0 },
        toGlobalAction: { $0 },
        toLocalEnvironment: { _ in () }
    )
    + WebShapeRenderingReducer()
        .pullback(toLocalState: \.shapeContext, toLocalEnvironment: { $0 as WebRenderingEnvironment })
).eraseToAnyReducer()

struct BreakoutWebEnvironment: WebRenderingEnvironment {
    var renderer: WebRenderer
    
    init(renderer: WebRenderer) {
        self.renderer = renderer
    }
}

public class BreakoutGame: WebBrowserWindow {
    var store: GameStore<AnyBreakoutWebReducer>!
    var lastTime: Double?
    
    public convenience init() {
        let state = BreakoutGameState()
        self.init(size: state.screenSize)
        store = GameStore(
            state: state,
            environment: BreakoutWebEnvironment(renderer: self.renderer),
            reducer: breakoutWebReducer,
            registeredComponentTypes: [
                .init(keyPath: \.movement),
                .init(keyPath: \.transform),
                .init(keyPath: \.momentum),
                .init(keyPath: \.shape),
                .init(keyPath: \.keyboardInput),
                .init(keyPath: \.operation),
                .init(keyPath: \.player),
                .init(keyPath: \.ball),
                .init(keyPath: \.block),
            ]
        )
    }
    
    required init(size: Size) {
        super.init(size: size)
    }
    
    public override func onWebRendererReady() {
        super.onWebRendererReady()
        
        let document = JSObject.global.document
        var infoElement = document.createElement("div")
        infoElement.innerHTML = """
        <h4>About</h4>
        This game is written in Swift leveraging SwiftWASM.
        <br /><br />
        <strong>Instructions</strong>
        <br /><br />
        Use left and right keys to move and the up key to fire a paddle
        """
        _ = document.body.appendChild(infoElement)
        
        store.sendAction(.newGame)
    }
    
    public override func update(_ currentTime: Double) {
        super.update(currentTime)
        if let lastTime = lastTime {
            let delta = (currentTime - lastTime) / 10
            store.sendDelta(delta)
        }
        lastTime = currentTime
    }
    
    public override func onKeyDown(_ key: KeyboardInput) {
        store.sendAction(.keyboardInput(.keyDown(key)))
    }
    
    public override func onKeyUp(_ key: KeyboardInput) {
        store.sendAction(.keyboardInput(.keyUp(key)))
    }
    
    public override func mouseDown(_ location: Point) {
        super.mouseDown(location)
        store.sendAction(.locationInput(location))
    }
    
    public override func touchDown(_ location: Point) {
        super.touchDown(location)
        store.sendAction(.locationInput(location))
    }
}
