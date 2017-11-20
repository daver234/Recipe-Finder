//
//  DataManager.swift
//  BlueCart
//
//  Created by David Rothschild on 11/8/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation
import Disk

/// A singleton class to manage data received from the backend
class DataManager {
    
    static let instance = DataManager()
    
    // MARK: - Variables
    fileprivate(set) var allRecipes = [RecipePage]()
    fileprivate(set) var numberOfPagesRetrieved = 0
    fileprivate(set) var totalRecipesRetrieved = 0
    fileprivate(set) var allRecipesWithoutPages = [Recipe]()
    var lastSearchTerm = ""
    var saveRecipes = SaveRecipes()
    
    private init() {
    }

    /// Decode full page of recipes
    func decodeDataForPage(searchString: String, data: Data, completion: @escaping CompletionHandler) {
        if searchString != lastSearchTerm {
            resetDataManagerVariables()
             lastSearchTerm = searchString
        }
        do {
            let result = try JSONDecoder().decode(RecipePage.self, from: data)
            updateAllVariables(result: result)
            saveRecipes.saveRecipePageCoreData(searchTerm: searchString, pageNumber: numberOfPagesRetrieved, recipePage: result)
            completion(true)
        } catch let jsonError {
            print("Error decoding JSON from server", jsonError)
            completion(false)
        }
    }
    
    /// Decode specific data like a recipe
    func decodeDataForDetail(data: Data, completion: @escaping CompletionHandlerWithData) {
        do {
            let result = try JSONDecoder().decode([String: RecipeDetail].self, from: data)
            completion(result, nil)
        } catch let jsonError {
            print("Error decoding JSON from server", jsonError)
            completion(nil, jsonError)
        }
    }
}


/// MARK: - Supporting Functions
extension DataManager {
    
    /// Update count of individual recipes retrieved
    func updateNewRecipesRetrieved(result: RecipePage) {
        guard let newRecipesRetrieved = result.recipes?.count else { return }
        self.totalRecipesRetrieved += newRecipesRetrieved
    }
    
    /// Update all variables after decode
    func updateAllVariables(result: RecipePage) {
        self.numberOfPagesRetrieved += 1
        self.updateNewRecipesRetrieved(result: result)
        guard let recipeResult = result.recipes else { return }
        self.allRecipes.append(result)
        for item in recipeResult {
            allRecipesWithoutPages.append(item)
        }
    }
    
    /// Used when a specific search term has been entered
    /// Allows re-use of RecipeTableVC
    func resetDataManagerVariables() {
        allRecipes.removeAll()
        numberOfPagesRetrieved = 0
        totalRecipesRetrieved = 0
        allRecipesWithoutPages.removeAll()
    }
}

/// Retrive recent searches to disk for use in offline situations.
extension DataManager {
    func retrieveSavedSearchTermResults(term: String) {
        resetDataManagerVariables()
        var termTrimmed = term.lowercased().replacingOccurrences(of: " ", with: "")
        termTrimmed == "" ? (termTrimmed = Constants.TOP_RATED_FILE) : (termTrimmed = termTrimmed)
        if Disk.exists("Recipe/\(termTrimmed)", in: .caches) {
            print("file exists", termTrimmed)
        }
        do {
            let retrieveSearch = try Disk.retrieve("Recipe/\(termTrimmed)", from: .caches, as: RecipePage.self)
            updateAllVariables(result: retrieveSearch)
        } catch let error as NSError {
            fatalError("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
    }
    
    func retrieveSavedDetailedRecipeWithIngredients(recipeId: String, completion: @escaping CompletionHandlerWithData) {
        if Disk.exists("\(recipeId)", in: .caches) {
            do {
                let retrieveSearch = try Disk.retrieve("\(recipeId)", from: .caches, as: Data.self)
                DataManager.instance.decodeDataForDetail(data: retrieveSearch, completion: completion)
            } catch let error as NSError {
                completion(nil, error)
                fatalError("""
                    Domain: \(error.domain)
                    Code: \(error.code)
                    Description: \(error.localizedDescription)
                    Failure Reason: \(error.localizedFailureReason ?? "")
                    Suggestions: \(error.localizedRecoverySuggestion ?? "")
                    """)
            }
        } else {
            completion(nil, nil)
        }
    }
}
