//
//  RecipeTableViewCell.swift
//  BlueCart
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var foodCategoryLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupView(recipe: Recipe) {
        foodCategoryLabel.text = recipe.title   // food.category
        foodNameLabel.text = recipe.recipeID // food.name
    }
}
