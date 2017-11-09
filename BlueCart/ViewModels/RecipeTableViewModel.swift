//
//  RecipeTableViewModel.swift
//  BlueCart
//
//  Created by David Rothschild on 11/8/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation

/// ViewModel to support RecipeTableVC
class RecipeTableViewModel {
    
    // MARK: - Properties
    // fileprivate var pageNumber = 1
    // var recipeCount: Box<Int> = Box(0)
    var didGetRecipes: Box<Bool> = Box(false)
    var recipePageNumber: Box<Int> = Box(0)
    
}

extension RecipeTableViewModel {
    func loadRecipes() {
        let request = Request()
        let apiManager = APIManager(request: request)
        apiManager.getRecipesForPage(pageNumber: recipePageNumber.value) { [weak self] success in
            if success {
                self?.recipePageNumber.value += 1
            }
            
        }
    }
    
    func getRecipeCount() -> Int? {
        return DataManager.instance.totalRecipesRetrieved
    }
}
