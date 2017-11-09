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
    
    func getRecipesForPage(pageNumber: Int, completion: @escaping CompletionHandler) {
        print("*** in APIManager: next pageNumber to get is:", pageNumber)
        let urlString = "\(Constants.SEARCH_URL)\(API_KEY)&page=\(pageNumber)"
        guard let url = URL(string: urlString) else { return }
        getRecipesForPageWithURL(url: url, pageNumber: pageNumber, completion: completion)
    }
    
    func getSpecificSearch(searchString: String, pageSize: Int, completion: @escaping CompletionHandler) {
        // let urlString = "\(Constants().SEARCH_URL)\(API_KEY)&q\(searchString)"
        guard let url = URLComponents(scheme: Constants.SCHEME, host: Constants.HOST, path: Constants.PATH, queryItems: [URLQueryItem(name: "q", value: searchString)]).url else { return }
        print("here is URL",url)
        
    }
    
    /// This function signature can be used for testing since a URL can be passed in. Could pass in local JSON for XCTest
    fileprivate func getRecipesForPageWithURL(url: URL, pageNumber: Int, completion: @escaping CompletionHandler) {
        /// Check to see if we have already retrieved all the data.  If so, return and don't call the API again.
//        guard !DataManager.instance.checkForEndOfDataIsTrue() else {
//            print("GOT TO END DATA")
//            completion(false)
//            return
//        }
        // request.url = url
        request.callAPI(url: url, completion: completion)
    }
}
