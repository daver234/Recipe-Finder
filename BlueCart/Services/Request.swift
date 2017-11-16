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
    // func callAPIForSpecificSearchTerm(searchString: String, url: URL, completion: @escaping CompletionHandler)
}

enum Parameter {
    case searchString(String)
    case reachable(Bool)
    case url(URL)
    case completionShort(CompletionHandler)
    case completionData(CompletionHandlerWithData)
    case pageNumber(Int)
}

/// Used to make the URL session request
class Request: AbstractRequestClient {
    
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
            searchString == "" ? (searchStringForFileName = Constants.TOP_RATED_FILE) : (searchStringForFileName = searchString)
            self.saveRecipePageForOffline(searchString: searchStringForFileName, data: data)
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
                self.saveDetailForOffline(recipeId: recipeId, data: data)
                DataManager.instance.decodeDataForDetail(data: data, completion: completion)
            }
            task.resume()
        case false:
            DataManager.instance.retrieveSavedDetailedRecipeWithIngredients(recipeId: recipeId, completion: completion)
        }
    }
    
    /// Save RecipePage for use in offline
    fileprivate func saveRecipePageForOffline(searchString: String, data: Data) {
        let termTrimmed = searchString.lowercased().replacingOccurrences(of: " ", with: "")
        do {
            if Disk.exists("\(termTrimmed)", in: .caches) {
                try Disk.append(data, to: "Recipe/", in: .caches)
            } else {
                 try Disk.save(data, to: .caches, as: "Recipe/\(termTrimmed)")
            }
           
        } catch let error as NSError  {
            fatalError("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
    }
    
    /// Save RecipeDetail for use in offline. This contains the ingredients.
    /// - Parameter recipeId: This id becomes the file name to retrive later.
    /// - Parameter completion: The completion handler to execute with the data.
    fileprivate func saveDetailForOffline(recipeId: String, data: Data) {
        do {
            try Disk.save(data, to: .caches, as: "\(recipeId)")
        } catch let error as NSError  {
            fatalError("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
    }
}
