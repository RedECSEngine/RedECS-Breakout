import RedECS
import Geometry
import RedECSRenderingComponents

public struct BreakoutHUDFormatter: HUDElementFormattable, Codable {
    public enum BreakoutHUDElement: Codable {
        case lives
        case score
        
        case leftButton
        case rightButton
        case shootButton
    }
    public func format(_ elementId: BreakoutHUDElement, _ state: BreakoutGameState) -> String {
        switch elementId {
        case .lives:
            return "Lives: \(state.lives)"
        case .score:
            return "Score: \(state.score)"
        default:
            return ""
        }
    }
}

func createUI() -> BreakoutGameEffect {
    let formatter = BreakoutHUDFormatter()
    let hud = HUDComponent<BreakoutHUDFormatter>(
        entity: "hud",
        children: [
            .init(
                id: .score,
                position: .init(x: 0, y: 0),
                type: .label(HUDLabel(size: 18, strategy: .dynamic(formatter)))
            ),
            .init(
                id: .lives,
                position: .init(x: BreakoutConstants.screenSize.width - 100, y: 0),
                type: .label(HUDLabel(size: 18, strategy: .dynamic(formatter)))
            ),
            .init(
                id: .leftButton,
                position: .init(
                    x: 12,
                    y: BreakoutConstants.screenSize.height - 60
                ),
                type: .button(HUDButton(
                    shape: .polygon(.init(points: [
                        Point(x: 16, y: 0),
                        Point(x:  0, y: 17),
                        Point(x: 16, y: 34),
                        Point(x: 16, y: 22),
                        Point(x: 40, y: 22),
                        Point(x: 40, y: 12),
                        Point(x: 16, y: 12),
                    ])),
                    fillColor: .red
                ))
            ),
            .init(
                id: .rightButton,
                position: .init(
                    x: 64,
                    y: BreakoutConstants.screenSize.height - 60
                ),
                type: .button(HUDButton(
                    shape: .polygon(.init(points: [
                        Point(x: 24, y: 0),
                        Point(x: 40, y: 17),
                        Point(x: 24, y: 34),
                        Point(x: 24, y: 22),
                        Point(x: 0, y: 22),
                        Point(x: 0, y: 12),
                        Point(x: 24, y: 12),
                    ])),
                    fillColor: .red
                ))
            ),
            .init(
                id: .shootButton,
                position: .init(
                    x: BreakoutConstants.screenSize.width - 36,
                    y: BreakoutConstants.screenSize.height - 36
                ),
                type: .button(HUDButton(
                    shape: .circle(Circle(center: .zero, radius: 30)),
                    fillColor: .red
                ))
            ),
        ]
    )
    return .system(.addComponent(hud, into: \.hud))
}
