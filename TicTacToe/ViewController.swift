import UIKit

class ViewController: UIViewController {

	@IBOutlet private weak var collectionView: UICollectionView!
	@IBOutlet weak var selectedPlayoption: UISegmentedControl!

	static var optionToPlay: [Int: String] = [
		0: "X",
		1: "O"
	]

	let size = 9
	static var play: [Play?] = Array(repeating: nil, count: 9)
	let validWins = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [2, 4, 6], [0, 4, 8]]
	var playerOnePlaySequence: [Int] = []
	var playerTwoPlaySequence: [Int] = []
	var playStack: [Int] = []
	var lastPlayer: Int = 0


	override func viewDidLoad() {
		super.viewDidLoad()
		self.collectionView.dataSource = self
		self.collectionView.delegate = self
	}

	@IBAction func reset() {
		ViewController.play = Array(repeating: nil, count: 9)
		self.playerTwoPlaySequence.removeAll()
		self.playerOnePlaySequence.removeAll()
		self.selectedPlayoption.selectedSegmentIndex = 0
		self.collectionView.reloadData()
	}

	@IBAction func undo() {
		self.undoLastPlay()
	}

}

struct Play {
	let player: Int
	let play: String

	init(player: Int, play: String) {
		self.player = player
		self.play = play
	}
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		self.playStack.append(indexPath.row)
		let play = ViewController.optionToPlay[self.selectedPlayoption.selectedSegmentIndex] ?? ""
		ViewController.play[indexPath.row] = Play(player: self.selectedPlayoption.selectedSegmentIndex, play: play)
		self.lastPlayer = self.selectedPlayoption.selectedSegmentIndex
		if self.selectedPlayoption.selectedSegmentIndex == 0 {
			playerOnePlaySequence.append(indexPath.row)
			self.selectedPlayoption.selectedSegmentIndex = 1
		} else {
			self.selectedPlayoption.selectedSegmentIndex = 0
			playerTwoPlaySequence.append(indexPath.row)
		}

		collectionView.reloadData()
		evaluateWin()
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		let balance = (self.collectionView.frame.size.width - 15) / 3
		return CGSize(width: balance, height: balance)
	}

	func evaluateWin() {
		for state in validWins {
			if contains(sequence: playerOnePlaySequence, state: state) {
				self.showAlert(string: "X has won!")
				return
			}
			if contains(sequence: playerTwoPlaySequence, state: state) {
				self.showAlert(string: "O has won!")
				return
			}
		}

		if (playerOnePlaySequence.count + playerTwoPlaySequence.count) == 9 {
			self.showAlert(string: "This is a draw")
			return
		}
	}

	func undoLastPlay() {
		if !self.playStack.isEmpty {
			let lastPlayedIndex = self.playStack.removeLast()
			ViewController.play[lastPlayedIndex] = nil
			if self.lastPlayer == 0 {
				if !self.playerOnePlaySequence.isEmpty {
					self.playerOnePlaySequence.removeLast()
				}
			} else {
				if !self.playerTwoPlaySequence.isEmpty {
					self.playerTwoPlaySequence.removeLast()
				}
			}
			self.selectedPlayoption.selectedSegmentIndex = self.lastPlayer
			self.collectionView.reloadData()
		} else {
			self.reset()
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
}

extension ViewController {
	func showAlert(string: String) {
		let alert = UIAlertController(title: "Notice!",
									  message: string,
									  preferredStyle: .alert)
		let reload = UIAlertAction(title: "Reload", style: .default) { [weak self] (action) in
			ViewController.play = Array(repeating: nil, count: 9)
			self?.playerTwoPlaySequence.removeAll()
			self?.playerOnePlaySequence.removeAll()
			self?.selectedPlayoption.selectedSegmentIndex = 0
			self?.collectionView.reloadData()
		}

		let okay = UIAlertAction(title: "OK", style: .default)
		alert.addAction(reload)
		alert.addAction(okay)
		self.present(alert, animated: false) {

		}
	}
}

extension ViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as? CollectionViewCell else {
			return UICollectionViewCell()
		}
		guard let play = ViewController.play[indexPath.row]
			else {
				cell.setPlayedValue(playedValue: "")
				return cell }
		cell.setPlayedValue(playedValue: play.play)
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return size
	}
}

