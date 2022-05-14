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
        for entityId in state.entities.entityIds {
            guard let entity = state.entities[entityId],
                  let transform = state.transform[entityId],
                  var momentum = state.momentum[entityId] else { continue }

            guard entity.tags.contains("ball") else {
                continue
            }
            
            if (transform.position.x > state.screenSize.width && momentum.velocity.x > 0)
                || (transform.position.x < 0 && momentum.velocity.x < 0) {
                momentum.velocity.x = -momentum.velocity.x
            }
            
            if (transform.position.y > state.screenSize.height && momentum.velocity.y > 0) {
                momentum.velocity.y = -momentum.velocity.y
            }
            
            if (transform.position.y < 0 && momentum.velocity.y < 0) {
                effects.append(.game(.ballDied(entityId)))
            }
                  
            state.transform[entityId] = transform
            state.momentum[entityId] = momentum
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
