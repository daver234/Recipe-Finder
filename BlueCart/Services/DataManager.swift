//
//  DataManager.swift
//  BlueCart
//
//  Created by David Rothschild on 11/8/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation
import Kingfisher

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
            saveRecipes.saveRecipePageToCoreData(searchTerm: searchString, pageNumber: numberOfPagesRetrieved, recipePage: result)
            completion(true)
        } catch let jsonError {
            print("Error decoding JSON from server", jsonError)
            completion(false)
        }
    }
    
    /// Decode specific data like a recipe
    func decodeDataForDetail(data: Data, completion: @escaping CompletionHandlerWithData) {
        do {
            let result = try JSONDecoder().decode([String: Recipe].self, from: data)
            guard let ingredients = result["recipe"]?.ingredients, let recipeID = result["recipe"]?.recipeID else { return }
            SaveRecipes().saveIngredietsToRecipe(ingredients: ingredients, recipeID: recipeID)
            completion(result, nil)
        } catch let jsonError {
            print("Error decoding JSON from server", jsonError)
            completion(nil, jsonError)
        }
    }
}


/// MARK: - Supporting Functions
extension DataManager {
    
    /// Keep fetching images for all loaded and saved recipes,
    /// so that they are available offline.
    func prefetchImagesForAllRecipes() {
        var stringToUrl = [URL]()
        for item in allRecipesWithoutPages {
            guard let stringUrl = item.imageUrl, let url = URL(string: stringUrl) else { return }
            stringToUrl.append(url)
        }
        let urls = stringToUrl.flatMap { $0 }
        ImagePrefetcher(urls: urls).start()
    }
    
    /// Update count of individual recipes retrieved from a RecipePage
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
        prefetchImagesForAllRecipes()
    }
    
    /// Update all variables after retrieving recipes from Core Data.
    /// Used when device is offline.
    /// First up, need to get the stored recipes from core data.
    func updateAllVariablesWhenOffline(searchTerm: String, completion: @escaping CompletionHandler) {
        RetrieveRecipes().retrievedSavedRecipes(searchTerm: searchTerm) { [weak self] (result, error) in
            if error == nil {
                guard let recipes = result else {
                    print("Error retrieving saved recipes")
                    completion(false)
                    return
                }
                self?.totalRecipesRetrieved = recipes.count
                self?.allRecipesWithoutPages = recipes
                self?.numberOfPagesRetrieved += 1
                (self?.totalRecipesRetrieved ?? 0) > 0 ? completion(true) : completion(false)
            } else {
                print("Error retrieving saved recipes.")
                completion(false)
            }
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
