import RedECS
import RedECSBasicComponents
import RedECSRenderingComponents
import Geometry

public struct WildModeCollisionReducer: Reducer {
    public func reduce(
        state: inout BreakoutGameState,
        delta: Double,
        environment: Void
    ) -> BreakoutGameEffect {
        for (ballId, ball) in state.ball {
            guard let ballTransform = state.transform[ballId],
                  var ballMomentum = state.momentum[ballId] else { continue }
            var ball = ball
            
            for (deflectileId, deflectile) in state.entities.entities {
                guard ball.lastEntityHit != deflectileId, // skip collision check if we just hit this
                      deflectile.tags.contains("deflectile"),
                      let deflectileTransform = state.transform[deflectileId],
                      let deflectileShape = state.shape[deflectileId] else { continue }
                
                let didCollide = CollisionUtitilies.checkCollision(
                    ballPosition: ballTransform.position,
                    ballRadius: BreakoutConstants.ballRadius,
                    shapeId: deflectileId,
                    shapePosition: deflectileTransform.position,
                    shape: deflectileShape.shape,
                    modifyingBall: &ball,
                    modifyingMomentum: &ballMomentum
                )
                if didCollide {
                    ball.hasHitPlayerControlledObject = true
                    state.ball[ballId] = ball
                    state.momentum[ballId] = ballMomentum
                    break
                }
            }
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
