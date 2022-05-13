import RedECS
import RedECSBasicComponents
import RedECSRenderingComponents
import Geometry

public struct BreakoutCollisionReducer: Reducer {
    public func reduce(
        state: inout BreakoutGameState,
        delta: Double,
        environment: Void
    ) -> BreakoutGameEffect {
        var effects: [BreakoutGameEffect] = []
        ballLoop: for (entityId, entity) in state.entities.entities {
            guard entity.tags.contains("ball"),
                  let transform = state.transform[entityId],
                  var momentum = state.momentum[entityId] else { continue }

            collidableLoop: for (otherEntityId, otherEntity) in state.entities.entities {
                guard !otherEntity.tags.contains("ball"),
                      let otherTransform = state.transform[otherEntityId],
                      let otherShape = state.shape[otherEntityId] else { continue }
                switch otherShape.shape {
                case .rect:
                    break
                case .circle:
                    break
                case .polygon(let polygon):
                    let ballshape = Circle(center: transform.position, radius: BreakoutConstants.ballRadius)
                    lineLoop: for line in polygon.lines {
                        let positionedLine = line.offset(by: otherTransform.position)
                        // if collision
                        if positionedLine.intersects(ballshape) {
                            let diff = ballshape.center - line.offset(by: otherTransform.position).center
                            
                            //  - calculate new x based on distance
                            if diff.x > 0 {
                                momentum.velocity.x = 1
                            } else {
                                momentum.velocity.x = -1
                            }
                            
                            if momentum.velocity.y < 0 {
                                momentum.velocity.y = -momentum.velocity.y
                            }
                            
                            if otherEntity.tags.contains("block") {
                                effects.append(.system(.removeEntity(otherEntityId)))
                            }
                            break collidableLoop
                        }
                    }
                }
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
