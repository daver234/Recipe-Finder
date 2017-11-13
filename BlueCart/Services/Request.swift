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
            DataManager.instance.decodeDataForDetail(data: data, completion: completion)
        }
        task.resume()
    }
    
    
    /// Get a page full of recipes for a specific search term
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
            let termTrimmed = searchString.lowercased().replacingOccurrences(of: " ", with: "")
            print("file name to save: \(termTrimmed).json")
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
            DataManager.instance.decodeDataForSpecificSearchTerm(data: data, completion: completion)
        }
        task.resume()
    }
    
}
