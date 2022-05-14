import RedECS
import RedECSBasicComponents
import RedECSRenderingComponents
import Geometry

public struct BlockCollisionReducer: Reducer {
    public func reduce(
        state: inout BreakoutGameState,
        delta: Double,
        environment: Void
    ) -> BreakoutGameEffect {
        var effects: [BreakoutGameEffect] = []
        ballLoop: for (ballId, ball) in state.ball {
            guard ball.hasHitPlayerControlledObject,
                  let transform = state.transform[ballId],
                  var momentum = state.momentum[ballId],
                  var ballShape = state.shape[ballId] else { continue }
            var ball = ball
            
            collidableLoop: for (blockId, block) in state.block {
                guard ball.lastEntityHit != blockId, // skip collision check if we just hit this
                      let otherTransform = state.transform[blockId],
                      let otherShape = state.shape[blockId] else { continue }
                
                let didCollide = CollisionUtitilies.checkCollision(
                    ballPosition: transform.position,
                    ballRadius: BreakoutConstants.ballRadius,
                    shapeId: blockId,
                    shapePosition: otherTransform.position,
                    shape: otherShape.shape,
                    modifyingBall: &ball,
                    modifyingMomentum: &momentum
                )
                if didCollide {
                    var block = block // prepare to mutate the block we are iterating over
                    block.lives -= 1
                    if block.lives <= 0 {
                        effects.append(.system(.removeEntity(blockId)))
                    }
                    if state.mode == .wild {
                        ball.lives -= 1
                        ballShape.fillColor = .colorForLives(ball.lives)
                        if ball.lives <= 0 {
                            effects.append(.system(.removeEntity(ballId)))
                        }
                    }
                    state.block[blockId] = block
                    state.ball[ballId] = ball
                    state.shape[ballId] = ballShape
                    state.momentum[ballId] = momentum
                    break collidableLoop
                }
            }
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
