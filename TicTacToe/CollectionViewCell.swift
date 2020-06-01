import UIKit

class CollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var label: UILabel!

	func setPlayedValue(playedValue: String) {
		self.label.text = playedValue
	}
}
