//
//  RecipeTableViewModel.swift
//  BlueCart
//
//  Created by David Rothschild on 11/8/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit
import CoreData

/// ViewModel to support RecipeTableVC
class RecipeTableViewModel {
    
    // MARK: - Properties
    var didGetRecipes: Box<Bool> = Box(false)
    var recipePageNumber: Box<Int> = Box(0)
    var searchString: Box<String> = Box("")
    fileprivate(set) var searchTerms: Box<[NSManagedObject]> = Box([])
    fileprivate(set) var currentPageNumber: Box<Int> = Box(1)
    var networkReachable = true
}


// MARK: - Functions to access the DataManager singleton
extension RecipeTableViewModel {
    func getRecipeCount() -> Int? {
        return DataManager.instance.totalRecipesRetrieved
    }
    
    /// Get a specific recipe.  Changes retrieval function based on online or offline
    /// - Parameter pageToGet: The specific page to get the recipe from
    /// - Parameter recipeToGet: The index of the recipe to get
    /// - Parameter index: The cell index that needs the recipe.  Used for offline.
    func getRecipe(pageToGet: Int, recipeToGet: Int, index: Int) -> Recipe {
        var recipeToReturn = Recipe()
        if networkReachable {
            guard let recipe = DataManager.instance.allRecipes[pageToGet].recipes?[recipeToGet] else {
                return recipeToReturn
            }
            recipeToReturn = recipe
        } else {
            recipeToReturn = DataManager.instance.allRecipesWithoutPages[index]
        }
        return recipeToReturn
    }
    
    func getPagesRetrieved() -> Int {
        return DataManager.instance.numberOfPagesRetrieved
    }
    
    /// Change network reachable status
    func isNetworkReachable(reachable: Bool) {
        networkReachable = reachable
    }
    
    /// Load search terms for accessing recipe pages
    /// RecipeTableVC then gets individual search terms from view model
    func loadSearchTerms() {
        searchTerms.value = []
        guard let result = SearchTerms().retrievedSavedSearchTerms() else { return }
        searchTerms.value = result
    }
    
    /// This function loads more recipes for the existing search term as the user scrolls the table view
    func loadRecipesForExistingSearchTerm(pageNumber: Int) {
        currentPageNumber.value = pageNumber
        loadRecipes(pageNumber: pageNumber, searchString: searchString.value)
    }
    
    /// This function loads different recipes based on whether or not the device is online or offline.
    /// If offline, then retrieve saved recipes.  If online, do a search.
    func loadRecipesBasedOnSearchTerm(searchString: String) {
        if networkReachable {
            loadRecipes(pageNumber: recipePageNumber.value, searchString: searchString) 
        } else {
            DataManager.instance.updateAllVariablesWhenOffline(searchTerm: searchString) { [weak self] success in
                if success {
                    self?.didGetRecipes.value = true
                } else {
                    print("Did not get recipes from Core Data for offline use.")
                    self?.didGetRecipes.value = false
                }
            }
        }
        
    }
    
    /// Function for RecipeTableVC to save a new search term
    /// Then go get those recipes to display in table view
    /// - Parameter term:  The search term to save and find recipes
    func saveSearchTerm(term: String) {
        SearchTerms().saveSearchTermToCoreData(term: term)
        loadRecipesBasedOnSearchTerm(searchString: term)
    }
}


// MARK: - Functions for accessing backend server
extension RecipeTableViewModel {
    /// Primary function to get RecipePage from backend
    /// Used on app launch, search terms, and prefetching more table rows
    func loadRecipes(pageNumber: Int, searchString: String) {
        let apiManager = getAPIManagerInstance()
        apiManager.getRecipesForPage(pageNumber: pageNumber, searchString: searchString) { [weak self] success in
            if success {
                self?.recipePageNumber.value += 1
                self?.didGetRecipes.value = true
            }
        }
    }
    
    fileprivate func getAPIManagerInstance() -> APIManager {
        let request = Request()
        return APIManager(request: request)
    }
}
