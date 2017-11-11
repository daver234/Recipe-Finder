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
    fileprivate(set) var flatAllRecipes = [Recipe]()
}


/// Functions to access the DataManager singleton
extension RecipeTableViewModel {
    func getRecipeCount() -> Int? {
        return DataManager.instance.totalRecipesRetrieved
    }
    
    func getAllRecipesWithoutPages() -> [Recipe] {
        return DataManager.instance.allRecipesWithoutPages
    }
    
    func getRecipe(pageToGet: Int, recipeToGet: Int) -> Recipe {
        guard let recipe = DataManager.instance.allRecipes[pageToGet].recipes?[recipeToGet] else {
            return Recipe()
        }
        return recipe
    }
    
    func getPagesRetrieved() -> Int {
        return DataManager.instance.numberOfPagesRetrieved
    }
    
    func getRecipes(pageNumber: Int) -> [Recipe] {
        guard let recipes = DataManager.instance.allRecipes[pageNumber].recipes else { return [Recipe]() }
        return recipes
    }
    
    func incrementPageNumber() {
        recipePageNumber.value += 1
    }
    
    /// Saving search terms to CoreData
    /// Handles iOS 10 and above one way and iOS 9 and below another
    /// - Parameter term: The search term to save
    func saveSearchTerm(term: String) {
        if #available(iOS 10.0, *) {
            let task = Search(context: CoreDataStack.managedObjectContext)
            task.searchTerms = term
        } else {
            // Fallback on earlier versions of iOS
            let entityDesc = NSEntityDescription.entity(forEntityName: Constants.SEARCH_TERM, in: CoreDataStack.managedObjectContext)
            let task = Search(entity: entityDesc!, insertInto: CoreDataStack.managedObjectContext)
            task.searchTerms = term
        }
        CoreDataStack.saveContext()
    }
}


/// Functions for accessing backend server
extension RecipeTableViewModel {
    func loadRecipes(pageNumber: Int) {
        let request = Request()
        let apiManager = APIManager(request: request)
        apiManager.getRecipesForPage(pageNumber: pageNumber) { [weak self] success in
            if success {
                self?.recipePageNumber.value += 1
                self?.didGetRecipes.value = true
            }
        }
    }
    
    func loadNewRecipesFromSearchText(searchTerm: String) {
        print("Search term is:", searchTerm)
    }
}
