import SwiftyReversi
import UseCases
import Foundation

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

extension SavedState {
    public init(data: Data) throws {
        guard let input = String(data: data, encoding: .utf8) else {
            throw FormatError(data: data)
        }
        var lines: ArraySlice<Substring> = input.split(separator: "\n")[...]
        
        guard var line = lines.popFirst() else {
            throw FormatError(data: data)
        }
        
        guard let diskSymbol = line.popFirst(),
              let turn = Optional<Disk>(symbol: diskSymbol) else {
            throw FormatError(data: data)
        }

        // darkPlayer
        guard let darkPlayerSymbol = line.popFirst(),
              let darkPlayer = Player(symbol: darkPlayerSymbol) else {
            throw FormatError(data: data)
        }

        // lightPlayer
        guard let lightPlayerSymbol = line.popFirst(),
              let lightPlayer = Player(symbol: lightPlayerSymbol) else {
            throw FormatError(data: data)
        }
        
        // board
        let board: Board
        do {
            var width: Int?
            let height: Int
            var disks: [Disk?] = []
            
            var y = 0
            while let line = lines.popFirst() {
                var x = 0
                for character in line {
                    let disk = Disk?(symbol: character).flatMap { $0 }
                    disks.append(disk)
                    x += 1
                }
                if let w = width {
                    guard x == w else {
                        throw FormatError(data: data)
                    }
                } else {
                    width = x
                }
                y += 1
            }
            height = y
            
            do { // scope to shadow `width` with `guard`
                guard let width = width else {
                    throw FormatError(data: data)
                }
                guard width >= 2,
                      height >= 2,
                      width.isMultiple(of: 2),
                      height.isMultiple(of: 2) else {
                    throw FormatError(data: data)
                }

                board = Board(width: width, height: height, disks: disks)
            }
        }

        self.init(
            turn: turn,
            darkPlayer: darkPlayer,
            lightPlayer: lightPlayer,
            board: board
        )
    }
    
    public var data: Data {
        var output: String = ""
        output += turn.symbol
        output += String(darkPlayer.symbol)
        output += String(lightPlayer.symbol)
        output += "\n"
        output.append(board.description)
        return output.data(using: .utf8)!
    }
    
    internal struct FormatError: Error {
        var data: Data
    }
}

private extension Player {
    init?(symbol: Character) {
        switch symbol {
        case "0": self = .manual
        case "1": self = .computer
        default: return nil
        }
    }
    
    var symbol: Character {
        switch self {
        case .manual: return "0"
        case .computer: return "1"
        }
    }
}

private extension Optional where Wrapped == Disk {
    init?(symbol: Character) {
        switch symbol {
        case "x": self = .some(.dark)
        case "o": self = .some(.light)
        case "-": self = .none
        default: return nil
        }
    }
}
