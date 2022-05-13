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
        
        for entityId in state.entities.entityIds {
            guard let entity = state.entities[entityId],
                  var transform = state.transform[entityId],
                  var momentum = state.momentum[entityId] else { continue }

            guard entity.tags.contains("ball")else  {
                break
            }
            
            if (transform.position.x > state.screenSize.width && momentum.velocity.x > 0)
                || (transform.position.x < 0 && momentum.velocity.x < 0) {
                momentum.velocity.x = -momentum.velocity.x
            }
            
            if (transform.position.y > state.screenSize.height && momentum.velocity.y > 0)
                || (transform.position.y < 0 && momentum.velocity.y < 0) {
                momentum.velocity.y = -momentum.velocity.y
            }
                  
            state.transform[entityId] = transform
            state.momentum[entityId] = momentum
        }
        
        return .none
    }
    
    public func reduce(
        state: inout BreakoutGameState,
        action: BreakoutGameAction,
        environment: Void
    ) -> BreakoutGameEffect {
        return .none
    }
}
