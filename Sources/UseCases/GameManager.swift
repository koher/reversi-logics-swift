import SwiftyReversi

public struct GameManager {
    public private(set) var game: Game
    
    public var darkPlayer: Player
    public var lightPlayer: Player
    
    public private(set) var playingState: PlayingState
    public private(set) var resetState: ResetState
    
    public init(game: Game, darkPlayer: Player, lightPlayer: Player) {
        self.game = game
        self.darkPlayer = darkPlayer
        self.lightPlayer = lightPlayer
        
        switch game.state {
        case .beingPlayed(turn: let side):
            self.playingState = .waitingForPlayer(side: side)
        case .over(let winner):
            self.playingState = .over(winner: winner)
        }
        
        self.resetState = .notConfirming
    }
}

// MARK: PlayingState

extension GameManager {
    public enum PlayingState {
        case waitingForPlayer(side: Disk)
        case placingDisks(side: Disk, from: Board)
        case passing(side: Disk)
        case over(winner: Disk?)
    }
}

// MARK: Inputs - PlayingState

extension GameManager {
    public mutating func placeDiskAt(x: Int, y: Int) throws {
        guard case .waitingForPlayer(side: let side) = playingState else {
            assertionFailure()
            return
        }
        let before = game.board
        try game.placeDiskAt(x: x, y: y)
        playingState = .placingDisks(side: side, from: before)
    }
    
    public mutating func completePlacingDisks() {
        guard case .placingDisks(side: let side, _) = playingState else {
            assertionFailure()
            return
        }
        switch game.state {
        case .beingPlayed(turn: let newSide):
            if side == newSide {
                playingState = .passing(side: side.flipped)
            } else {
                playingState = .waitingForPlayer(side: newSide)
            }
        case .over(winner: let winner):
            playingState = .over(winner: winner)
        }
    }
    
    public mutating func confirmPassing() {
        guard case .passing(side: let side) = playingState else {
            assertionFailure()
            return
        }
        let newSide = side.flipped

        // assertions
        switch game.state {
        case .beingPlayed(turn: let side):
            assert(newSide == side)
        case .over:
            assertionFailure()
        }
        
        playingState = .waitingForPlayer(side: newSide)
    }
}

// MARK: ResetState

extension GameManager {
    public enum ResetState {
        case notConfirming
        case confirming
    }
}

// MARK: Inputs - ResetState

extension GameManager {
    public mutating func confirmToReset(_ resets: Bool) {
        guard resets else { return }
        let newGame = Game(board: Board(width: game.board.width, height: game.board.height))
        self = GameManager(game: newGame, darkPlayer: .manual, lightPlayer: .manual)
    }
}
