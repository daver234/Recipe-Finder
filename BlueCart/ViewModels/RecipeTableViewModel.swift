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
    var currentSearchString: Box<String> = Box("")
    fileprivate(set) var searchTerms: Box<[NSManagedObject]> = Box([])
    fileprivate(set) var currentPageNumber: Box<Int> = Box(0)
    var networkReachable = true
    fileprivate(set) var isSearching = false
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
    func loadRecipesForExistingSearchTerm() {
        if !isSearching {
            isSearching = true
            loadRecipes(pageNumber: currentPageNumber.value + 1, searchString: currentSearchString.value)
        }
    }
    
    /// This function loads different recipes based on whether or not the device is online or offline.
    /// If offline, then retrieve saved recipes.  If online, do a search.
    func loadRecipesBasedOnSearchTerm(searchString: String) {
        if networkReachable {
            isSearching = true
            currentPageNumber.value = 0
            currentSearchString.value = searchString
            loadRecipes(pageNumber: 1, searchString: searchString) 
        } else {
            /// pageNumber is not needed when offline since loading all saved recipes at once, not pages.
            /// So 4 pages would produce 120 recipes (30 per page), then 120 recipes will load if device
            /// is offline.
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
                self?.currentPageNumber.value = DataManager.instance.numberOfPagesRetrieved   //currentPageNumber.value += 1
                self?.didGetRecipes.value = true
                self?.isSearching = false
            }
        }
    }
    
    fileprivate func getAPIManagerInstance() -> APIManager {
        let request = Request()
        return APIManager(request: request)
    }
}
