//
//  Requests.swift
//  BlueCart
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation

protocol AbstractRequestClient {
    func callAPIForPage(url: URL, completion: @escaping CompletionHandler)
    func callAPIForDetail(url: URL, completion: @escaping CompletionHandlerWithData)
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
}
