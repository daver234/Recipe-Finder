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
    
    var detailFood: Food? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        guard let detailFoody = detailFood else { return }
        guard let foodNameLabel2 = foodNameLabel, let foodCategoryLabel2 = foodCategoryLabel else { return }
        foodNameLabel2.text = detailFoody.name
        foodCategoryLabel2.text = detailFoody.category
    }

}
