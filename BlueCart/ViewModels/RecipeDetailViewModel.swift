//
//  RecipeDetailViewModel.swift
//  BlueCart
//
//  Created by David Rothschild on 11/9/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation

class RecipeDetailViewModel {
    fileprivate(set) var newRecipe = [String: Recipe]()
    fileprivate(set) var theRecipe: Box<[String: Recipe]>  = Box([String: Recipe]())
    fileprivate(set) var viewRecipe: Box<Recipe> = Box(Recipe())
    var networkReachable = true
}


/// Functions to access the DataManager Singleton
extension RecipeDetailViewModel {
    func getRecipe() -> [String: Recipe] {
        return newRecipe
    }
    
    // Set the recipe to use in the RecipeDetailVC
    func setRecipe(recievedRecipe: Recipe)  {
        viewRecipe.value = recievedRecipe
        print("viewRecipe", viewRecipe.value)
    }
    
    /// Change network reachable status
    func isNetworkReachable(reachable: Bool) {
        networkReachable = reachable
    }
    
    /// Get a specific recipe.  Changes retrieval function based on online or offline
    /// - Parameter recipeID: The ID of the recipe to retrieve.
    func getRecipeDetail(recipeID: String) {
        if networkReachable {
           loadDetailRecipe(recipeId: recipeID)
        } else {
            // recipeToReturn = RetrieveRecipes().retrievedSavedRecipes(searchTerm: <#T##String#>)
        }
        
    }
}

/// Functions to access DataManager Singleton
extension RecipeDetailViewModel {
    func loadDetailRecipe(recipeId: String) {
        let request = Request()
        let apiManager = APIManager(request: request)
        apiManager.getDetailedRecipe(reachable: networkReachable, recipeId: recipeId) { (response, error) in
            guard error == nil else {
                print("Error in getDetailedRecipe", error.debugDescription)
                return
            }
            guard let recipe = response else {
                print("Problem with response in detail recipe")
                return
            }
            self.newRecipe = recipe
            self.theRecipe.value = recipe
        }
    }
}
