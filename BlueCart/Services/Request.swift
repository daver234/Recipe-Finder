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
    func callAPIForPage(url: URL, completion: @escaping CompletionHandler)
    func callAPIForDetail(url: URL, completion: @escaping CompletionHandlerWithData)
    func callAPIForSpecificSearchTerm(searchString: String, url: URL, completion: @escaping CompletionHandler)
}

/// Used to make the URL session request
class Request: AbstractRequestClient {
    
    /// Get a page full of recipes
    func callAPIForPage(url: URL, completion: @escaping CompletionHandler) {
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
            //self.saveRecipePageForOffline(searchString: Constants.TOP_RATED_FILE, data: data)
            DataManager.instance.decodeDataForPage(data: data, completion: completion)
        }
        task.resume()
    }
    
    /// Get a specific recipe
    func callAPIForDetail(url: URL, completion: @escaping CompletionHandlerWithData) {
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
            // self.saveDetailForOffline(data: data)
            DataManager.instance.decodeDataForDetail(data: data, completion: completion)
        }
        task.resume()
    }
    
    
    /// Get a page full of recipes for a specific search term
    /// - Parameter searchString: The text being search. Use to create file name to save
    /// - Parameter url: The url for accessing the backend
    /// - Parameter completion: The completion hanlder to call when dome.
    func callAPIForSpecificSearchTerm(searchString: String, url: URL, completion: @escaping CompletionHandler) {
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
            
            /// Save data to disk for offline access
            self.saveRecipePageForOffline(searchString: searchString, data: data)
            
            DataManager.instance.decodeDataForSpecificSearchTerm(data: data, completion: completion)
        }
        task.resume()
    }
    
    /// Save RecipePage for use in offline
    fileprivate func saveRecipePageForOffline(searchString: String, data: Data) {
        let termTrimmed = searchString.lowercased().replacingOccurrences(of: " ", with: "")
        do {
            try Disk.save(data, to: .caches, as: "\(termTrimmed).json")
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
    
    /// Save RecipeDetail for use in offline.
    /// First create the file if it doesn't exist.  Then append new detailed recipes,
    /// the one with the ingredient list, to the existing file.
    fileprivate func saveDetailForOffline(data: Data) {
        let searchString = Constants.RECIPE_DETAIL_FILE
        let termTrimmed = searchString.lowercased().replacingOccurrences(of: " ", with: "")
        do {
            if Disk.exists("\(Constants.RECIPE_DETAIL_FILE).json", in: .caches) {
                try Disk.append(data, to: "\(termTrimmed).json", in: .caches)
            } else {
                try Disk.save(data, to: .caches, as: "\(termTrimmed).json")
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
}
