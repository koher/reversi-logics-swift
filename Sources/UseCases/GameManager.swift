import SwiftyReversi

public struct GameManager {
    public private(set) var game: Game
    
    public var darkPlayer: Player
    public var lightPlayer: Player
    
    public private(set) var playState: PlayState
    public private(set) var resetState: ResetState
    
    public init(game: Game, darkPlayer: Player, lightPlayer: Player) {
        self.game = game
        self.darkPlayer = darkPlayer
        self.lightPlayer = lightPlayer
        
        switch game.state {
        case .beingPlayed(turn: let side):
            if game.board.hasValidMoves(for: side) {
                self.playState = .waitingForPlayer(side: side)
            } else {
                self.playState = .passing(side: side)
            }
        case .over(let winner):
            self.playState = .over(winner: winner)
        }
        
        self.resetState = .notConfirming
    }
}

// MARK: PlayState

extension GameManager {
    public enum PlayState: Equatable {
        case waitingForPlayer(side: Disk)
        case flippingDisks(side: Disk, from: Board)
        case passing(side: Disk)
        case over(winner: Disk?)
    }
}

// MARK: ResetState

extension GameManager {
    public enum ResetState: Equatable {
        case notConfirming
        case confirming
    }
}

// MARK: Input

extension GameManager {
    public mutating func placeDiskAt(x: Int, y: Int) {
        guard case .waitingForPlayer(side: let side) = playState else { preconditionFailure() }
        let before = game.board
        do {
            try game.placeDiskAt(x: x, y: y)
            playState = .flippingDisks(side: side, from: before)
        } catch {
            assertionFailure("\(error)")
        }
    }
    
    public mutating func completeFlippingDisks() {
        guard case .flippingDisks(side: _, _) = playState else { preconditionFailure() }
        switch game.state {
        case .beingPlayed(turn: let newSide):
            if game.board.hasValidMoves(for: newSide) {
                playState = .waitingForPlayer(side: newSide)
            } else {
                playState = .passing(side: newSide)
            }
        case .over(winner: let winner):
            playState = .over(winner: winner)
        }
    }
    
    public mutating func pass() {
        guard case .passing(side: let side) = playState else { preconditionFailure() }
        do {
            try game.pass()
            playState = .waitingForPlayer(side: side.flipped)
        } catch {
            assertionFailure()
        }
    }
    
    public mutating func confirmToReset() {
        guard case .notConfirming = resetState else { preconditionFailure() }
        resetState = .confirming
    }
    
    public mutating func reset(_ resets: Bool) {
        guard case .confirming = resetState else { preconditionFailure() }
        guard resets else {
            resetState = .notConfirming
            return
        }
        
        let newGame = Game(board: Board(width: game.board.width, height: game.board.height))
        self = GameManager(game: newGame, darkPlayer: .manual, lightPlayer: .manual)
    }
}
