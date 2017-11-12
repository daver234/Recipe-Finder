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
        let urlString = "\(Constants.SEARCH_URL)\(APIKeyService.API_KEY)&page=\(pageNumber)"
        guard let url = URL(string: urlString) else { return }
        getRecipesForPageWithURL(url: url, completion: completion)
    }
    
    /// Get recipes for specific search terms
    /// - Parameter searchString: The type of recipe wanted, like: "chicken"
    /// - Parameter completion: The completion handler to execute on success or failure
    func getSpecificSearch(searchString: String, completion: @escaping CompletionHandler) {
        print(searchString)
        let partialURL = searchString.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let urlString = "\(Constants.SEARCH_URL)\(APIKeyService.API_KEY)&q=\(partialURL ?? "")"
        guard let url = URL(string: urlString) else { return }
        print("here is URL and searchTerm", urlString)
        request.callAPIForSpecificSearchTerm(url: url, completion: completion)
    }
    
    /// Get recipe detail for RecipeDetailVC
    /// - Parameter recipeId: The ID of the recipe to retrieve
    /// - Parameter completion: The completion handler to execute on success or failure
    func getDetailedRecipe(recipeId: String, completion: @escaping CompletionHandlerWithData) {
        let urlString = "\(Constants.RECIPE_URL)\(APIKeyService.API_KEY)&\(Constants.RECIPE_ID)=\(recipeId)"
        guard let url = URL(string: urlString) else { return }
        getRecipeDetail(url: url, completion: completion)
    }
    
    /// This function signature can be used for testing since a URL can be passed in. Could pass in local JSON for XCTest
    /// - Parameter url: The URL to call in the backend
    /// - Parameter completion: The completion handler to execute on success or failure
    fileprivate func getRecipesForPageWithURL(url: URL, completion: @escaping CompletionHandler) {
        request.callAPIForPage(url: url, completion: completion)
    }
    
    /// Get the detail for the recipe
    /// - Parameter url: The URL to call in the backend
    /// - Parameter completion: The completion handler to execute on success or failure
    fileprivate func getRecipeDetail(url: URL, completion: @escaping CompletionHandlerWithData) {
        request.callAPIForDetail(url: url, completion: completion)
    }
}
