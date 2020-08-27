import UseCases
import SwiftyReversi

public struct GamePresenter {
    public private(set) var manager: GameManager
    private var prevGame: Game
    
    public init(manager: GameManager) {
        self.manager = manager
        self.prevGame = manager.game
    }
}

// MARK: Output
extension GamePresenter {
    public var message: Message {
        switch manager.game.state {
        case .beingPlayed(turn: let side):
            if case .passing(side: let side) = manager.playingState {
                return .turn(side: side)
            } else {
                return .turn(side: side)
            }
        case .over(winner: let winner): return .result(winner: winner)
        }
    }
    
    public func count(of side: Disk) -> Int {
        switch manager.playingState {
        case .placingDisks(side: _, from: let board): return board.count(of: side)
        case _: return manager.game.board.count(of: side)
        }
    }

    public var darkPlayer: Player {
        get { manager.darkPlayer }
        set { manager.darkPlayer = newValue } // Input
    }
    
    public var lightPlayer: Player {
        get { manager.lightPlayer }
        set { manager.lightPlayer = newValue } // Input
    }
    
    public func isPlayerActivityIndicatorVisible(of side: Disk) -> Bool {
        guard case .waitingForPlayer(side: let turn) = manager.playingState else { return false }
        switch (side, turn, manager.darkPlayer, manager.lightPlayer) {
        case (.dark, .dark, .computer, _): return true
        case (.light, .light, _, .computer): return true
        case (_, _, _, _): return false
        }
    }
    
    public var needsAnimatingBoardChanges: Bool {
        if case .placingDisks(_, _) = manager.playingState { return true }
        else { return false }
    }
    
    public var isPassingAlertVisible: Bool {
        guard case .notConfirming = manager.resetState else { return false }
        guard case .passing = manager.playingState else { return false }
        return true
    }
    
    public var isResetAlertVisible: Bool {
        guard  case .confirming = manager.resetState else { return false }
        return true
    }
    
    public var boardForComputer: Board? {
        switch (manager.playingState, manager.darkPlayer, manager.lightPlayer) {
        case (.waitingForPlayer(side: .dark), .computer, _):
            return manager.game.board
        case (.waitingForPlayer(side: .light), _, .computer):
            return manager.game.board.flipped()
        case (_, _, _):
            return nil
        }
    }
    
    public var savedState: SavedState {
        switch manager.game.state {
        case .beingPlayed(turn: let turn as Disk?),
             .over(winner: let turn):
            return SavedState(
                turn: turn,
                darkPlayer: manager.darkPlayer,
                lightPlayer: manager.lightPlayer,
                board: manager.game.board
            )
        }
    }
}

// MARK: Input

extension GamePresenter {
    public mutating func tryPlacingDiskAt(x: Int, y: Int) {
        switch (manager.playingState, manager.darkPlayer, manager.lightPlayer) {
        case (.waitingForPlayer(side: .dark), .manual, _),
             (.waitingForPlayer(side: .light), _, .manual):
            try? manager.placeDiskAt(x: x, y: y)
        case (_, _, _):
            break
        }
    }
    
    public mutating func placeDiskAt(x: Int, y: Int) throws {
        try manager.placeDiskAt(x: x, y: y)
    }
    public mutating func completePlacingDisks() { manager.completePlacingDisks() }
    public mutating func completeConfirmationForPass() { manager.completeConfirmationForPass() }
    public mutating func confirmToReset() { manager.confirmToReset() }
    public mutating func completeConfirmationForReset(_ resets: Bool) { manager.completeConfirmationForReset(resets) }
    
    public init(savedState: SavedState) {
        let manager: GameManager = .init(
            game: Game(board: savedState.board, turn: savedState.turn ?? .dark),
            darkPlayer: savedState.darkPlayer,
            lightPlayer: savedState.lightPlayer
        )
        self.init(manager: manager)
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
