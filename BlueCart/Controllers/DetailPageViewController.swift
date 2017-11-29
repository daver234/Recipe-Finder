//
//  DetailPageViewController.swift
//  BlueCart
//
//  Created by David Rothschild on 11/28/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit

class DetailPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // MARK: - Properties
    var isReachable : Bool?
    var indexFromAllRecipesWithoutPages: Int?
    var viewModel = RecipeDetailViewModel()
    var recipeFromTable: Recipe?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.navigationController?.navigationBar.tintColor = ColorPalette.Black.Medium
  
        if let viewController = getViewControllerAtIndex(index: indexFromAllRecipesWithoutPages ?? 0) {
            let viewControllers = [viewController]
            setViewControllers(
                viewControllers,
                direction: .forward,
                animated: false,
                completion: nil
            )
        }
    }

    /// Set up previous view controller with correct recipe
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? RecipeDetailVC, var index = viewController.indexForRecipe, index > 0 {
            index -= 1
            return getViewControllerAtIndex(index: index)
        }
        return nil
    }
    // , let recipesRetrieved = viewModel.getTotalRecipesRetrieved(), (index + 1) < recipesRetrieved
    /// Set up next view controller with correct content
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? RecipeDetailVC, var index = viewController.indexForRecipe else  { return nil }
        guard let recipesRetrieved = viewModel.getTotalRecipesRetrieved(), (index + 1) < recipesRetrieved else { print("next controller N/A") ;return nil }
        index += 1
        return getViewControllerAtIndex(index: index)
    }
    
    func getViewControllerAtIndex(index: Int) -> RecipeDetailVC? {
        guard let storyboard = storyboard, let recipeDetailVC = storyboard.instantiateViewController(withIdentifier: Constants.RECIPE_DETAIL_SB) as? RecipeDetailVC else { return RecipeDetailVC() }
        guard let recipes = viewModel.getAllRecipes() else { return nil }
        recipeDetailVC.indexForRecipe = index
        recipeDetailVC.recipeFromTable = recipes[index]
        recipeDetailVC.isReachable = isReachable
        

        /// If coming to the end of the recipes retrieved, need to make sure more data is fetched
        guard let total = viewModel.getTotalRecipesRetrieved() else { return nil }
        if (index + 5) >= total {
            viewModel.loadRecipesForExistingSearchTerm()
        }
        return recipeDetailVC
    }
}
