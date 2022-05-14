import RedECSRenderingComponents

extension Color {
    static func colorForLives(_ lives: Int) -> Color {
        switch lives {
        case (Int.min...0):
            return .grey
        case 1:
            return .red
        case 2:
            return .blue
        default:
            return .green
        }
    }
}
