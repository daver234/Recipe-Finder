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
           // no action
        }
    }
    
    /// Get count of total recipes retrieved.
    func getTotalRecipesRetrieved() -> Int? {
        return DataManager.instance.totalRecipesRetrieved
    }
    
    /// This function loads more recipes for the existing search term as the user scrolls the table view
    func loadRecipesForExistingSearchTerm() {
        var term = ""
        DataManager.instance.lastSearchTerm == "Top Rated" ? (term = "") : (term = DataManager.instance.lastSearchTerm)
        loadRecipes(pageNumber: DataManager.instance.numberOfPagesRetrieved + 1, searchString: term)
    }
    
    /// Get number of pages retrieved.
    /// This is the same as the last page retrieved.
    /// Use this number to check if need another page of recipes
    /// while using the DetailPageViewController.
    func getPagesRetrieved() -> Int? {
        return DataManager.instance.numberOfPagesRetrieved
    }
    
    /// Get all the recipes retrievd so far
    func getAllRecipes() -> [Recipe]? {
        return DataManager.instance.allRecipesWithoutPages
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
    
    /// Primary function to get RecipePage from backend
    /// Used on app launch, search terms, and prefetching more table rows
    fileprivate func loadRecipes(pageNumber: Int, searchString: String) {
        let apiManager = getAPIManagerInstance()
        apiManager.getRecipesForPage(pageNumber: pageNumber, searchString: searchString) { success in
            if success {
                print("Got another page of data", success)
            }
        }
    }
    
    fileprivate func getAPIManagerInstance() -> APIManager {
        let request = Request()
        return APIManager(request: request)
    }
}
