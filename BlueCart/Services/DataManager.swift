//
//  DataManager.swift
//  BlueCart
//
//  Created by David Rothschild on 11/8/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation

/// A singleton class to manage data received from the backend
class DataManager {
    
    static let instance = DataManager()
    
    // MARK: - Variables
    fileprivate(set) var allRecipes = [RecipePage]()
    fileprivate(set) var numberOfPagesRetrieved = 0
    fileprivate(set) var totalRecipesRetrieved = 0
    fileprivate(set) var allRecipesWithoutPages = [Recipe]()
    
    private init() {
    }
    
    /// Decode full page of recipes
    func decodeDataForPage(data: Data, completion: @escaping CompletionHandler) {
        do {
            let result = try JSONDecoder().decode(RecipePage.self, from: data)
            self.allRecipes.append(result)
            
            /// Update all variables
            self.numberOfPagesRetrieved += 1
            self.updateNewRecipesRetrieved(result: result)
            guard let recipeResult = result.recipes else { return }
            for item in recipeResult {
                allRecipesWithoutPages.append(item)
            }
            
            completion(true)
        } catch let jsonError {
            print("Error decoding JSON from server", jsonError)
            completion(false)
        }
    }
    
    /// Update count of individual recipes retrieved
    func updateNewRecipesRetrieved(result: RecipePage) {
        guard let newRecipesRetrieved = result.recipes?.count else { return }
        self.totalRecipesRetrieved += newRecipesRetrieved
        print("^^^ totalRecipesRetrieved", self.totalRecipesRetrieved)
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
