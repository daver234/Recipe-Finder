//
//  RecipeDetailViewModel.swift
//  BlueCart
//
//  Created by David Rothschild on 11/9/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation

class RecipeDetailViewModel {
    fileprivate(set) var newRecipe = [String: RecipeDetail]()
    fileprivate(set) var theRecipe: Box<[String: RecipeDetail]>  = Box([String: RecipeDetail]())
}


/// Functions to access the DataManager Singleton
extension RecipeDetailViewModel {
    func getRecipe() -> [String: RecipeDetail] {
        return newRecipe
    }
}

/// Functions to access DataManager Singleton
extension RecipeDetailViewModel {
    func loadDetailRecipe(recipeId: String) {
        let request = Request()
        let apiManager = APIManager(request: request)
        apiManager.getDetailedRecipe(recipeId: recipeId) { (response, error) in
            guard error == nil else {
                print("Error in getDetailedRecipe", error.debugDescription)
                return
            }
            guard let recipe = response else {
                print("Problem with response in detail recipe")
                return
            }
            self.newRecipe = recipe
            self.theRecipe = Box(self.newRecipe)
        }
    }
}
