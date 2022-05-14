import RedECS
import RedECSBasicComponents
import Geometry

public enum CollisionUtitilies {
    public static func checkCollision(
        ballPosition: Point,
        ballRadius: Double,
        shapeId: EntityId,
        shapePosition: Point,
        shape: Shape,
        modifyingBall ball: inout BallComponent,
        modifyingMomentum momentum: inout MomentumComponent
    ) -> Bool {
        switch shape {
        case .rect:
            return false
        case .circle:
            return false
        case .polygon(let polygon):
            let ballshape = Circle(center: ballPosition, radius: ballRadius)
            lineLoop: for line in polygon.lines {
                let positionedLine = line.offset(by: shapePosition)
                // if collision
                if positionedLine.intersects(ballshape) {
                    ball.lastEntityHit = shapeId
                    let diff = ballshape.center - line.offset(by: shapePosition).center
                    if line.isHorizontal {
                        momentum.velocity.x = diff.x / (line.length / 2)
                        momentum.velocity.y = -momentum.velocity.y
                    } else if line.isVertical {
                        momentum.velocity.x = -momentum.velocity.x
                        momentum.velocity.y = diff.y / (line.length / 2)
                    }
                    return true
                }
            }
            return false
        }
    }
}
