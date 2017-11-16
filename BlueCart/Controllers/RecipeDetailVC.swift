//
//  RecipeDetailVC.swift
//  BlueCart
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit
import Kingfisher
import M13Checkbox


class RecipeDetailVC: UIViewController, UITableViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var socialRankLabel: UILabel!
    @IBOutlet weak var recipeIdLabel: UILabel!
    @IBOutlet weak var recipeTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var recipeFromTable: Recipe?
    var viewModel = RecipeDetailViewModel()
    var isReachable : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Constants.RECIPE_TITLE
        tableView.dataSource = self
        guard let reach = isReachable else { return }
        viewModel.networkReachable = reach
        guard let recipe = recipeFromTable, let recipeId = recipe.recipeID else { return }
        viewModel.loadDetailRecipe(recipeId: recipeId)
        configureView()
        monitorProperties()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func configureView() {
        guard let newRecipe = recipeFromTable else { return }
        guard let rank = newRecipe.socialRank, let recipeID = newRecipe.recipeID, let imageUrl = newRecipe.imageUrl, let title = newRecipe.title else { return }
        self.recipeTitleLabel.text = title
        let socialRankString = String(format: "%.2f", rank)
        self.socialRankLabel.text = socialRankString
        self.recipeIdLabel.text = recipeID
        let image = UIImage(named: Constants.LOADING_IMAGE)
        let url = URL(string: imageUrl)
        DispatchQueue.main.async {
            self.recipeImage.kf.setImage(with: url, placeholder: image)
        }
    }
    
    func monitorProperties() {
        viewModel.theRecipe.bind { [unowned self] (value) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}


extension RecipeDetailVC:  UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let ingredients = viewModel.newRecipe["recipe"]?.ingredients else {
            /// If the recipe was not viewed while online then ingredients are not available.
            /// Put up a message in the table view explaining this case.
            guard let reachable = isReachable  else { return 0 }
            if !reachable {
                TableViewHelper.EmptyMessage(message: Constants.NO_INGREDIENTS, viewController: self, tableView: tableView)
            }
            return 0
        }
        tableView.backgroundView = UIView(frame: .zero)
        return  ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.INGREDIENTS, for: indexPath) as? IngredientsTableViewCell else {
            return UITableViewCell()
        }
        guard let ingredients = viewModel.newRecipe["recipe"]?.ingredients else { return UITableViewCell() }
        cell.setupView(ingredient: ingredients[indexPath.row])
        cell.setNeedsLayout()
        return cell
    }
}
