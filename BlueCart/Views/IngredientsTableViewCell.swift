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
        let checkbox = M13Checkbox(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
        checkbox.markType = .checkmark
        checkbox.checkmarkLineWidth = 1.0
        checkedBoxView.addSubview(checkbox)
    }
}
