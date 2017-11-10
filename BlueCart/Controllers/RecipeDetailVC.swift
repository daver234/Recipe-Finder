//
//  RecipeDetailVC.swift
//  BlueCart
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit

class RecipeDetailVC: UIViewController {

    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var foodCategoryLabel: UILabel!
    
    var detailRecipe: Recipe? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        guard let detailRecipe = detailRecipe else { return }
        guard let recipeNameLabel = foodNameLabel, let recipeNumber = foodCategoryLabel else { return }
        recipeNameLabel.text = detailRecipe.title
        recipeNumber.text = detailRecipe.recipeID
    }

}
