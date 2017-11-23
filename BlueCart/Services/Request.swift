//
//  Requests.swift
//  BlueCart
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation
import Disk

protocol AbstractRequestClient {
    func callAPIForPage(searchString: String, url: URL, completion: @escaping CompletionHandler)
    func callAPIForDetail(reachable: Bool, recipeId: String, url: URL, completion: @escaping CompletionHandlerWithData)
}

/// Used to make the URL session request
class Request: AbstractRequestClient {
    
    var saveRecipes = SaveRecipes()
    
    /// Get a page full of recipes
    func callAPIForPage(searchString: String, url: URL, completion: @escaping CompletionHandler) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("URLSession error: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Data or Response error in URLSession of Request.callAPIForPage")
                completion(false)
                return
            }
            /// To get Top Rated recipes, the search term is empty.  Hence we have to add back a name in order
            /// to create a file name to save
            var searchStringForFileName = ""
            searchString == "" ? (searchStringForFileName = Constants.TOP_RATED) : (searchStringForFileName = searchString)
            DataManager.instance.decodeDataForPage(searchString: searchStringForFileName, data: data, completion: completion)
        }
        task.resume()
    }
    
    /// Get a specific recipe
    func callAPIForDetail(reachable: Bool, recipeId: String, url: URL, completion: @escaping CompletionHandlerWithData) {
        switch reachable {
        case true:
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard error == nil else {
                    print("URLSession error: \(String(describing: error?.localizedDescription))")
                    completion(nil, error)
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Data or Response error in URLSession of Request.CallAPIForDetail")
                    completion(nil, error)
                    return
                }
                // self.saveDetailForOffline(recipeId: recipeId, data: data)
                self.saveRecipes.saveDetailForOffline(recipeId: recipeId, data: data)
                DataManager.instance.decodeDataForDetail(data: data, completion: completion)
            }
            task.resume()
        case false:
            DataManager.instance.retrieveSavedDetailedRecipeWithIngredients(recipeId: recipeId, completion: completion)
        }
    }
}
