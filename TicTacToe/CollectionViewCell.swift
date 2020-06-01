//
//  CollectionViewCell.swift
//  TicTacToe
//
//  Created by Damilola Akapo on 01/06/2020.
//  Copyright © 2020 tictactoe. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var label: UILabel!

	func setPlayedValue(playedValue: String) {
		self.label.text = playedValue
	}
}
