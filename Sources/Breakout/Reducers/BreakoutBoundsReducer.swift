import RedECS
import RedECSBasicComponents
import RedECSRenderingComponents
import Geometry

public struct BreakoutBoundsReducer: Reducer {
    public func reduce(
        state: inout BreakoutGameState,
        delta: Double,
        environment: Void
    ) -> BreakoutGameEffect {
        var effects: [BreakoutGameEffect] = []
        for (entityId, ball) in state.ball {
            guard let transform = state.transform[entityId],
                  var momentum = state.momentum[entityId] else { continue }
            var ball = ball
            
            if (transform.position.x > state.screenSize.width && momentum.velocity.x > 0)
                || (transform.position.x < 0 && momentum.velocity.x < 0) {
                momentum.velocity.x = -momentum.velocity.x
                ball.lastEntityHit = nil
            }
            
            if (transform.position.y > state.screenSize.height && momentum.velocity.y > 0) {
                momentum.velocity.y = -momentum.velocity.y
                ball.lastEntityHit = nil
            }
            
            if (transform.position.y < 0 && momentum.velocity.y < 0) {
                ball.lastEntityHit = nil
                effects.append(.game(.ballDied(entityId)))
            }
                  
            state.transform[entityId] = transform
            state.momentum[entityId] = momentum
            state.ball[entityId] = ball
        }
        
        return .many(effects)
    }
    
    public func reduce(
        state: inout BreakoutGameState,
        action: BreakoutGameAction,
        environment: Void
    ) -> BreakoutGameEffect {
        return .none
    }
}
