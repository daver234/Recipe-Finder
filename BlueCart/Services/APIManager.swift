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
    func getRecipesForPage(pageNumber: Int, completion: @escaping CompletionHandler) {
        print("*** in APIManager: next pageNumber to get is:", pageNumber)
        let urlString = "\(Constants.SEARCH_URL)\(APIKeyService.API_KEY)&page=\(pageNumber)"
        guard let url = URL(string: urlString) else { return }
        getRecipesForPageWithURL(url: url, completion: completion)
    }
    
    /// Get recipes for specific search terms
    /// - Parameter searchString: The type of recipe wanted, like: "chicken"
    /// - Parameter completion: The completion handler to execute on success or failure
    func getSpecificSearch(searchString: String, completion: @escaping CompletionHandler) {
        guard let url = URLComponents(scheme: Constants.SCHEME, host: Constants.HOST, path: Constants.PATH, queryItems: [URLQueryItem(name: Constants.SEARCH_QUERY, value: searchString)]).url else { return }
        print("here is URL",url)
        
    }
    
    /// Get recipe detail for RecipeDetailVC
    /// - Parameter recipeId: The ID of the recipe to retrieve
    /// - Parameter completion: The completion handler to execute on success or failure
    func getDetailedRecipe(recipeId: String, completion: @escaping CompletionHandler) {
        let urlString = "\(Constants.SEARCH_URL)\(APIKeyService.API_KEY)&\(Constants.RECIPE_ID)=\(recipeId)"
        guard let url = URL(string: urlString) else { return }
        getRecipesForPageWithURL(url: url, completion: completion)
    }
    
    /// This function signature can be used for testing since a URL can be passed in. Could pass in local JSON for XCTest
    fileprivate func getRecipesForPageWithURL(url: URL, completion: @escaping CompletionHandler) {
        request.callAPI(url: url, completion: completion)
    }
}
