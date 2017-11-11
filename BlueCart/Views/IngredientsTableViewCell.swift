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
    // @IBOutlet weak var checkBoxView: M13Checkbox!
    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var checkedBoxView: UIView!
    
    // MARK: - Functions
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }

    func setupView(ingredient: String) {
        ingredientLabel.text = ingredient
        //checkBoxView.boxType = .circle
        let checkbox = M13Checkbox(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
        checkbox.markType = .checkmark
        checkbox.checkmarkLineWidth = 2.0
        checkedBoxView.addSubview(checkbox)
    }
}
