//
//  IngredientsTableViewCell.swift
//  BlueCart
//
//  Created by David Rothschild on 11/10/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit
import M13Checkbox

class IngredientsTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var checkedBoxView: UIView!

    func setupView(ingredient: String) {
        ingredientLabel.text = ingredient
    }
}
