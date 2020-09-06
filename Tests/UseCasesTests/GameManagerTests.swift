import XCTest
import SwiftyReversi
import UseCases

final class GamaManagerTests: XCTestCase {
    func testPlaceDistAt() {
        var manager = GameManager(game: Game(board: Board("""
        ----
        -oxx
        -oxx
        xx-x
        """), turn: .dark), darkPlayer: .manual, lightPlayer: .manual)

        manager.placeDiskAt(x: 0, y: 1)
        
        XCTAssertEqual(manager.playState, .flippingDisks(side: .dark, from: Board("""
        ----
        -oxx
        -oxx
        xx-x
        """)))
    }
    
    func testCompleteFlippingDisks() {
        let manager = GameManager(game: Game(board: Board("""
        ----
        -oxx
        -oxx
        xx-x
        """), turn: .dark), darkPlayer: .manual, lightPlayer: .manual)
        
        do { // .waitingForPlayer
            var manager = manager
            manager.placeDiskAt(x: 0, y: 1)
            manager.completeFlippingDisks()
            
            XCTAssertEqual(manager.playState, .waitingForPlayer(side: .light))
        }
        
        do { // .passing
            var manager = manager
            manager.placeDiskAt(x: 0, y: 2)
            manager.completeFlippingDisks()
            
            XCTAssertEqual(manager.playState, .passing(side: .light))
        }
        
        do { // .over
            var manager = manager
            manager.placeDiskAt(x: 1, y: 0)
            manager.completeFlippingDisks()
            
            XCTAssertEqual(manager.playState, .over(winner: .dark))
        }
    }
    
    func testPass() {
        var manager = GameManager(game: Game(board: Board("""
        ----
        -oxx
        xxxx
        xx-x
        """), turn: .light), darkPlayer: .manual, lightPlayer: .manual)
        
        manager.pass()
        
        XCTAssertEqual(manager.playState, .waitingForPlayer(side: .dark))
    }
    
    func testReset() {
        var manager = GameManager(game: Game(board: Board("""
        ----
        xxxx
        -oxx
        xx-x
        """), turn: .light), darkPlayer: .computer, lightPlayer: .computer)
        
        manager.confirmToReset()
        
        XCTAssertEqual(manager.playState, .waitingForPlayer(side: .light))
        XCTAssertEqual(manager.resetState, .confirming)
        
        manager.placeDiskAt(x: 3, y: 0)
        
        XCTAssertEqual(manager.playState, .flippingDisks(side: .light, from: Board("""
        ----
        xxxx
        -oxx
        xx-x
        """)))
        XCTAssertEqual(manager.resetState, .confirming)

        do {
            var manager = manager
            
            manager.reset(true)
            
            XCTAssertEqual(manager.playState, .waitingForPlayer(side: .dark))
            XCTAssertEqual(manager.game.state, .beingPlayed(turn: .dark))
            XCTAssertEqual(manager.game.board, Board("""
            ----
            -ox-
            -xo-
            ----
            """))
            XCTAssertEqual(manager.resetState, .notConfirming)
        }
        
        do {
            var manager = manager
            
            manager.reset(false)
            
            XCTAssertEqual(manager.playState, .flippingDisks(side: .light, from: Board("""
            ----
            xxxx
            -oxx
            xx-x
            """)))
            XCTAssertEqual(manager.resetState, .notConfirming)
        }
    }
}
