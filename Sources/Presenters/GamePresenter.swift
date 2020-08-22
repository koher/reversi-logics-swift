import UseCases
import SwiftyReversi

public struct GamePresenter {
    public private(set) var gameManager: GameManager
    private var prevGame: Game
    
    public init(gameManager: GameManager) {
        self.gameManager = gameManager
        self.prevGame = gameManager.game
    }
    
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
    
    public func isPlayerActivityIndicatorVisible(of player: Player) -> Bool {
        guard case .waitingForPlayer(side: let side) = gameManager.playingState else { return false }
        switch (side, gameManager.darkPlayer, gameManager.lightPlayer) {
        case (.dark, .computer, _): return true
        case (.light, _, .computer): return true
        case (_, _, _): return false
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
