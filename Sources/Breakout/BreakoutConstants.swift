import Geometry

public enum BreakoutConstants {
    static let screenSize: Size = .init(width: 320, height: 480)
    
    static let playerId = "player"
    static let playerProjectileTimeout: Double = 100
    static let paddleSize: Size = .init(width: 50, height: 10)
    static let paddleSpeed: Double = 2.8
    
    static let deflectileSize: Size = .init(width: 40, height: 6)
    static let deflectileSpeed: Double = 1
    
    static let blockSize: Size = .init(width: 30, height: 10)
    static let blockRows: Int = 4
    static let blockCols: Int = 8
    
    static let ballRadius: Double = 5
    static let ballSpeed: Double = 2
}
