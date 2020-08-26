import SwiftyReversi
import UseCases

public struct SavedState: Equatable {
    public var turn: Disk?
    public var darkPlayer: Player
    public var lightPlayer: Player
    public var board: Board
    
    public init(turn: Disk?, darkPlayer: Player, lightPlayer: Player, board: Board) {
        self.turn = turn
        self.darkPlayer = darkPlayer
        self.lightPlayer = lightPlayer
        self.board = board
    }
}
