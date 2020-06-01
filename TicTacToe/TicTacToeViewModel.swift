import Foundation

struct TicTacToe: ViewModel {
	let size: Int = 9

	var optionToPlay: [Int: String] = [
		0: "X",
		1: "O"
	]
	var play: [Play?] = Array(repeating: nil, count: 9)
	let validWins = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [2, 4, 6], [0, 4, 8]]
	var playerXStack: [Int] = []
	var playerOStack: [Int] = []
	var fullGameStack: [Int] = []
	var gameplayStack: [Int] = []

	func getPlay(for index: Int) -> String {
		return self.play[index]?.play ?? ""
	}

	mutating func undoLastPlay(_ undoDone: () -> Void) -> Int {
		if !self.fullGameStack.isEmpty {
			debugPrint("gameplay stack \(self.gameplayStack)")
			let lastPlayedIndex = self.fullGameStack.removeLast()
			self.play[lastPlayedIndex] = nil
			if playerXStack.contains(lastPlayedIndex) {
				playerXStack.removeAll { (value) -> Bool in
					return value == lastPlayedIndex
				}
			}
			if playerOStack.contains(lastPlayedIndex) {
				playerOStack.removeAll { (value) -> Bool in
					return value == lastPlayedIndex
				}
			}
		} else {
			self.reset()
		}
		undoDone()
		return self.gameplayStack.isEmpty ? 0: self.gameplayStack.removeLast()
	}

	func evaluateWin(wincase: (WinState) -> Void) {
		for state in validWins {
			if contains(sequence: self.playerXStack, state: state) {
				wincase(.xwon)
				return
			}
			if contains(sequence: self.playerOStack, state: state) {
				wincase(.owon)
				return
			}
		}

		if (self.playerOStack.count + self.playerXStack.count) == 9 {
			wincase(.draw)
			return
		}
	}

	func contains(sequence: [Int], state: [Int]) -> Bool {
		var count = 0
		for s in state {
			if sequence.contains(s) {
				count+=1
			}
		}
		return count == 3
	}

	mutating func updateGame(lastPlayer: LastPlayer,
							 cellPlayed: Int,
							 status: (WinState) -> Void) -> NextPlayer {
		self.fullGameStack.append(cellPlayed)
		self.gameplayStack.append(lastPlayer)
		let play = self.optionToPlay[lastPlayer] ?? ""
		self.play[cellPlayed] = Play(player: lastPlayer, play: play)
		if lastPlayer == 0 {
			self.playerXStack.append(cellPlayed)
		} else {
			self.playerOStack.append(cellPlayed)
		}
		evaluateWin(wincase: status)
		return lastPlayer == 0 ? 1: 0
	}

	@discardableResult
	mutating func reset() -> Int {
		self.play = Array(repeating: nil, count: 9)
		self.playerXStack.removeAll()
		self.playerOStack.removeAll()
		self.gameplayStack.removeAll()
		return 0
	}

}

enum WinState: String {
	case xwon = "X has won!"
	case owon = "O has won!"
	case draw = "Game is a draw!"
}

protocol ViewModel {
	var size: Int { get }
	func getPlay(for index: Int) -> String

	@discardableResult
	mutating func reset() -> Int

	typealias LastPlayer = Int
	mutating func undoLastPlay(_ undoDone: () -> Void) -> Int

	typealias NextPlayer = Int
	mutating func updateGame(lastPlayer: LastPlayer, cellPlayed: Int, status: (WinState) -> Void) -> NextPlayer
}
