import UIKit

class ViewController: UIViewController {

	@IBOutlet private weak var collectionView: UICollectionView!
	@IBOutlet weak var selectedPlayoption: UISegmentedControl!

	private var viewModel: ViewModel = TicTacToe()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.collectionView.dataSource = self
		self.collectionView.delegate = self
	}

	@IBAction func reset() {
		reload()
	}

	@IBAction func undo() {
		self.undoLastPlay()
	}

}

extension ViewController {
	func undoLastPlay() {
		let nextPlayer = self.viewModel.undoLastPlay {
			self.collectionView.reloadData()
		}
		self.selectedPlayoption.selectedSegmentIndex = nextPlayer
	}

	func reload() {
		self.selectedPlayoption.selectedSegmentIndex = self.viewModel.reset()
		self.collectionView.reloadData()
	}

	func showAlert(string: String) {
		let alert = UIAlertController(title: "Notice!",
									  message: string,
									  preferredStyle: .alert)
		let reload = UIAlertAction(title: "Reload", style: .default) { [weak self] (action) in
			self?.reload()
		}
		let okay = UIAlertAction(title: "OK", style: .default)
		alert.addAction(reload)
		alert.addAction(okay)
		self.present(alert, animated: false)
	}
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let lastPlayer = self.selectedPlayoption.selectedSegmentIndex
		let nextPlayer = self.viewModel.updateGame(lastPlayer: lastPlayer,
												   cellPlayed: indexPath.row,
												   status: {
													[weak self] (state) in
				self?.showAlert(string: state.rawValue)
		})
		self.selectedPlayoption.selectedSegmentIndex = nextPlayer
		collectionView.reloadData()
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		let length = (self.collectionView.frame.size.width - 15) / 3
		return CGSize(width: length, height: length)
	}
}

extension ViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as? CollectionViewCell else {
			return UICollectionViewCell()
		}
		let playText = self.viewModel.getPlay(for: indexPath.row)
		cell.setPlayedValue(playedValue: playText)
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.viewModel.size
	}
}

