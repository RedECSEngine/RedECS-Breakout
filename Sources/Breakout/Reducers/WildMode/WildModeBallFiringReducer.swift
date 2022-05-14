import RedECS
import RedECSBasicComponents
import RedECSRenderingComponents
import Geometry

public struct WildModeBallFiringReducer: Reducer {
    public func reduce(
        state: inout BreakoutGameState,
        delta: Double,
        environment: Void
    ) -> BreakoutGameEffect {
        var candidateBlocks: [(BlockComponent, Point)] = []
        for (blockId, block) in state.block {
            guard let transform = state.transform[blockId] else { continue }
            var block = block
            block.timeSinceFiring += delta
            if block.timeSinceFiring >= 100 {
                candidateBlocks.append((block, transform.position))
            }
            state.block[blockId] = block
        }
        
        if let (block, position) = candidateBlocks.randomElement() {
            state.block[block.entity]?.timeSinceFiring = 0
            return .game(.createNewBall(position: position, velocity: .init(x: 0, y: -1)))
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
