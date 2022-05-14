import RedECS
import RedECSBasicComponents
import RedECSRenderingComponents
import Geometry

public struct PlayerCollisionReducer: Reducer {
    public func reduce(
        state: inout BreakoutGameState,
        delta: Double,
        environment: Void
    ) -> BreakoutGameEffect {
        ballLoop: for (ballId, ball) in state.ball {
            guard let ballTransform = state.transform[ballId],
                  var ballMomentum = state.momentum[ballId] else { continue }
            var ball = ball
            
            let playerId = BreakoutConstants.playerId
            guard ball.lastEntityHit != playerId, // skip collision check if we just hit this
                  let playerTransform = state.transform[playerId],
                  let playerShape = state.shape[playerId] else { continue }
            
            let didCollide = CollisionUtitilies.checkCollision(
                ballPosition: ballTransform.position,
                ballRadius: BreakoutConstants.ballRadius,
                shapeId: playerId,
                shapePosition: playerTransform.position,
                shape: playerShape.shape,
                modifyingBall: &ball,
                modifyingMomentum: &ballMomentum
            )
            if didCollide {
                ball.hasHitPlayerControlledObject = true
                state.ball[ballId] = ball
                state.momentum[ballId] = ballMomentum
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
