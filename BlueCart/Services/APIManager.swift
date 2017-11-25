//
//  APIManager.swift
//  BlueCart
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation

/// Functions to get data from backend
/// Injecting a Request object upon initialization.
/// Therefore, APIManager does not depend on a specific and concrete class
/// but instead relies on the protocol abstraction
class APIManager {
    let request: AbstractRequestClient
    
    init(request: AbstractRequestClient) {
        self.request = request
    }
    
    /// Get recipes for RecipeTableVC
    /// - Parameter pageNumber: The next page number filled with 30 recipes from the backend server
    /// - Parameter completion: The completion handler to execute on success or failure
    func getRecipesForPage(pageNumber: Int, searchString: String, completion: @escaping CompletionHandler) {
        guard let encodedSearchTerm = searchString.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let urlString = "\(Constants.SEARCH_URL)\(APIKeyService.API_KEY)&q=\(encodedSearchTerm)&page=\(pageNumber)&sort=r"
        print("here is urlString", urlString)
        guard let url = URL(string: urlString) else { return }
        request.callAPIForPage(searchString: searchString, url: url, completion: completion)
    }
    
    /// Get recipe detail with ingredients for RecipeDetailVC
    /// - Parameter reachable: Bool to indicate if network is reachable
    /// - Parameter recipeId: The ID of the recipe to retrieve
    /// - Parameter completion: The completion handler to execute on success or failure
    func getDetailedRecipe(reachable: Bool, recipeId: String, completion: @escaping CompletionHandlerWithData) {
        let urlString = "\(Constants.RECIPE_URL)\(APIKeyService.API_KEY)&\(Constants.RECIPE_ID)=\(recipeId)"
        guard let url = URL(string: urlString) else { return }
        request.callAPIForDetail(reachable: reachable, recipeId: recipeId, url: url, completion: completion)
    }
}
