import UseCases
import SwiftyReversi

public struct GamePresenter {
    public private(set) var gameManager: GameManager
    private var prevGame: Game
    
    public init(gameManager: GameManager) {
        self.gameManager = gameManager
        self.prevGame = gameManager.game
    }
}

// MARK: Output
extension GamePresenter {
    public var message: Message {
        switch gameManager.game.state {
        case .beingPlayed(turn: let side):
            if case .passing(side: let side) = gameManager.playingState {
                return .turn(side: side)
            } else {
                return .turn(side: side)
            }
        case .over(winner: let winner): return .result(winner: winner)
        }
    }
    
    public func count(of side: Disk) -> Int {
        switch gameManager.playingState {
        case .placingDisks(side: _, from: let board): return board.count(of: side)
        case _: return gameManager.game.board.count(of: side)
        }
    }

    public var darkPlayer: Player {
        get { gameManager.darkPlayer }
        set { gameManager.darkPlayer = newValue } // Input
    }
    
    public var lightPlayer: Player {
        get { gameManager.lightPlayer }
        set { gameManager.lightPlayer = newValue } // Input
    }
    
    public func isPlayerActivityIndicatorVisible(of side: Disk) -> Bool {
        guard case .waitingForPlayer(side: let turn) = gameManager.playingState else { return false }
        switch (side, turn, gameManager.darkPlayer, gameManager.lightPlayer) {
        case (.dark, .dark, .computer, _): return true
        case (.light, .light, _, .computer): return true
        case (_, _, _, _): return false
        }
    }
    
    public var isPassingAlertVisible: Bool {
        guard case .notConfirming = gameManager.resetState else { return false }
        guard case .passing = gameManager.playingState else { return false }
        return true
    }
    
    public var isResetAlertVisible: Bool {
        guard  case .confirming = gameManager.resetState else { return false }
        return true
    }
}

// MARK: Input

extension GamePresenter {
    public mutating func tryPlacingDiskAt(x: Int, y: Int) {
        switch (gameManager.playingState, gameManager.darkPlayer, gameManager.lightPlayer) {
        case (.waitingForPlayer(side: .dark), .manual, _),
             (.waitingForPlayer(side: .light), _, .manual):
            try? gameManager.placeDiskAt(x: x, y: y)
        case (_, _, _):
            break
        }
    }
    
    public mutating func completePlacingDisks() { gameManager.completePlacingDisks() }
    public mutating func completeConfirmationForPass() { gameManager.completeConfirmationForPass() }
    public mutating func confirmToReset() { gameManager.confirmToReset() }
    public mutating func completeConfirmationForReset(_ resets: Bool) { gameManager.completeConfirmationForReset(resets) }
}

// MARK: Message

extension GamePresenter {
    public enum Message {
        case turn(side: Disk)
        case result(winner: Disk?)
    }
}

// MARK: User Input

extension GamePresenter {
    public mutating func selectBoardCellAt(x: Int, y: Int) {
        
    }
}
