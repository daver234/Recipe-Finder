//
//  Requests.swift
//  BlueCart
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation

protocol AbstractRequestClient {
    func callAPI(url: URL, completion: @escaping CompletionHandler)
}

/// Used to make the URL session request
class Request: AbstractRequestClient {
    
    // var url: URL?
    
    func callAPI(url: URL, completion: @escaping CompletionHandler) {
        // guard let url = url else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("URLSession error: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Data or Response error in URLSession of Request.callAPI")
                completion(false)
                return
            }
            DataManager.instance.decodeData(data: data, completion: completion)
        }
        task.resume()
    }
}
